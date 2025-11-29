import { APIGatewayProxyEvent } from "aws-lambda";

const mockSend = jest.fn();

jest.mock("@aws-sdk/client-dynamodb", () => ({
  DynamoDBClient: jest.fn(() => ({})),
}));

jest.mock("@aws-sdk/lib-dynamodb", () => ({
  DynamoDBDocumentClient: {
    from: jest.fn(() => ({
      send: mockSend,
    })),
  },
  PutCommand: jest.fn((params) => ({ type: "Put", params })),
}));

jest.mock("uuid", () => ({
  v4: jest.fn(() => "mock-uuid-12345"),
}));

/**
 * テスト用のAPIGatewayProxyEventを作成する
 */
function createMockEvent(
  overrides: Partial<APIGatewayProxyEvent> = {}
): APIGatewayProxyEvent {
  return {
    httpMethod: "POST",
    path: "/v1/users",
    headers: {},
    multiValueHeaders: {},
    queryStringParameters: null,
    multiValueQueryStringParameters: null,
    pathParameters: null,
    stageVariables: null,
    requestContext: {} as APIGatewayProxyEvent["requestContext"],
    resource: "",
    body: JSON.stringify({
      name: "テストユーザー",
      email_address: "test@example.com",
      image_url: "https://example.com/avatar.jpg",
    }),
    isBase64Encoded: false,
    ...overrides,
  };
}

describe("POST /users ハンドラー", () => {
  let handler: typeof import("../src/index").handler;

  beforeEach(async () => {
    jest.clearAllMocks();
    jest.resetModules();
    process.env.DYNAMODB_TABLE_NAME = "test-table";

    const module = await import("../src/index");
    handler = module.handler;
  });

  describe("OPTIONSリクエスト", () => {
    it("CORSヘッダー付きで200を返す", async () => {
      const event = createMockEvent({ httpMethod: "OPTIONS" });

      const result = await handler(event);

      expect(result.statusCode).toBe(200);
      expect(result.headers).toMatchObject({
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "GET,POST,OPTIONS",
      });
    });
  });

  describe("POSTリクエスト", () => {
    it("ユーザーを正常に作成できる", async () => {
      mockSend.mockResolvedValueOnce({});

      const event = createMockEvent();
      const result = await handler(event);

      expect(result.statusCode).toBe(201);
      expect(result.headers).toMatchObject({
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
      });

      const body = JSON.parse(result.body);
      expect(body).toMatchObject({
        id: "mock-uuid-12345",
        name: "テストユーザー",
        email_address: "test@example.com",
        image_url: "https://example.com/avatar.jpg",
        description: "",
      });
    });

    it("リクエストボディがない場合は400を返す", async () => {
      const event = createMockEvent({ body: null });

      const result = await handler(event);

      expect(result.statusCode).toBe(400);

      const body = JSON.parse(result.body);
      expect(body.message).toBe("リクエストボディが必要です");
    });

    it("email_addressがない場合は400を返す", async () => {
      const event = createMockEvent({
        body: JSON.stringify({ name: "テスト" }),
      });

      const result = await handler(event);

      expect(result.statusCode).toBe(400);

      const body = JSON.parse(result.body);
      expect(body.message).toBe("email_addressは必須です");
    });

    it("nameとimage_urlがない場合は空文字でユーザーを作成する", async () => {
      mockSend.mockResolvedValueOnce({});

      const event = createMockEvent({
        body: JSON.stringify({ email_address: "test@example.com" }),
      });

      const result = await handler(event);

      expect(result.statusCode).toBe(201);

      const body = JSON.parse(result.body);
      expect(body.name).toBe("");
      expect(body.image_url).toBe("");
    });

    it("DynamoDBエラー時は500を返す", async () => {
      mockSend.mockRejectedValueOnce(new Error("DynamoDB error"));

      const event = createMockEvent();
      const result = await handler(event);

      expect(result.statusCode).toBe(500);

      const body = JSON.parse(result.body);
      expect(body.message).toContain("サーバーエラーが発生しました");
    });

    it("DynamoDBに正しいパラメータで保存される", async () => {
      mockSend.mockResolvedValueOnce({});

      const event = createMockEvent();
      await handler(event);

      expect(mockSend).toHaveBeenCalledTimes(1);
      const putCommand = mockSend.mock.calls[0][0];
      expect(putCommand.type).toBe("Put");
      expect(putCommand.params.TableName).toBe("test-table");
      expect(putCommand.params.Item.PK).toBe("USER#mock-uuid-12345");
      expect(putCommand.params.Item.SK).toBe("PROFILE");
      expect(putCommand.params.Item.EntityType).toBe("USER");
      expect(putCommand.params.Item.EmailAddress).toBe("test@example.com");
      expect(putCommand.params.Item.GSI3PK).toBe("EMAIL#test@example.com");
    });
  });
});
