import {
  SecretsManagerClient,
  GetSecretValueCommand,
} from "@aws-sdk/client-secrets-manager";
import { SecretValue } from "../types/index";
import { AWS_CONFIG } from "../config/env";

let cachedApiKey: string | null = null;
let cachedGcpCredentials: any = null;

/**
 * AWS Secrets ManagerからGemini APIキーを取得
 */
export async function getGeminiApiKey(): Promise<string> {
  if (cachedApiKey) {
    return cachedApiKey;
  }

  const secretArn = AWS_CONFIG.GEMINI_API_KEY_ARN();

  const client = new SecretsManagerClient({
    region: AWS_CONFIG.REGION,
  });
  const command = new GetSecretValueCommand({ SecretId: secretArn });

  const response = await client.send(command);
  if (!response.SecretString) {
    throw new Error("Secret value is empty");
  }

  const secret: SecretValue = JSON.parse(response.SecretString);
  if (!secret.gemini_api_key) {
    throw new Error("gemini_api_key not found in secret");
  }

  cachedApiKey = secret.gemini_api_key;
  return cachedApiKey;
}

/**
 * AWS Secrets ManagerからGCPサービスアカウントキーを取得
 */
export async function getGcpServiceAccountKey(): Promise<any> {
  if (cachedGcpCredentials) {
    return cachedGcpCredentials;
  }

  const secretArn = AWS_CONFIG.GCP_SERVICE_ACCOUNT_KEY_ARN();

  const client = new SecretsManagerClient({
    region: AWS_CONFIG.REGION,
  });
  const command = new GetSecretValueCommand({ SecretId: secretArn });

  const response = await client.send(command);
  if (!response.SecretString) {
    throw new Error("GCP service account key secret value is empty");
  }

  cachedGcpCredentials = JSON.parse(response.SecretString);
  return cachedGcpCredentials;
}
