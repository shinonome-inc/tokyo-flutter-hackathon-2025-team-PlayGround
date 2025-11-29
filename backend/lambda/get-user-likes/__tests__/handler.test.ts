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
  BatchGetCommand: jest.fn((params) => ({ type: "BatchGet", params })),
}));

function createMockEvent(
  overrides: Partial<APIGatewayProxyEvent> = {}
): APIGatewayProxyEvent {
  return {
    httpMethod: "GET",
    path: "/v1/users/test-user-id/likes",
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

describe("GET /users/{userId}/likes ハンドラー", () => {
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
    it("ユーザーのいいね一覧を取得できる", async () => {
      const mockUser = {
        PK: "USER#user-123",
        SK: "PROFILE",
        UserId: "user-123",
        UserName: "テストユーザー",
        ImageUrl: "https://example.com/user.jpg",
        Description: "自己紹介",
        EmailAddress: "test@example.com",
      };

      const mockLikes = [
        {
          PK: "RECIPE#recipe-1",
          SK: "LIKE#user-123",
          GSI1PK: "USER#test-user-id",
          GSI1SK: "LIKE#2025-01-02T00:00:00.000Z",
          RecipeId: "recipe-1",
          UserId: "test-user-id",
          CreatedAt: "2025-01-02T00:00:00.000Z",
          EntityType: "LIKE",
        },
        {
          PK: "RECIPE#recipe-2",
          SK: "LIKE#user-123",
          GSI1PK: "USER#test-user-id",
          GSI1SK: "LIKE#2025-01-01T00:00:00.000Z",
          RecipeId: "recipe-2",
          UserId: "test-user-id",
          CreatedAt: "2025-01-01T00:00:00.000Z",
          EntityType: "LIKE",
        },
      ];

      const mockRecipes = [
        {
          PK: "RECIPE#recipe-1",
          SK: "RECIPE#recipe-1",
          RecipeId: "recipe-1",
          UserId: "author-1",
          Title: "レシピ1",
          Overview: "概要1",
          ImageUrl: "https://example.com/1.jpg",
          IsAiGenerated: false,
          CreatedAt: "2025-01-01T00:00:00.000Z",
        },
        {
          PK: "RECIPE#recipe-2",
          SK: "RECIPE#recipe-2",
          RecipeId: "recipe-2",
          UserId: "author-2",
          Title: "レシピ2",
          Overview: "概要2",
          ImageUrl: "https://example.com/2.jpg",
          IsAiGenerated: true,
          CreatedAt: "2024-12-31T00:00:00.000Z",
        },
      ];

      const mockAuthors = [
        {
          PK: "USER#author-1",
          SK: "PROFILE",
          UserId: "author-1",
          UserName: "作者1",
          ImageUrl: "https://example.com/author1.jpg",
          Description: "作者1の紹介",
          EmailAddress: "author1@example.com",
        },
        {
          PK: "USER#author-2",
          SK: "PROFILE",
          UserId: "author-2",
          UserName: "作者2",
          ImageUrl: "https://example.com/author2.jpg",
          Description: "作者2の紹介",
          EmailAddress: "author2@example.com",
        },
      ];

      // GetCommand（ユーザー存在確認）
      mockSend.mockResolvedValueOnce({ Item: mockUser });
      // QueryCommand（いいね取得）
      mockSend.mockResolvedValueOnce({ Items: mockLikes });
      // BatchGetCommand（レシピ取得）
      mockSend.mockResolvedValueOnce({
        Responses: { "test-table": mockRecipes },
      });
      // BatchGetCommand（作者取得）
      mockSend.mockResolvedValueOnce({
        Responses: { "test-table": mockAuthors },
      });

      const event = createMockEvent();
      const result = await handler(event);

      expect(result.statusCode).toBe(200);

      const body = JSON.parse(result.body);
      expect(body).toHaveLength(2);
      expect(body[0]).toMatchObject({
        id: "recipe-1",
        title: "レシピ1",
        liked_at: "2025-01-02T00:00:00.000Z",
        user: {
          id: "author-1",
          name: "作者1",
        },
      });
      expect(body[1]).toMatchObject({
        id: "recipe-2",
        title: "レシピ2",
        liked_at: "2025-01-01T00:00:00.000Z",
        user: {
          id: "author-2",
          name: "作者2",
        },
      });

      // GSI1を使用していることを確認
      const queryCommand = mockSend.mock.calls[1][0];
      expect(queryCommand.params.IndexName).toBe("GSI1");
      expect(queryCommand.params.ExpressionAttributeValues[":pk"]).toBe(
        "USER#test-user-id"
      );
      expect(queryCommand.params.ExpressionAttributeValues[":sk"]).toBe(
        "LIKE#"
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

    it("いいねがない場合は空配列を返す", async () => {
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
