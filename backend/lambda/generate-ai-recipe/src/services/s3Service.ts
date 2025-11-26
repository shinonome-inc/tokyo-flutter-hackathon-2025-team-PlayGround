import { S3Client, PutObjectCommand } from "@aws-sdk/client-s3";
import { AWS_CONFIG } from "../config/env";

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
