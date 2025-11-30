import { APIGatewayProxyEvent } from "aws-lambda";

// aws-jwt-verify をモック
const mockVerify = jest.fn();
jest.mock("aws-jwt-verify", () => ({
  CognitoJwtVerifier: {
    create: jest.fn(() => ({
      verify: mockVerify,
    })),
  },
}));

// モックの設定
jest.mock("uuid", () => ({
  v4: jest.fn(() => "mock-uuid-1234"),
}));
jest.mock("../src/services/secretsManagerService");
jest.mock("../src/services/geminiService");
jest.mock("../src/services/imagenService");
jest.mock("../src/services/s3Service");
jest.mock("../src/services/ingredientDetectionService");

// DynamoDB モック
const mockSend = jest.fn().mockResolvedValue({});
jest.mock("@aws-sdk/client-dynamodb", () => ({
  DynamoDBClient: jest.fn(() => ({})),
}));
jest.mock("@aws-sdk/lib-dynamodb", () => ({
  DynamoDBDocumentClient: {
    from: jest.fn(() => ({
      send: mockSend,
    })),
  },
  TransactWriteCommand: jest.fn(),
}));

import { handler } from "../src/index";
import { getGeminiApiKey } from "../src/services/secretsManagerService";
import { generateRecipeText } from "../src/services/geminiService";
import { generateRecipeImage } from "../src/services/imagenService";
import {
  uploadImageToS3,
  downloadImageFromS3,
  generatePresignedUrl,
} from "../src/services/s3Service";
import { enrichRecipeContextWithImageIngredients } from "../src/services/ingredientDetectionService";

/**
 * テスト用のJWTトークンを生成する
 */
function createMockJwt(payload: object): string {
  const header = Buffer.from(
    JSON.stringify({ alg: "HS256", typ: "JWT" })
  ).toString("base64url");
  const payloadEncoded = Buffer.from(JSON.stringify(payload)).toString(
    "base64url"
  );
  const signature = "mock-signature";
  return `${header}.${payloadEncoded}.${signature}`;
}

/**
 * テスト用のAPIGatewayProxyEventを生成する
 */
function createMockEvent(
  body: object | null,
  authHeader?: string
): APIGatewayProxyEvent {
  return {
    headers: authHeader ? { Authorization: authHeader } : {},
    body: body ? JSON.stringify(body) : null,
    httpMethod: "POST",
    isBase64Encoded: false,
    path: "/v1/generate-recipe",
    pathParameters: null,
    queryStringParameters: null,
    multiValueQueryStringParameters: null,
    stageVariables: null,
    requestContext: {} as APIGatewayProxyEvent["requestContext"],
    resource: "",
    multiValueHeaders: {},
  };
}

