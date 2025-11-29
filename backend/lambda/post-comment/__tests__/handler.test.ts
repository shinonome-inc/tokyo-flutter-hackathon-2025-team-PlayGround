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
  GetCommand: jest.fn((params) => ({ type: "Get", params })),
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
    path: "/v1/recipes/test-recipe-id/comments",
    headers: {},
    multiValueHeaders: {},
    queryStringParameters: null,
    multiValueQueryStringParameters: null,
    pathParameters: { recipeId: "test-recipe-id" },
    stageVariables: null,
    requestContext: {} as APIGatewayProxyEvent["requestContext"],
    resource: "",
    body: JSON.stringify({
      user_id: "user-1",
      description: "テストコメント",
    }),
    isBase64Encoded: false,
    ...overrides,
  };
}

describe("POST /recipes/{recipeId}/comments ハンドラー", () => {
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
        "Access-Control-Allow-Methods": "POST,OPTIONS",
      });
    });
  });

  describe("POSTリクエスト", () => {
    it("コメントを正常に作成できる", async () => {
      const mockUser = {
        PK: "USER#user-1",
        SK: "PROFILE",
        UserName: "テストユーザー",
      };

      mockSend
        .mockResolvedValueOnce({ Item: mockUser })
        .mockResolvedValueOnce({});

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
        user_id: "user-1",
        user_name: "テストユーザー",
        description: "テストコメント",
      });
      expect(body.created_at).toBeDefined();
    });

    it("recipeIdがない場合は400を返す", async () => {
      const event = createMockEvent({ pathParameters: null });

      const result = await handler(event);

      expect(result.statusCode).toBe(400);

      const body = JSON.parse(result.body);
      expect(body.message).toBe("recipeIdが指定されていません");
    });

    it("リクエストボディがない場合は400を返す", async () => {
      const event = createMockEvent({ body: null });

      const result = await handler(event);

      expect(result.statusCode).toBe(400);

      const body = JSON.parse(result.body);
      expect(body.message).toBe("リクエストボディが必要です");
    });

    it("descriptionがない場合は400を返す", async () => {
      const event = createMockEvent({
        body: JSON.stringify({ user_id: "user-1" }),
      });

      const result = await handler(event);

      expect(result.statusCode).toBe(400);

      const body = JSON.parse(result.body);
      expect(body.message).toBe("descriptionは必須です");
    });

    it("user_idがない場合は400を返す", async () => {
      const event = createMockEvent({
        body: JSON.stringify({ description: "テストコメント" }),
      });

      const result = await handler(event);

      expect(result.statusCode).toBe(400);

      const body = JSON.parse(result.body);
      expect(body.message).toBe("user_idは必須です");
    });

    it("ユーザー情報が取得できない場合はUnknown Userを使用する", async () => {
      mockSend.mockResolvedValueOnce({ Item: null }).mockResolvedValueOnce({});

      const event = createMockEvent();
      const result = await handler(event);

      expect(result.statusCode).toBe(201);

      const body = JSON.parse(result.body);
      expect(body.user_name).toBe("Unknown User");
    });

    it("DynamoDBエラー時は500を返す", async () => {
      mockSend.mockRejectedValueOnce(new Error("DynamoDB error"));

      const event = createMockEvent();
      const result = await handler(event);

      expect(result.statusCode).toBe(500);

      const body = JSON.parse(result.body);
      expect(body.message).toContain("サーバーエラーが発生しました");
    });
  });
});
