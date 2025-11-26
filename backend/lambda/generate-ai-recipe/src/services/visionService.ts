import { ImageAnnotatorClient } from "@google-cloud/vision";
import { getSecretValue } from "./secretsManagerService";
import { AWS_CONFIG } from "../config/env";
import { extractIngredientLabels, extractTexts } from "../utils/annotationUtils";

/**
 * Cloud Vision API クライアントを取得する
 */
export async function getVisionClient(): Promise<ImageAnnotatorClient> {
  try {
    const serviceAccountKey = await getSecretValue(
      AWS_CONFIG.GCP_SERVICE_ACCOUNT_KEY_ARN()
    );
    return new ImageAnnotatorClient({
      credentials: JSON.parse(serviceAccountKey),
    });
  } catch (error) {
    throw new Error("GCPサービスアカウントキーの取得に失敗しました: " + error);
  }
}

/**
 * Cloud Vision APIを用いて画像からラベルの物体を検出し、指定したキーワードリストにマッチするものだけ返す
 * @param imageBase64 Base64エンコードされた画像データ
 * @param labels フィルタリングに使用するキーワードの配列
 * @returns 検出されたラベルのリスト（キーワードに一致したもの）
 */
export async function detectLabeledObjectTextsFromImage(
  imageBase64: string,
  labels: string[]
): Promise<string[]> {
  const client: ImageAnnotatorClient = await getVisionClient();
  try {
    const [labelResult] = await client.labelDetection(
      Buffer.from(imageBase64, "base64")
    );

    return extractIngredientLabels(labelResult.labelAnnotations, labels);
  } catch (error) {
    console.error("ラベル検出中にエラーが発生:", error);
    return [];
  }
}

/**
 * Cloud Vision APIを用いて画像内のテキストを検出する
 * @param imageBase64 Base64エンコードされた画像データ
 * @returns 検出されたテキストのリスト
 */
export async function detectTextsFromImage(
  imageBase64: string
): Promise<string[]> {
  const client = await getVisionClient();
  try {
    const [textResult] = await client.textDetection(
      Buffer.from(imageBase64, "base64")
    );
    return extractTexts(textResult.textAnnotations);
  } catch (error) {
    console.error("画像テキスト検出中にエラーが発生:", error);
    return [];
  }
}