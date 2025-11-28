import { S3Client, PutObjectCommand } from "@aws-sdk/client-s3";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";
import { AWS_CONFIG } from "../config/env";

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
