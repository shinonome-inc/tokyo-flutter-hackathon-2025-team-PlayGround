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
    path: "/v1/recipes/test-recipe-id",
    headers: {},
    multiValueHeaders: {},
    queryStringParameters: null,
    multiValueQueryStringParameters: null,
    pathParameters: { recipeId: "test-recipe-id" },
    stageVariables: null,
    requestContext: {} as APIGatewayProxyEvent["requestContext"],
    resource: "",
    body: null,
    isBase64Encoded: false,
    ...overrides,
  };
}

describe("GET /recipes/{recipeId} ハンドラー", () => {
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
    it("レシピ詳細を正常に取得できる", async () => {
      const recipeId = "test-recipe-id";
      const userId = "user-1";

      const mockRecipeItems = [
        {
          PK: `RECIPE#${recipeId}`,
          SK: `RECIPE#${recipeId}`,
          RecipeId: recipeId,
          UserId: userId,
          Title: "テストレシピ",
          Overview: "テスト概要",
          Notes: "メモ",
          ImageUrl: "https://example.com/image.jpg",
          IsAiGenerated: false,
          CreatedAt: "2025-01-01T00:00:00Z",
          UpdatedAt: "2025-01-02T00:00:00Z",
          EntityType: "RECIPE",
        },
        {
          PK: `RECIPE#${recipeId}`,
          SK: "INGREDIENT#000#ing-1",
          IngredientId: "ing-1",
          RecipeId: recipeId,
          Name: "材料1",
          Amount: "100g",
          OrderIndex: 0,
          EntityType: "INGREDIENT",
        },
        {
          PK: `RECIPE#${recipeId}`,
          SK: "INGREDIENT#001#ing-2",
          IngredientId: "ing-2",
          RecipeId: recipeId,
          Name: "材料2",
          Amount: "200ml",
          OrderIndex: 1,
          EntityType: "INGREDIENT",
        },
        {
          PK: `RECIPE#${recipeId}`,
          SK: "STEP#001#step-1",
          StepId: "step-1",
          RecipeId: recipeId,
          OrderNumber: 1,
          Description: "手順1の説明",
          EntityType: "STEP",
        },
        {
          PK: `RECIPE#${recipeId}`,
          SK: "STEP#002#step-2",
          StepId: "step-2",
          RecipeId: recipeId,
          OrderNumber: 2,
          Description: "手順2の説明",
          EntityType: "STEP",
        },
      ];

      const mockUser = {
        PK: `USER#${userId}`,
        SK: "PROFILE",
        name: "テストユーザー",
        image_url: "https://example.com/user.jpg",
        description: "ユーザー説明",
        email_address: "test@example.com",
      };

      mockSend
        .mockResolvedValueOnce({ Items: mockRecipeItems })
        .mockResolvedValueOnce({ Item: mockUser });

      const event = createMockEvent();
      const result = await handler(event);

      expect(result.statusCode).toBe(200);

      const body = JSON.parse(result.body);
      expect(body).toMatchObject({
        id: recipeId,
        title: "テストレシピ",
        overview: "テスト概要",
        notes: "メモ",
        image_url: "https://example.com/image.jpg",
        is_ai_generated: false,
        created_at: "2025-01-01T00:00:00Z",
        updated_at: "2025-01-02T00:00:00Z",
        user: {
          id: userId,
          name: "テストユーザー",
          image_url: "https://example.com/user.jpg",
          description: "ユーザー説明",
          email_address: "test@example.com",
        },
      });

      expect(body.ingredients).toHaveLength(2);
      expect(body.ingredients[0]).toMatchObject({
        id: "ing-1",
        name: "材料1",
        amount: "100g",
        order_index: 0,
      });
      expect(body.ingredients[1]).toMatchObject({
        id: "ing-2",
        name: "材料2",
        amount: "200ml",
        order_index: 1,
      });

      expect(body.steps).toHaveLength(2);
      expect(body.steps[0]).toMatchObject({
        id: "step-1",
        order_number: 1,
        description: "手順1の説明",
      });
      expect(body.steps[1]).toMatchObject({
        id: "step-2",
        order_number: 2,
        description: "手順2の説明",
      });
    });

    it("recipeIdがない場合は400を返す", async () => {
      const event = createMockEvent({ pathParameters: null });

      const result = await handler(event);

      expect(result.statusCode).toBe(400);

      const body = JSON.parse(result.body);
      expect(body.error).toBe("Bad Request");
      expect(body.message).toBe("recipeId is required");
    });

    it("レシピが存在しない場合は404を返す", async () => {
      mockSend.mockResolvedValueOnce({ Items: [] });

      const event = createMockEvent();
      const result = await handler(event);

      expect(result.statusCode).toBe(404);

      const body = JSON.parse(result.body);
      expect(body.error).toBe("Not Found");
      expect(body.message).toBe("Recipe not found");
    });

    it("ユーザー情報が取得できない場合はデフォルト値を使用する", async () => {
      const recipeId = "test-recipe-id";
      const userId = "unknown-user";

      const mockRecipeItems = [
        {
          PK: `RECIPE#${recipeId}`,
          SK: `RECIPE#${recipeId}`,
          RecipeId: recipeId,
          UserId: userId,
          Title: "テストレシピ",
          Overview: "テスト概要",
          CreatedAt: "2025-01-01T00:00:00Z",
          EntityType: "RECIPE",
        },
      ];

      mockSend
        .mockResolvedValueOnce({ Items: mockRecipeItems })
        .mockResolvedValueOnce({ Item: null });

      const event = createMockEvent();
      const result = await handler(event);

      expect(result.statusCode).toBe(200);

      const body = JSON.parse(result.body);
      expect(body.user).toMatchObject({
        id: userId,
        name: "Unknown",
        image_url: "",
        description: "",
        email_address: "",
      });
    });

    it("DynamoDBエラー時は500を返す", async () => {
      mockSend.mockRejectedValueOnce(new Error("DynamoDB error"));

      const event = createMockEvent();
      const result = await handler(event);

      expect(result.statusCode).toBe(500);

      const body = JSON.parse(result.body);
      expect(body.error).toBe("Internal server error");
      expect(body.message).toBe("DynamoDB error");
    });

    it("材料と手順が正しい順序でソートされる", async () => {
      const recipeId = "test-recipe-id";
      const userId = "user-1";

      const mockRecipeItems = [
        {
          PK: `RECIPE#${recipeId}`,
          SK: `RECIPE#${recipeId}`,
          RecipeId: recipeId,
          UserId: userId,
          Title: "テストレシピ",
          Overview: "テスト概要",
          CreatedAt: "2025-01-01T00:00:00Z",
          EntityType: "RECIPE",
        },
        {
          PK: `RECIPE#${recipeId}`,
          SK: "INGREDIENT#002#ing-3",
          IngredientId: "ing-3",
          Name: "材料3",
          Amount: "300g",
          OrderIndex: 2,
          EntityType: "INGREDIENT",
        },
        {
          PK: `RECIPE#${recipeId}`,
          SK: "INGREDIENT#000#ing-1",
          IngredientId: "ing-1",
          Name: "材料1",
          Amount: "100g",
          OrderIndex: 0,
          EntityType: "INGREDIENT",
        },
        {
          PK: `RECIPE#${recipeId}`,
          SK: "STEP#003#step-3",
          StepId: "step-3",
          OrderNumber: 3,
          Description: "手順3",
          EntityType: "STEP",
        },
        {
          PK: `RECIPE#${recipeId}`,
          SK: "STEP#001#step-1",
          StepId: "step-1",
          OrderNumber: 1,
          Description: "手順1",
          EntityType: "STEP",
        },
      ];

      mockSend
        .mockResolvedValueOnce({ Items: mockRecipeItems })
        .mockResolvedValueOnce({ Item: { name: "ユーザー" } });

      const event = createMockEvent();
      const result = await handler(event);

      expect(result.statusCode).toBe(200);

      const body = JSON.parse(result.body);

      expect(body.ingredients[0].order_index).toBe(0);
      expect(body.ingredients[1].order_index).toBe(2);

      expect(body.steps[0].order_number).toBe(1);
      expect(body.steps[1].order_number).toBe(3);
    });
  });
});
