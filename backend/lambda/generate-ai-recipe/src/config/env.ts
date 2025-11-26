/**
 * 環境変数を取得
 */
export function getEnv(key: string, defaultValue?: string): string {
  const value = process.env[key];

  if (!value && !defaultValue) {
    throw new Error(`${key} environment variable is not set`);
  }

  return value || defaultValue!;
}

/**
 * AWS関連の環境変数
 */
export const AWS_CONFIG = {
  REGION: process.env.AWS_REGION || "ap-northeast-1",
  GEMINI_API_KEY_ARN: () => getEnv("GEMINI_API_KEY_ARN"),
  GCP_SERVICE_ACCOUNT_KEY_ARN: () => getEnv("GCP_SERVICE_ACCOUNT_KEY_ARN"),
  S3_BUCKET_NAME: () => getEnv("S3_BUCKET_NAME"),
  ENVIRONMENT: process.env.ENVIRONMENT || "dev",
};

/**
 * GCP関連の環境変数
 */
export const GCP_CONFIG = {
  PROJECT_ID: process.env.GCP_PROJECT_ID || "genkaimeshi-recipe",
  IMAGEN_LOCATION: "us-central1",
};
