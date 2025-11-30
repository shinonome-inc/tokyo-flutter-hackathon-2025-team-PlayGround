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

// aws-jwt-verify をモック（オプショナル認証用）
const mockVerify = jest.fn();
jest.mock("aws-jwt-verify", () => ({
  CognitoJwtVerifier: {
    create: jest.fn(() => ({
      verify: mockVerify,
    })),
  },
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
    process.env.COGNITO_USER_POOL_ID = "test-user-pool-id";
    process.env.COGNITO_CLIENT_ID = "test-client-id";

    // 有効なトークンの場合はユーザーIDを返す
    mockVerify.mockImplementation((token: string) => {
      // トークンからペイロードを取得してsubを返す
      try {
        const payload = token.split(".")[1];
        const decoded = JSON.parse(Buffer.from(payload, "base64").toString("utf-8"));
        if (decoded.sub) {
          return Promise.resolve({ sub: decoded.sub });
        }
      } catch {
        // パースエラーの場合は検証失敗
      }
      return Promise.reject(new Error("Invalid token"));
    });

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
    it("レシピ詳細を正常に取得できる（認証なし）", async () => {
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
          SK: "STEP#001#step-1",
          StepId: "step-1",
          RecipeId: recipeId,
          OrderNumber: 1,
          Description: "手順1の説明",
          EntityType: "STEP",
        },
        {
          PK: `RECIPE#${recipeId}`,
          SK: "COMMENT#2025-01-02T00:00:00Z#comment-1",
          CommentId: "comment-1",
          UserId: "commenter-1",
          UserName: "コメントユーザー",
          Description: "素晴らしいレシピです！",
          CreatedAt: "2025-01-02T00:00:00Z",
          EntityType: "COMMENT",
        },
        {
          PK: `RECIPE#${recipeId}`,
          SK: "LIKE#liker-1",
          UserId: "liker-1",
          CreatedAt: "2025-01-03T00:00:00Z",
          EntityType: "LIKE",
        },
        {
          PK: `RECIPE#${recipeId}`,
          SK: "LIKE#liker-2",
          UserId: "liker-2",
          CreatedAt: "2025-01-04T00:00:00Z",
          EntityType: "LIKE",
        },
      ];

      const mockUser = {
        PK: `USER#${userId}`,
        SK: "PROFILE",
        UserName: "テストユーザー",
        ImageUrl: "https://example.com/user.jpg",
        Description: "ユーザー説明",
        EmailAddress: "test@example.com",
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
        imageUrl: "https://example.com/image.jpg",
        isAiGenerated: false,
        createdAt: "2025-01-01T00:00:00Z",
        user: {
          id: userId,
          name: "テストユーザー",
          imageUrl: "https://example.com/user.jpg",
          description: "ユーザー説明",
          emailAddress: "test@example.com",
        },
      });

      // 材料のチェック
      expect(body.ingredients).toHaveLength(1);
      expect(body.ingredients[0]).toMatchObject({
        id: "ing-1",
        name: "材料1",
        amount: "100g",
      });

      // 手順のチェック
      expect(body.steps).toHaveLength(1);
      expect(body.steps[0]).toMatchObject({
        orderNumber: 1,
        description: "手順1の説明",
      });

      // コメントのチェック
      expect(body.comments).toHaveLength(1);
      expect(body.comments[0]).toMatchObject({
        id: "comment-1",
        userId: "commenter-1",
        userName: "コメントユーザー",
        description: "素晴らしいレシピです！",
        createdAt: "2025-01-02T00:00:00Z",
      });

      // いいね関連のチェック（認証なし）
      expect(body.likeCount).toBe(2);
      expect(body.isLikedByMe).toBe(false);
    });

    it("認証ありの場合、isLikedByMeが正しく判定される", async () => {
      const recipeId = "test-recipe-id";
      const userId = "user-1";
      const currentUserId = "liker-1"; // いいね済みユーザー

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
          SK: `LIKE#${currentUserId}`,
          UserId: currentUserId,
          CreatedAt: "2025-01-03T00:00:00Z",
          EntityType: "LIKE",
        },
      ];

      const mockUser = {
        PK: `USER#${userId}`,
        SK: "PROFILE",
        UserName: "テストユーザー",
      };

      mockSend
        .mockResolvedValueOnce({ Items: mockRecipeItems })
        .mockResolvedValueOnce({ Item: mockUser });

      const event = createMockEvent({
        headers: {
          Authorization: `Bearer ${createMockJwt(currentUserId)}`,
        },
      });
      const result = await handler(event);

      expect(result.statusCode).toBe(200);

      const body = JSON.parse(result.body);
      expect(body.isLikedByMe).toBe(true);
      expect(body.likeCount).toBe(1);
    });

    it("認証ありでいいねしていない場合、isLikedByMeがfalseになる", async () => {
      const recipeId = "test-recipe-id";
      const userId = "user-1";
      const currentUserId = "not-liked-user";

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
          SK: "LIKE#other-user",
          UserId: "other-user",
          CreatedAt: "2025-01-03T00:00:00Z",
          EntityType: "LIKE",
        },
      ];

      const mockUser = {
        PK: `USER#${userId}`,
        SK: "PROFILE",
        UserName: "テストユーザー",
      };

      mockSend
        .mockResolvedValueOnce({ Items: mockRecipeItems })
        .mockResolvedValueOnce({ Item: mockUser });

      const event = createMockEvent({
        headers: {
          Authorization: `Bearer ${createMockJwt(currentUserId)}`,
        },
      });
      const result = await handler(event);

      expect(result.statusCode).toBe(200);

      const body = JSON.parse(result.body);
      expect(body.isLikedByMe).toBe(false);
      expect(body.likeCount).toBe(1);
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
        imageUrl: "",
        description: "",
        emailAddress: "",
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
        .mockResolvedValueOnce({ Item: { UserName: "ユーザー" } });

      const event = createMockEvent();
      const result = await handler(event);

      expect(result.statusCode).toBe(200);

      const body = JSON.parse(result.body);

      // 材料がOrderIndexでソートされている
      expect(body.ingredients[0].name).toBe("材料1");
      expect(body.ingredients[1].name).toBe("材料3");

      // 手順がOrderNumberでソートされている
      expect(body.steps[0].orderNumber).toBe(1);
      expect(body.steps[1].orderNumber).toBe(3);
    });

    it("コメントが作成日時順でソートされる", async () => {
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
          SK: "COMMENT#2025-01-03T00:00:00Z#comment-2",
          CommentId: "comment-2",
          UserId: "user-2",
          UserName: "ユーザー2",
          Description: "後のコメント",
          CreatedAt: "2025-01-03T00:00:00Z",
          EntityType: "COMMENT",
        },
        {
          PK: `RECIPE#${recipeId}`,
          SK: "COMMENT#2025-01-01T00:00:00Z#comment-1",
          CommentId: "comment-1",
          UserId: "user-1",
          UserName: "ユーザー1",
          Description: "先のコメント",
          CreatedAt: "2025-01-01T00:00:00Z",
          EntityType: "COMMENT",
        },
      ];

      mockSend
        .mockResolvedValueOnce({ Items: mockRecipeItems })
        .mockResolvedValueOnce({ Item: { UserName: "ユーザー" } });

      const event = createMockEvent();
      const result = await handler(event);

      expect(result.statusCode).toBe(200);

      const body = JSON.parse(result.body);

      // コメントが作成日時順でソートされている
      expect(body.comments[0].description).toBe("先のコメント");
      expect(body.comments[1].description).toBe("後のコメント");
    });
  });
});
