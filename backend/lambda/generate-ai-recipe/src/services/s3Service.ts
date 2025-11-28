import { S3Client, PutObjectCommand, GetObjectCommand } from "@aws-sdk/client-s3";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";
import { AWS_CONFIG } from "../config/env";
import { Readable } from "stream";

/**
 * S3に画像をアップロード
 */
export async function uploadImageToS3(
  imageData: Buffer,
  fileName: string
): Promise<string> {
  const bucketName = AWS_CONFIG.S3_BUCKET_NAME();
  const environment = AWS_CONFIG.ENVIRONMENT;

  const s3Client = new S3Client({
    region: AWS_CONFIG.REGION,
  });
  const key = `${environment}/recipe-images/${fileName}`;

  await s3Client.send(
    new PutObjectCommand({
      Bucket: bucketName,
      Key: key,
      Body: imageData,
      ContentType: "image/png",
    })
  );

  return `https://${bucketName}.s3.${AWS_CONFIG.REGION}.amazonaws.com/${key}`;
}

/**
 * S3用のPresigned URLを生成
 * @param fileName アップロードするファイル名
 * @returns Presigned URL
 */
export async function generatePresignedUrl(
  fileName: string,
  contentType: string = "image/png"
): Promise<string> {
  const bucketName = AWS_CONFIG.S3_BUCKET_NAME();
  const environment = AWS_CONFIG.ENVIRONMENT;
  const key = `${environment}/recipe-images/${fileName}`;

  const s3Client = new S3Client({
    region: AWS_CONFIG.REGION,
  });

  const command = new PutObjectCommand({
    Bucket: bucketName,
    Key: key,
    ContentType: contentType,
  });

  const presignedUrl = await getSignedUrl(s3Client, command, {
    expiresIn: 600,
  });

  return presignedUrl;
}

/**
 * S3から画像をダウンロード
 * @param fileName ダウンロードするファイル名
 * @returns 画像のBuffer
 */
export async function downloadImageFromS3(fileName: string): Promise<Buffer> {
  const bucketName = AWS_CONFIG.S3_BUCKET_NAME();
  const environment = AWS_CONFIG.ENVIRONMENT;
  const key = `${environment}/recipe-images/${fileName}`;

  const s3Client = new S3Client({
    region: AWS_CONFIG.REGION,
  });

  const command = new GetObjectCommand({
    Bucket: bucketName,
    Key: key,
  });

  const response = await s3Client.send(command);

  if (!response.Body) {
    throw new Error("Failed to download image from S3");
  }

  const stream = response.Body as Readable;
  const chunks: Uint8Array[] = [];

  for await (const chunk of stream) {
    chunks.push(chunk);
  }

  return Buffer.concat(chunks);
}
