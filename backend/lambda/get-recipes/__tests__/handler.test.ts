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
    it("レシピ一覧を正常に取得できる（ingredients, likeCount含む）", async () => {
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

      // recipe-1の詳細（材料2つ、いいね3つ）
      const mockRecipe1Details = [
        {
          PK: "RECIPE#recipe-1",
          SK: "RECIPE#recipe-1",
          RecipeId: "recipe-1",
        },
        {
          PK: "RECIPE#recipe-1",
          SK: "INGREDIENT#000#ing-1",
          IngredientId: "ing-1",
          Name: "材料1",
          Amount: "100g",
          OrderIndex: 0,
        },
        {
          PK: "RECIPE#recipe-1",
          SK: "INGREDIENT#001#ing-2",
          IngredientId: "ing-2",
          Name: "材料2",
          Amount: "200ml",
          OrderIndex: 1,
        },
        {
          PK: "RECIPE#recipe-1",
          SK: "LIKE#liker-1",
          UserId: "liker-1",
        },
        {
          PK: "RECIPE#recipe-1",
          SK: "LIKE#liker-2",
          UserId: "liker-2",
        },
        {
          PK: "RECIPE#recipe-1",
          SK: "LIKE#liker-3",
          UserId: "liker-3",
        },
      ];

      // recipe-2の詳細（材料1つ、いいね0）
      const mockRecipe2Details = [
        {
          PK: "RECIPE#recipe-2",
          SK: "RECIPE#recipe-2",
          RecipeId: "recipe-2",
        },
        {
          PK: "RECIPE#recipe-2",
          SK: "INGREDIENT#000#ing-3",
          IngredientId: "ing-3",
          Name: "材料A",
          Amount: "50g",
          OrderIndex: 0,
        },
      ];

      mockSend
        .mockResolvedValueOnce({ Items: mockRecipes }) // GSI2 Query
        .mockResolvedValueOnce({ Responses: { "test-table": mockUsers } }) // BatchGet users
        .mockResolvedValueOnce({ Items: mockRecipe1Details }) // Query recipe-1 details
        .mockResolvedValueOnce({ Items: mockRecipe2Details }); // Query recipe-2 details

      const event = createMockEvent();
      const result = await handler(event);

      expect(result.statusCode).toBe(200);

      const body = JSON.parse(result.body);
      expect(body).toHaveLength(2);

      // recipe-1の検証
      expect(body[0]).toMatchObject({
        id: "recipe-1",
        title: "テストレシピ1",
        user: {
          id: "user-1",
          name: "ユーザー1",
        },
        likeCount: 3,
      });
      expect(body[0].ingredients).toHaveLength(2);
      expect(body[0].ingredients[0]).toMatchObject({
        id: "ing-1",
        name: "材料1",
        amount: "100g",
      });
      expect(body[0].ingredients[1]).toMatchObject({
        id: "ing-2",
        name: "材料2",
        amount: "200ml",
      });

      // recipe-2の検証
      expect(body[1]).toMatchObject({
        id: "recipe-2",
        title: "テストレシピ2",
        likeCount: 0,
      });
      expect(body[1].ingredients).toHaveLength(1);
      expect(body[1].ingredients[0]).toMatchObject({
        id: "ing-3",
        name: "材料A",
        amount: "50g",
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

      const mockRecipeDetails = [
        {
          PK: "RECIPE#recipe-1",
          SK: "RECIPE#recipe-1",
          RecipeId: "recipe-1",
        },
      ];

      mockSend
        .mockResolvedValueOnce({ Items: mockRecipes }) // GSI2 Query
        .mockResolvedValueOnce({ Responses: { "test-table": [] } }) // BatchGet users (empty)
        .mockResolvedValueOnce({ Items: mockRecipeDetails }); // Query recipe details

      const event = createMockEvent();
      const result = await handler(event);

      expect(result.statusCode).toBe(200);

      const body = JSON.parse(result.body);
      expect(body[0].user).toMatchObject({
        id: "unknown-user",
        name: "Unknown",
      });
      expect(body[0].ingredients).toEqual([]);
      expect(body[0].likeCount).toBe(0);
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
