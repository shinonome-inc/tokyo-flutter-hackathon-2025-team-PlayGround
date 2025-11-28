import { APIGatewayProxyEvent, APIGatewayProxyResult } from "aws-lambda";
import { v4 as uuidv4 } from "uuid";
import { generatePresignedUrl } from "./services/s3Service";

/**
 * Presigned URLを生成するハンドラ
 */
export const handler = async (
  event: APIGatewayProxyEvent
): Promise<APIGatewayProxyResult> => {
  try {
    const fileName = `${uuidv4()}.png`;
    const presignedUrl = await generatePresignedUrl(fileName);

    return {
      statusCode: 200,
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        upload_url: presignedUrl,
        file_name: fileName,
      }),
    };
  } catch (error) {
    console.error("Error generating Presigned URL:", error);
    return {
      statusCode: 500,
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        error: "Failed to generate Presigned URL",
        message: error instanceof Error ? error.message : "Unknown error",
      }),
    };
  }
};
