import {
  SecretsManagerClient,
  GetSecretValueCommand,
} from "@aws-sdk/client-secrets-manager";
import { SecretValue } from "../types/index";
import { AWS_CONFIG } from "../config/env";

let cachedApiKey: string | null = null;

export async function getGeminiApiKey(): Promise<string> {
  if (cachedApiKey) return cachedApiKey;

  const secretString = await getSecretValue(AWS_CONFIG.GEMINI_API_KEY_ARN());
  const secret: SecretValue = JSON.parse(secretString);

  if (!secret.gemini_api_key) {
    throw new Error("gemini_api_key not found in secret");
  }

  cachedApiKey = secret.gemini_api_key;
  return cachedApiKey;
}

/**
 * AWS Secrets Managerから特定のシークレットを取得
 * @param secretArn シークレットのARN
 * @returns シークレットの値
 */
export async function getSecretValue(secretArn: string): Promise<string> {
  const client = new SecretsManagerClient({
    region: AWS_CONFIG.REGION,
  });
  const command = new GetSecretValueCommand({ SecretId: secretArn });

  const response = await client.send(command);
  if (!response.SecretString) {
    throw new Error("Secret value is empty");
  }

  return response.SecretString;
}
