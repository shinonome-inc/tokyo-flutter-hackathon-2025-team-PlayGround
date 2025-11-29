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

/**
 * テスト用のJWTトークンを作成する
 */
function createMockJwt(sub: string): string {
  const header = Buffer.from(JSON.stringify({ alg: "HS256", typ: "JWT" })).toString("base64");
  const payload = Buffer.from(JSON.stringify({ sub })).toString("base64");
  const signature = "mock-signature";
  return `${header}.${payload}.${signature}`;
}

/**
 * テスト用のAPIGatewayProxyEventを作成する
 */
function createMockEvent(
  overrides: Partial<APIGatewayProxyEvent> = {}
): APIGatewayProxyEvent {
  return {
    httpMethod: "POST",
    path: "/v1/users",
    headers: {
      Authorization: `Bearer ${createMockJwt("mock-user-id-12345")}`,
    },
    multiValueHeaders: {},
    queryStringParameters: null,
    multiValueQueryStringParameters: null,
    pathParameters: null,
    stageVariables: null,
    requestContext: {} as APIGatewayProxyEvent["requestContext"],
    resource: "",
    body: JSON.stringify({
      name: "テストユーザー",
      emailAddress: "test@example.com",
      imageUrl: "https://example.com/avatar.jpg",
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

  describe("認証", () => {
    it("Authorizationヘッダーがない場合は401を返す", async () => {
      const event = createMockEvent({ headers: {} });

      const result = await handler(event);

      expect(result.statusCode).toBe(401);

      const body = JSON.parse(result.body);
      expect(body.message).toBe("認証が必要です");
    });

    it("不正なトークン形式の場合は401を返す", async () => {
      const event = createMockEvent({
        headers: { Authorization: "Bearer invalid-token" },
      });

      const result = await handler(event);

      expect(result.statusCode).toBe(401);
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
        id: "mock-user-id-12345",
        name: "テストユーザー",
        emailAddress: "test@example.com",
        imageUrl: "https://example.com/avatar.jpg",
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

    it("emailAddressがない場合は400を返す", async () => {
      const event = createMockEvent({
        body: JSON.stringify({ name: "テスト" }),
      });

      const result = await handler(event);

      expect(result.statusCode).toBe(400);

      const body = JSON.parse(result.body);
      expect(body.message).toBe("emailAddressは必須です");
    });

    it("nameとimageUrlがない場合は空文字でユーザーを作成する", async () => {
      mockSend.mockResolvedValueOnce({});

      const event = createMockEvent({
        body: JSON.stringify({ emailAddress: "test@example.com" }),
      });

      const result = await handler(event);

      expect(result.statusCode).toBe(201);

      const body = JSON.parse(result.body);
      expect(body.name).toBe("");
      expect(body.imageUrl).toBe("");
    });

    it("DynamoDBエラー時は500を返す", async () => {
      mockSend.mockRejectedValueOnce(new Error("DynamoDB error"));

      const event = createMockEvent();
      const result = await handler(event);

      expect(result.statusCode).toBe(500);

      const body = JSON.parse(result.body);
      expect(body.message).toContain("サーバーエラーが発生しました");
    });

    it("DynamoDBに正しいパラメータで保存される（userIdはJWTのsubを使用）", async () => {
      mockSend.mockResolvedValueOnce({});

      const event = createMockEvent();
      await handler(event);

      expect(mockSend).toHaveBeenCalledTimes(1);
      const putCommand = mockSend.mock.calls[0][0];
      expect(putCommand.type).toBe("Put");
      expect(putCommand.params.TableName).toBe("test-table");
      expect(putCommand.params.Item.PK).toBe("USER#mock-user-id-12345");
      expect(putCommand.params.Item.SK).toBe("PROFILE");
      expect(putCommand.params.Item.UserId).toBe("mock-user-id-12345");
      expect(putCommand.params.Item.EntityType).toBe("USER");
      expect(putCommand.params.Item.EmailAddress).toBe("test@example.com");
      expect(putCommand.params.Item.GSI3PK).toBe("EMAIL#test@example.com");
    });
  });
});
