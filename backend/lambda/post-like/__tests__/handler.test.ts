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
}));

/**
 * テスト用のAPIGatewayProxyEventを作成する
 */
function createMockEvent(
  overrides: Partial<APIGatewayProxyEvent> = {}
): APIGatewayProxyEvent {
  return {
    httpMethod: "POST",
    path: "/v1/recipes/test-recipe-id/likes",
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
    }),
    isBase64Encoded: false,
    ...overrides,
  };
}

describe("POST /recipes/{recipeId}/likes ハンドラー", () => {
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
        is_liked: true,
      });
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

    it("user_idがない場合は400を返す", async () => {
      const event = createMockEvent({
        body: JSON.stringify({}),
      });

      const result = await handler(event);

      expect(result.statusCode).toBe(400);

      const body = JSON.parse(result.body);
      expect(body.message).toBe("user_idは必須です");
    });

    it("DynamoDBエラー時は500を返す", async () => {
      mockSend.mockRejectedValueOnce(new Error("DynamoDB error"));

      const event = createMockEvent();
      const result = await handler(event);

      expect(result.statusCode).toBe(500);

      const body = JSON.parse(result.body);
      expect(body.message).toContain("サーバーエラーが発生しました");
    });

    it("DynamoDBに正しいパラメータで保存される", async () => {
      mockSend.mockResolvedValueOnce({});

      const event = createMockEvent();
      await handler(event);

      expect(mockSend).toHaveBeenCalledTimes(1);
      const putCommand = mockSend.mock.calls[0][0];
      expect(putCommand.type).toBe("Put");
      expect(putCommand.params.TableName).toBe("test-table");
      expect(putCommand.params.Item.PK).toBe("RECIPE#test-recipe-id");
      expect(putCommand.params.Item.SK).toBe("LIKE#user-1");
      expect(putCommand.params.Item.EntityType).toBe("LIKE");
      expect(putCommand.params.Item.GSI1PK).toBe("USER#user-1");
      expect(putCommand.params.Item.GSI1SK).toMatch(/^LIKE#/);
    });
  });
});
