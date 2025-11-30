import { APIGatewayProxyEvent } from "aws-lambda";
import { getUserIdFromAuthHeader } from "../src/utils/authUtils";

/**
 * テスト用のJWTトークンを生成する
 * 実際の署名は行わず、ペイロードのみをBase64エンコード
 */
function createMockJwt(payload: object): string {
  const header = Buffer.from(JSON.stringify({ alg: "HS256", typ: "JWT" })).toString("base64url");
  const payloadEncoded = Buffer.from(JSON.stringify(payload)).toString("base64url");
  const signature = "mock-signature";
  return `${header}.${payloadEncoded}.${signature}`;
}

/**
 * テスト用のAPIGatewayProxyEventを生成する
 */
function createMockEvent(authHeader?: string): APIGatewayProxyEvent {
  return {
    headers: authHeader ? { Authorization: authHeader } : {},
    body: null,
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

/**
 * 注意: 以下のテストは非推奨の getUserIdFromAuthHeader 関数をテストしています。
 * この関数はJWTトークンの署名を検証しません。
 * 新しい verifyAndGetUserId 関数は、aws-jwt-verify を使用して
 * CognitoのJWKS（JSON Web Key Set）から公開鍵を取得し、署名を検証するため、
 * ユニットテストではモックが必要になります。
 */
describe("authUtils", () => {
  describe("getUserIdFromAuthHeader (deprecated)", () => {
    it("有効なJWTトークンからユーザーIDを取得できる", () => {
      const userId = "user-123-abc";
      const token = createMockJwt({ sub: userId, exp: 9999999999 });
      const event = createMockEvent(`Bearer ${token}`);

      const result = getUserIdFromAuthHeader(event);

      expect(result).toBe(userId);
    });

    it("Bearerプレフィックスなしのトークンでも動作する", () => {
      const userId = "user-456-def";
      const token = createMockJwt({ sub: userId });
      const event = createMockEvent(token);

      const result = getUserIdFromAuthHeader(event);

      expect(result).toBe(userId);
    });

    it("小文字のauthorizationヘッダーでも動作する", () => {
      const userId = "user-789-ghi";
      const token = createMockJwt({ sub: userId });
      const event = createMockEvent();
      event.headers = { authorization: `Bearer ${token}` };

      const result = getUserIdFromAuthHeader(event);

      expect(result).toBe(userId);
    });

    it("Authorizationヘッダーがない場合はnullを返す", () => {
      const event = createMockEvent();

      const result = getUserIdFromAuthHeader(event);

      expect(result).toBeNull();
    });

    it("空のAuthorizationヘッダーの場合はnullを返す", () => {
      const event = createMockEvent("");

      const result = getUserIdFromAuthHeader(event);

      expect(result).toBeNull();
    });

    it("subクレームがないトークンの場合はnullを返す", () => {
      const token = createMockJwt({ exp: 9999999999, name: "test" });
      const event = createMockEvent(`Bearer ${token}`);

      const result = getUserIdFromAuthHeader(event);

      expect(result).toBeNull();
    });

    it("不正な形式のトークンの場合はnullを返す", () => {
      const event = createMockEvent("Bearer invalid-token");

      const result = getUserIdFromAuthHeader(event);

      expect(result).toBeNull();
    });

    it("ペイロード部分がないトークンの場合はnullを返す", () => {
      const event = createMockEvent("Bearer header-only");

      const result = getUserIdFromAuthHeader(event);

      expect(result).toBeNull();
    });

    it("Base64デコードに失敗するトークンの場合はnullを返す", () => {
      const event = createMockEvent("Bearer header.!!!invalid-base64!!!.signature");

      const result = getUserIdFromAuthHeader(event);

      expect(result).toBeNull();
    });

    it("JSONパースに失敗するトークンの場合はnullを返す", () => {
      const invalidPayload = Buffer.from("not-json").toString("base64url");
      const event = createMockEvent(`Bearer header.${invalidPayload}.signature`);

      const result = getUserIdFromAuthHeader(event);

      expect(result).toBeNull();
    });
  });
});

/**
 * verifyAndGetUserId のテストは、実際のCognito User Poolに対する
 * 統合テストまたはaws-jwt-verifyをモックしたテストとして実装する必要があります。
 *
 * モックを使用したテスト例:
 *
 * jest.mock('aws-jwt-verify', () => ({
 *   CognitoJwtVerifier: {
 *     create: jest.fn().mockReturnValue({
 *       verify: jest.fn().mockResolvedValue({ sub: 'test-user-id' })
 *     })
 *   }
 * }));
 *
 * describe('verifyAndGetUserId', () => {
 *   it('正常に検証されたトークンからユーザーIDを取得できる', async () => {
 *     const event = createMockEvent('Bearer valid-token');
 *     const result = await verifyAndGetUserId(event);
 *     expect(result.isValid).toBe(true);
 *     expect(result.userId).toBe('test-user-id');
 *   });
 * });
 */
