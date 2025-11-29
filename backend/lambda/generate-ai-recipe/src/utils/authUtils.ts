import { APIGatewayProxyEvent } from "aws-lambda";

/**
 * AuthorizationヘッダーからユーザーIDを取得する
 * JWTトークンをデコードしてsubクレームを抽出
 */
export function getUserIdFromAuthHeader(
  event: APIGatewayProxyEvent
): string | null {
  const authHeader =
    event.headers?.Authorization || event.headers?.authorization;
  if (!authHeader) {
    return null;
  }

  const token = authHeader.replace(/^Bearer\s+/i, "");
  try {
    // JWTのペイロード部分（2番目の部分）をデコード
    const payload = token.split(".")[1];
    if (!payload) {
      return null;
    }
    const decoded = JSON.parse(Buffer.from(payload, "base64").toString("utf-8"));
    return decoded.sub || null;
  } catch {
    return null;
  }
}
