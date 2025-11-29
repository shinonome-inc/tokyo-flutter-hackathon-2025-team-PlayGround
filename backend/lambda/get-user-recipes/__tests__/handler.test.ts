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
  QueryCommand: jest.fn((params) => ({ type: "Query", params })),
}));

function createMockEvent(
  overrides: Partial<APIGatewayProxyEvent> = {}
): APIGatewayProxyEvent {
  return {
    httpMethod: "GET",
    path: "/v1/users/test-user-id/recipes",
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

describe("GET /users/{userId}/recipes ハンドラー", () => {
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
    it("ユーザーのレシピ一覧を取得できる", async () => {
      const mockUser = {
        PK: "USER#user-123",
        SK: "PROFILE",
        UserId: "user-123",
        UserName: "テストユーザー",
        ImageUrl: "https://example.com/user.jpg",
        Description: "自己紹介",
        EmailAddress: "test@example.com",
      };

      const mockRecipes = [
        {
          PK: "RECIPE#recipe-1",
          SK: "RECIPE#recipe-1",
          GSI1PK: "USER#user-123",
          GSI1SK: "RECIPE#2025-01-01T00:00:00.000Z",
          title: "レシピ1",
          overview: "概要1",
          image_url: "https://example.com/1.jpg",
          is_ai_generated: false,
          created_at: "2025-01-01T00:00:00.000Z",
        },
        {
          PK: "RECIPE#recipe-2",
          SK: "RECIPE#recipe-2",
          GSI1PK: "USER#user-123",
          GSI1SK: "RECIPE#2025-01-02T00:00:00.000Z",
          title: "レシピ2",
          overview: "概要2",
          image_url: "https://example.com/2.jpg",
          is_ai_generated: true,
          created_at: "2025-01-02T00:00:00.000Z",
        },
      ];

      // GetCommand（ユーザー取得）
      mockSend.mockResolvedValueOnce({ Item: mockUser });
      // QueryCommand（レシピ取得）
      mockSend.mockResolvedValueOnce({ Items: mockRecipes });

      const event = createMockEvent();
      const result = await handler(event);

      expect(result.statusCode).toBe(200);

      const body = JSON.parse(result.body);
      expect(body).toHaveLength(2);
      expect(body[0]).toMatchObject({
        id: "recipe-1",
        title: "レシピ1",
        user: {
          id: "user-123",
          name: "テストユーザー",
        },
      });

      // GSI1を使用していることを確認
      const queryCommand = mockSend.mock.calls[1][0];
      expect(queryCommand.params.IndexName).toBe("GSI1");
      expect(queryCommand.params.ExpressionAttributeValues[":pk"]).toBe(
        "USER#test-user-id"
      );
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

    it("レシピがない場合は空配列を返す", async () => {
      const mockUser = {
        PK: "USER#user-123",
        SK: "PROFILE",
        UserId: "user-123",
        UserName: "テストユーザー",
        ImageUrl: "",
        Description: "",
        EmailAddress: "test@example.com",
      };

      mockSend.mockResolvedValueOnce({ Item: mockUser });
      mockSend.mockResolvedValueOnce({ Items: [] });

      const event = createMockEvent();
      const result = await handler(event);

      expect(result.statusCode).toBe(200);

      const body = JSON.parse(result.body);
      expect(body).toEqual([]);
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
