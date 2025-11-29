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
  QueryCommand: jest.fn((params) => ({ type: "Query", params })),
  BatchGetCommand: jest.fn((params) => ({ type: "BatchGet", params })),
}));

/**
 * テスト用のAPIGatewayProxyEventを作成する
 */
function createMockEvent(
  overrides: Partial<APIGatewayProxyEvent> = {}
): APIGatewayProxyEvent {
  return {
    httpMethod: "GET",
    path: "/v1/recipes",
    headers: {},
    multiValueHeaders: {},
    queryStringParameters: null,
    multiValueQueryStringParameters: null,
    pathParameters: null,
    stageVariables: null,
    requestContext: {} as APIGatewayProxyEvent["requestContext"],
    resource: "",
    body: null,
    isBase64Encoded: false,
    ...overrides,
  };
}

describe("GET /recipes ハンドラー", () => {
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
        "Access-Control-Allow-Methods": "GET, OPTIONS",
      });
    });
  });

  describe("GETリクエスト", () => {
    it("レシピ一覧を正常に取得できる", async () => {
      const mockRecipes = [
        {
          PK: "RECIPE#recipe-1",
          SK: "META",
          title: "テストレシピ1",
          overview: "テスト概要1",
          image_url: "https://example.com/image1.jpg",
          is_ai_generated: false,
          created_at: "2025-01-01T00:00:00Z",
          user_id: "user-1",
        },
        {
          PK: "RECIPE#recipe-2",
          SK: "META",
          title: "テストレシピ2",
          overview: "テスト概要2",
          image_url: "https://example.com/image2.jpg",
          is_ai_generated: true,
          created_at: "2025-01-02T00:00:00Z",
          user_id: "user-2",
        },
      ];

      const mockUsers = [
        {
          PK: "USER#user-1",
          SK: "PROFILE",
          name: "ユーザー1",
          image_url: "https://example.com/user1.jpg",
          description: "説明1",
          email_address: "user1@example.com",
        },
        {
          PK: "USER#user-2",
          SK: "PROFILE",
          name: "ユーザー2",
          image_url: "https://example.com/user2.jpg",
          description: "説明2",
          email_address: "user2@example.com",
        },
      ];

      mockSend
        .mockResolvedValueOnce({ Items: mockRecipes })
        .mockResolvedValueOnce({
          Responses: { "test-table": mockUsers },
        });

      const event = createMockEvent();
      const result = await handler(event);

      expect(result.statusCode).toBe(200);

      const body = JSON.parse(result.body);
      expect(body).toHaveLength(2);
      expect(body[0]).toMatchObject({
        id: "recipe-1",
        title: "テストレシピ1",
        user: {
          id: "user-1",
          name: "ユーザー1",
        },
      });
    });

    it("レシピが存在しない場合は空配列を返す", async () => {
      mockSend.mockResolvedValueOnce({ Items: [] });

      const event = createMockEvent();
      const result = await handler(event);

      expect(result.statusCode).toBe(200);

      const body = JSON.parse(result.body);
      expect(body).toEqual([]);
    });

    it("ユーザー情報が取得できない場合はデフォルト値を使用する", async () => {
      const mockRecipes = [
        {
          PK: "RECIPE#recipe-1",
          SK: "META",
          title: "テストレシピ",
          overview: "テスト概要",
          created_at: "2025-01-01T00:00:00Z",
          user_id: "unknown-user",
        },
      ];

      mockSend
        .mockResolvedValueOnce({ Items: mockRecipes })
        .mockResolvedValueOnce({ Responses: { "test-table": [] } });

      const event = createMockEvent();
      const result = await handler(event);

      expect(result.statusCode).toBe(200);

      const body = JSON.parse(result.body);
      expect(body[0].user).toMatchObject({
        id: "unknown-user",
        name: "Unknown",
      });
    });

    it("DynamoDBエラー時は500を返す", async () => {
      mockSend.mockRejectedValueOnce(new Error("DynamoDB error"));

      const event = createMockEvent();
      const result = await handler(event);

      expect(result.statusCode).toBe(500);

      const body = JSON.parse(result.body);
      expect(body.error).toBe("Internal server error");
    });
  });
});