describe("generate-ai-recipe handler", () => {
  const mockUserId = "user-123";
  const mockToken = createMockJwt({ sub: mockUserId });
  const mockAuthHeader = `Bearer ${mockToken}`;

  beforeEach(() => {
    jest.clearAllMocks();
    mockSend.mockResolvedValue({});
    process.env.COGNITO_USER_POOL_ID = "test-user-pool-id";
    process.env.COGNITO_CLIENT_ID = "test-client-id";

    // 有効なトークンの場合はユーザーIDを返す
    mockVerify.mockImplementation((token: string) => {
      // トークンからペイロードを取得してsubを返す
      try {
        const parts = token.split(".");
        if (parts.length !== 3) {
          return Promise.reject(new Error("Invalid token format"));
        }
        const payload = parts[1];
        const decoded = JSON.parse(Buffer.from(payload, "base64url").toString("utf-8"));
        if (decoded.sub) {
          return Promise.resolve({ sub: decoded.sub });
        }
      } catch {
        // パースエラーの場合は検証失敗
      }
      return Promise.reject(new Error("Invalid token"));
    });
  });

  describe("認証", () => {
    it("Authorizationヘッダーがない場合は401を返す", async () => {
      const event = createMockEvent({ prompt: "テストプロンプト" });

      const result = await handler(event);

      expect(result.statusCode).toBe(401);
      expect(JSON.parse(result.body)).toMatchObject({
        error: "認証が必要です",
      });
    });

    it("無効なトークンの場合は401を返す", async () => {
      const event = createMockEvent(
        { prompt: "テストプロンプト" },
        "Bearer invalid-token"
      );

      const result = await handler(event);

      expect(result.statusCode).toBe(401);
    });
  });

  describe("バリデーション", () => {
    it("リクエストボディがない場合は400を返す", async () => {
      const event = createMockEvent(null, mockAuthHeader);

      const result = await handler(event);

      expect(result.statusCode).toBe(400);
      expect(JSON.parse(result.body)).toEqual({
        error: "Request body is required",
      });
    });

    it("promptがない場合は400を返す", async () => {
      const event = createMockEvent({}, mockAuthHeader);

      const result = await handler(event);

      expect(result.statusCode).toBe(400);
      expect(JSON.parse(result.body)).toEqual({
        error: "prompt is required and must be a string",
      });
    });

    it("promptが文字列でない場合は400を返す", async () => {
      const event = createMockEvent({ prompt: 123 }, mockAuthHeader);

      const result = await handler(event);

      expect(result.statusCode).toBe(400);
      expect(JSON.parse(result.body)).toEqual({
        error: "prompt is required and must be a string",
      });
    });
  });

  describe("CORS preflight", () => {
    it("OPTIONSリクエストの場合は200を返す", async () => {
      const event = createMockEvent(null, mockAuthHeader);
      event.httpMethod = "OPTIONS";

      const result = await handler(event);

      expect(result.statusCode).toBe(200);
      expect(result.headers).toMatchObject({
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST,OPTIONS",
      });
    });
  });

  describe("Presigned URL生成モード", () => {
    it("requiresImageUpload=trueの場合はpresigned URLを返す", async () => {
      const mockUploadUrl = "https://s3.amazonaws.com/presigned-url";
      (generatePresignedUrl as jest.Mock).mockResolvedValue(mockUploadUrl);

      const event = createMockEvent(
        {
          prompt: "テストプロンプト",
          requiresImageUpload: true,
        },
        mockAuthHeader
      );

      const result = await handler(event);

      expect(result.statusCode).toBe(200);
      const body = JSON.parse(result.body);
      expect(body.uploadUrl).toBe(mockUploadUrl);
      expect(body.imageS3Key).toMatch(/\.png$/);
      expect(generatePresignedUrl).toHaveBeenCalled();
    });

    it("presigned URL生成に失敗した場合は500を返す", async () => {
      (generatePresignedUrl as jest.Mock).mockRejectedValue(
        new Error("S3 error")
      );

      const event = createMockEvent(
        {
          prompt: "テストプロンプト",
          requiresImageUpload: true,
        },
        mockAuthHeader
      );

      const result = await handler(event);

      expect(result.statusCode).toBe(500);
      expect(JSON.parse(result.body)).toMatchObject({
        error: "Failed to generate presigned URL",
      });
    });
  });

  describe("レシピ生成モード", () => {
    beforeEach(() => {
      (getGeminiApiKey as jest.Mock).mockResolvedValue("mock-api-key");
      (generateRecipeText as jest.Mock).mockResolvedValue({
        title: "テストレシピ",
        overview: "テスト概要",
        notes: "テストノート",
        ingredients: [{ name: "材料1", amount: "100g" }],
        steps: ["手順1", "手順2"],
      });
      (generateRecipeImage as jest.Mock).mockResolvedValue(
        Buffer.from("mock-image")
      );
      (uploadImageToS3 as jest.Mock).mockResolvedValue(
        "https://s3.amazonaws.com/image.png"
      );
    });

    it("画像なしでレシピを生成できる", async () => {
      const event = createMockEvent(
        { prompt: "カレーのレシピを提案して" },
        mockAuthHeader
      );

      const result = await handler(event);

      expect(result.statusCode).toBe(200);
      const body = JSON.parse(result.body);
      expect(body.title).toBe("テストレシピ");
      expect(body.overview).toBe("テスト概要");
      expect(body.isAiGenerated).toBe(true);
      expect(body.user.id).toBe(mockUserId);
      expect(body.ingredients).toHaveLength(1);
      expect(body.steps).toHaveLength(2);
    });

    it("画像付きでレシピを生成できる", async () => {
      (downloadImageFromS3 as jest.Mock).mockResolvedValue(
        Buffer.from("mock-image")
      );
      (enrichRecipeContextWithImageIngredients as jest.Mock).mockResolvedValue(
        "enriched prompt with ingredients"
      );

      const event = createMockEvent(
        {
          prompt: "この食材で作れるレシピを提案して",
          imageS3Key: "test-image.png",
        },
        mockAuthHeader
      );

      const result = await handler(event);

      expect(result.statusCode).toBe(200);
      expect(downloadImageFromS3).toHaveBeenCalledWith("test-image.png");
      expect(enrichRecipeContextWithImageIngredients).toHaveBeenCalled();
    });

    it("レシピ生成に失敗した場合は500を返す", async () => {
      (generateRecipeText as jest.Mock).mockRejectedValue(
        new Error("Gemini API error")
      );

      const event = createMockEvent(
        { prompt: "カレーのレシピを提案して" },
        mockAuthHeader
      );

      const result = await handler(event);

      expect(result.statusCode).toBe(500);
      expect(JSON.parse(result.body)).toMatchObject({
        error: "Internal server error",
      });
    });
  });
});
