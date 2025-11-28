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
  S3_BUCKET_NAME: () => getEnv("S3_BUCKET_NAME"),
  ENVIRONMENT: process.env.ENVIRONMENT || "dev",
};
