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
  DeleteCommand: jest.fn((params) => ({ type: "Delete", params })),
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
    path: "/v1/recipes/test-recipe-id/likes",
    headers: {
      Authorization: `Bearer ${createMockJwt("user-1")}`,
    },
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

describe("POST/DELETE /recipes/{recipeId}/likes ハンドラー", () => {
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
        "Access-Control-Allow-Methods": "POST,DELETE,OPTIONS",
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
    it("いいねを正常に作成できる", async () => {
      mockSend.mockResolvedValueOnce({});

      const event = createMockEvent();
      const result = await handler(event);

      expect(result.statusCode).toBe(201);
      expect(result.headers).toMatchObject({
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
      });

      const body = JSON.parse(result.body);
      expect(body).toEqual({
        isLiked: true,
      });
    });

    it("recipeIdがない場合は400を返す", async () => {
      const event = createMockEvent({ pathParameters: null });

      const result = await handler(event);

      expect(result.statusCode).toBe(400);

      const body = JSON.parse(result.body);
      expect(body.message).toBe("recipeIdが指定されていません");
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
      expect(putCommand.params.Item.PK).toBe("RECIPE#test-recipe-id");
      expect(putCommand.params.Item.SK).toBe("LIKE#user-1");
      expect(putCommand.params.Item.UserId).toBe("user-1");
      expect(putCommand.params.Item.EntityType).toBe("LIKE");
      expect(putCommand.params.Item.GSI1PK).toBe("USER#user-1");
      expect(putCommand.params.Item.GSI1SK).toMatch(/^LIKE#/);
    });
  });

  describe("DELETEリクエスト", () => {
    it("いいねを正常に削除できる", async () => {
      mockSend.mockResolvedValueOnce({});

      const event = createMockEvent({ httpMethod: "DELETE" });
      const result = await handler(event);

      expect(result.statusCode).toBe(204);
      expect(result.body).toBe("");
    });

    it("recipeIdがない場合は400を返す", async () => {
      const event = createMockEvent({
        httpMethod: "DELETE",
        pathParameters: null,
      });

      const result = await handler(event);

      expect(result.statusCode).toBe(400);

      const body = JSON.parse(result.body);
      expect(body.message).toBe("recipeIdが指定されていません");
    });

    it("DynamoDBに正しいパラメータで削除される（userIdはJWTのsubを使用）", async () => {
      mockSend.mockResolvedValueOnce({});

      const event = createMockEvent({ httpMethod: "DELETE" });
      await handler(event);

      expect(mockSend).toHaveBeenCalledTimes(1);
      const deleteCommand = mockSend.mock.calls[0][0];
      expect(deleteCommand.type).toBe("Delete");
      expect(deleteCommand.params.TableName).toBe("test-table");
      expect(deleteCommand.params.Key.PK).toBe("RECIPE#test-recipe-id");
      expect(deleteCommand.params.Key.SK).toBe("LIKE#user-1");
    });

    it("DynamoDBエラー時は500を返す", async () => {
      mockSend.mockRejectedValueOnce(new Error("DynamoDB error"));

      const event = createMockEvent({ httpMethod: "DELETE" });
      const result = await handler(event);

      expect(result.statusCode).toBe(500);

      const body = JSON.parse(result.body);
      expect(body.message).toContain("サーバーエラーが発生しました");
    });
  });
});
