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
}));

/**
 * テスト用のAPIGatewayProxyEventを作成する
 */
function createMockEvent(
  overrides: Partial<APIGatewayProxyEvent> = {}
): APIGatewayProxyEvent {
  return {
    httpMethod: "GET",
    path: "/v1/users",
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

describe("GET /users ハンドラー", () => {
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
        "Access-Control-Allow-Methods": "GET,POST,OPTIONS",
      });
    });
  });

  describe("GETリクエスト", () => {
    it("全ユーザーを取得できる（emailパラメータなし）", async () => {
      const mockUsers = [
        {
          UserId: "user-1",
          UserName: "ユーザー1",
          ImageUrl: "https://example.com/1.jpg",
          Description: "説明1",
          EmailAddress: "user1@example.com",
        },
        {
          UserId: "user-2",
          UserName: "ユーザー2",
          ImageUrl: "https://example.com/2.jpg",
          Description: "説明2",
          EmailAddress: "user2@example.com",
        },
      ];

      mockSend.mockResolvedValueOnce({ Items: mockUsers });

      const event = createMockEvent();
      const result = await handler(event);

      expect(result.statusCode).toBe(200);

      const body = JSON.parse(result.body);
      expect(body).toHaveLength(2);
      expect(body[0]).toMatchObject({
        id: "user-1",
        name: "ユーザー1",
        email_address: "user1@example.com",
      });

      // GSI2を使用していることを確認
      const queryCommand = mockSend.mock.calls[0][0];
      expect(queryCommand.params.IndexName).toBe("GSI2");
      expect(queryCommand.params.KeyConditionExpression).toBe("GSI2PK = :pk");
    });

    it("メールアドレスでユーザーを検索できる", async () => {
      const mockUser = {
        UserId: "user-1",
        UserName: "ユーザー1",
        ImageUrl: "https://example.com/1.jpg",
        Description: "説明1",
        EmailAddress: "test@example.com",
      };

      mockSend.mockResolvedValueOnce({ Items: [mockUser] });

      const event = createMockEvent({
        queryStringParameters: { email: "test@example.com" },
      });
      const result = await handler(event);

      expect(result.statusCode).toBe(200);

      const body = JSON.parse(result.body);
      expect(body).toHaveLength(1);
      expect(body[0].email_address).toBe("test@example.com");

      // GSI3を使用していることを確認
      const queryCommand = mockSend.mock.calls[0][0];
      expect(queryCommand.params.IndexName).toBe("GSI3");
      expect(queryCommand.params.ExpressionAttributeValues[":pk"]).toBe(
        "EMAIL#test@example.com"
      );
    });

    it("該当ユーザーがいない場合は空配列を返す", async () => {
      mockSend.mockResolvedValueOnce({ Items: [] });

      const event = createMockEvent({
        queryStringParameters: { email: "notfound@example.com" },
      });
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

    it("ユーザー情報が部分的に欠けている場合も正常に処理する", async () => {
      const mockUser = {
        UserId: "user-1",
        // UserName, ImageUrl, Description が欠けている
        EmailAddress: "test@example.com",
      };

      mockSend.mockResolvedValueOnce({ Items: [mockUser] });

      const event = createMockEvent();
      const result = await handler(event);

      expect(result.statusCode).toBe(200);

      const body = JSON.parse(result.body);
      expect(body[0]).toMatchObject({
        id: "user-1",
        name: "",
        image_url: "",
        description: "",
        email_address: "test@example.com",
      });
    });
  });
});
