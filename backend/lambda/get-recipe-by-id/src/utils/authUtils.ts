import { APIGatewayProxyEvent } from "aws-lambda";
import { CognitoJwtVerifier } from "aws-jwt-verify";

// JWT Verifier のシングルトンインスタンス（遅延初期化）
let verifier: ReturnType<typeof CognitoJwtVerifier.create> | null = null;
let verifierConfig: { userPoolId: string; clientId: string } | null = null;

/**
 * JWT Verifier を取得する（遅延初期化）
 * 環境変数は関数呼び出し時に評価される（テストでの動的設定に対応）
 */
function getVerifier(): ReturnType<typeof CognitoJwtVerifier.create> | null {
  const userPoolId = process.env.COGNITO_USER_POOL_ID || "";
  const clientId = process.env.COGNITO_CLIENT_ID || "";

  // 環境変数が変更された場合はverifierを再作成
  if (verifier && verifierConfig &&
      verifierConfig.userPoolId === userPoolId &&
      verifierConfig.clientId === clientId) {
    return verifier;
  }

  if (!userPoolId || !clientId) {
    // オプショナル認証の場合、環境変数がなくてもエラーにしない
    console.warn(
      "COGNITO_USER_POOL_ID or COGNITO_CLIENT_ID not set. JWT verification will be skipped."
    );
    return null;
  }

  verifier = CognitoJwtVerifier.create({
    userPoolId,
    tokenUse: "id",
    clientId,
  });
  verifierConfig = { userPoolId, clientId };

  return verifier;
}

/**
 * AuthorizationヘッダーからJWTトークンを検証し、ユーザーIDを取得する（オプショナル）
 * Authorizationヘッダーがない場合はnullを返す（エラーではない）
 * aws-jwt-verifyを使用してCognitoトークンの署名を検証
 */
export async function verifyAndGetUserIdOptional(
  event: APIGatewayProxyEvent
): Promise<string | null> {
  const authHeader =
    event.headers?.Authorization || event.headers?.authorization;
  if (!authHeader) {
    // オプショナル認証: ヘッダーがなければnullを返す（エラーではない）
    return null;
  }

  const token = authHeader.replace(/^Bearer\s+/i, "");
  if (!token) {
    return null;
  }

  const jwtVerifier = getVerifier();
  if (!jwtVerifier) {
    // Verifierが設定されていない場合は、検証なしでユーザーIDを取得（後方互換性）
    try {
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

  try {
    const payload = await jwtVerifier.verify(token);
    return payload.sub || null;
  } catch (error) {
    console.error("JWT verification failed:", error);
    // オプショナル認証: 検証に失敗してもnullを返す（401エラーではない）
    return null;
  }
}
