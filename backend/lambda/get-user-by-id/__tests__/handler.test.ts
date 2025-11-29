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
  GetCommand: jest.fn((params) => ({ type: "Get", params })),
}));

/**
 * テスト用のAPIGatewayProxyEventを作成する
 */
function createMockEvent(
  overrides: Partial<APIGatewayProxyEvent> = {}
): APIGatewayProxyEvent {
  return {
    httpMethod: "GET",
    path: "/v1/users/test-user-id",
    headers: {},
    multiValueHeaders: {},
    queryStringParameters: null,
    multiValueQueryStringParameters: null,
    pathParameters: { userId: "test-user-id" },
    stageVariables: null,
    requestContext: {} as APIGatewayProxyEvent["requestContext"],
    resource: "",
    body: null,
    isBase64Encoded: false,
    ...overrides,
  };
}

describe("GET /users/{userId} ハンドラー", () => {
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
        "Access-Control-Allow-Methods": "GET,OPTIONS",
      });
    });
  });

  describe("GETリクエスト", () => {
    it("ユーザー情報を取得できる", async () => {
      const mockUser = {
        PK: "USER#user-123",
        SK: "PROFILE",
        UserId: "user-123",
        UserName: "テストユーザー",
        ImageUrl: "https://example.com/image.jpg",
        Description: "自己紹介文",
        EmailAddress: "test@example.com",
        CreatedAt: "2025-01-01T00:00:00.000Z",
        UpdatedAt: "2025-01-01T00:00:00.000Z",
      };

      mockSend.mockResolvedValueOnce({ Item: mockUser });

      const event = createMockEvent();
      const result = await handler(event);

      expect(result.statusCode).toBe(200);

      const body = JSON.parse(result.body);
      expect(body).toMatchObject({
        id: "user-123",
        name: "テストユーザー",
        imageUrl: "https://example.com/image.jpg",
        description: "自己紹介文",
        emailAddress: "test@example.com",
      });

      // GetCommandのパラメータを確認
      const getCommand = mockSend.mock.calls[0][0];
      expect(getCommand.params.Key).toEqual({
        PK: "USER#test-user-id",
        SK: "PROFILE",
      });
    });

    it("userIdがない場合は400を返す", async () => {
      const event = createMockEvent({
        pathParameters: null,
      });

      const result = await handler(event);

      expect(result.statusCode).toBe(400);

      const body = JSON.parse(result.body);
      expect(body.message).toBe("userId is required");
    });

    it("ユーザーが見つからない場合は404を返す", async () => {
      mockSend.mockResolvedValueOnce({ Item: undefined });

      const event = createMockEvent();
      const result = await handler(event);

      expect(result.statusCode).toBe(404);

      const body = JSON.parse(result.body);
      expect(body.message).toBe("User not found");
    });

    it("DynamoDBエラー時は500を返す", async () => {
      mockSend.mockRejectedValueOnce(new Error("DynamoDB error"));

      const event = createMockEvent();
      const result = await handler(event);

      expect(result.statusCode).toBe(500);

      const body = JSON.parse(result.body);
      expect(body.message).toContain("サーバーエラーが発生しました");
    });

    it("ユーザー情報が部分的に欠けている場合も正常に処理する", async () => {
      const mockUser = {
        PK: "USER#user-123",
        SK: "PROFILE",
        UserId: "user-123",
        // UserName, ImageUrl, Description が欠けている
        EmailAddress: "test@example.com",
      };

      mockSend.mockResolvedValueOnce({ Item: mockUser });

      const event = createMockEvent();
      const result = await handler(event);

      expect(result.statusCode).toBe(200);

      const body = JSON.parse(result.body);
      expect(body).toMatchObject({
        id: "user-123",
        name: "",
        imageUrl: "",
        description: "",
        emailAddress: "test@example.com",
      });
    });
  });
});
