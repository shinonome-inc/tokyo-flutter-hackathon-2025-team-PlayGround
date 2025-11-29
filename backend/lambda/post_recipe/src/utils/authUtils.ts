import { APIGatewayProxyEvent } from "aws-lambda";
import { CognitoJwtVerifier } from "aws-jwt-verify";

// JWT Verifier のシングルトンインスタンス（遅延初期化）
let verifier: ReturnType<typeof CognitoJwtVerifier.create> | null = null;
let verifierConfig: { userPoolId: string; clientId: string } | null = null;

/**
 * JWT Verifier を取得する（遅延初期化）
 * 環境変数は関数呼び出し時に評価される（テストでの動的設定に対応）
 */
function getVerifier(): ReturnType<typeof CognitoJwtVerifier.create> {
  const userPoolId = process.env.COGNITO_USER_POOL_ID || "";
  const clientId = process.env.COGNITO_CLIENT_ID || "";

  // 環境変数が変更された場合はverifierを再作成
  if (verifier && verifierConfig &&
      verifierConfig.userPoolId === userPoolId &&
      verifierConfig.clientId === clientId) {
    return verifier;
  }

  if (!userPoolId || !clientId) {
    throw new Error(
      "COGNITO_USER_POOL_ID and COGNITO_CLIENT_ID environment variables must be set"
    );
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
 * JWT検証の結果
 */
export interface JwtVerificationResult {
  isValid: boolean;
  userId: string | null;
  error?: string;
}

/**
 * AuthorizationヘッダーからJWTトークンを検証し、ユーザーIDを取得する
 * aws-jwt-verifyを使用してCognitoトークンの署名を検証
 */
export async function verifyAndGetUserId(
  event: APIGatewayProxyEvent
): Promise<JwtVerificationResult> {
  const authHeader =
    event.headers?.Authorization || event.headers?.authorization;
  if (!authHeader) {
    return { isValid: false, userId: null, error: "Authorization header is missing" };
  }

  const token = authHeader.replace(/^Bearer\s+/i, "");
  if (!token) {
    return { isValid: false, userId: null, error: "Token is empty" };
  }

  try {
    const payload = await getVerifier().verify(token);
    const userId = payload.sub;
    if (!userId) {
      return { isValid: false, userId: null, error: "Token does not contain sub claim" };
    }
    return { isValid: true, userId };
  } catch (error) {
    console.error("JWT verification failed:", error);
    return {
      isValid: false,
      userId: null,
      error: error instanceof Error ? error.message : "Unknown verification error",
    };
  }
}
