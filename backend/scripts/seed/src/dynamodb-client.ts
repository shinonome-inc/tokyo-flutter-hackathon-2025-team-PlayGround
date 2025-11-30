import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import {
  DynamoDBDocumentClient,
  ScanCommand,
  BatchWriteCommand,
  PutCommand,
} from "@aws-sdk/lib-dynamodb";
import { TABLE_NAME, AWS_REGION } from "./config.js";

const client = new DynamoDBClient({ region: AWS_REGION });
export const docClient = DynamoDBDocumentClient.from(client);

/**
 * テーブル内の全データを削除
 */
export async function deleteAllItems(): Promise<number> {
  console.log(`📋 テーブル "${TABLE_NAME}" の全データを削除中...`);

  let deletedCount = 0;
  let lastEvaluatedKey: Record<string, unknown> | undefined;

  do {
    // スキャンして全アイテムを取得
    const scanResult = await docClient.send(
      new ScanCommand({
        TableName: TABLE_NAME,
        ProjectionExpression: "PK, SK",
        ExclusiveStartKey: lastEvaluatedKey,
      })
    );

    const items = scanResult.Items || [];

    if (items.length === 0) {
      break;
    }

    // 25件ずつバッチ削除（DynamoDBの制限）
    for (let i = 0; i < items.length; i += 25) {
      const batch = items.slice(i, i + 25);
      const deleteRequests = batch.map((item) => ({
        DeleteRequest: {
          Key: {
            PK: item.PK,
            SK: item.SK,
          },
        },
      }));

      await docClient.send(
        new BatchWriteCommand({
          RequestItems: {
            [TABLE_NAME]: deleteRequests,
          },
        })
      );

      deletedCount += batch.length;
      console.log(`  🗑️  ${deletedCount} 件削除完了`);
    }

    lastEvaluatedKey = scanResult.LastEvaluatedKey;
  } while (lastEvaluatedKey);

  console.log(`✅ 全 ${deletedCount} 件のデータを削除しました\n`);
  return deletedCount;
}

/**
 * 単一アイテムを挿入
 */
export async function putItem(item: Record<string, unknown>): Promise<void> {
  await docClient.send(
    new PutCommand({
      TableName: TABLE_NAME,
      Item: item,
    })
  );
}

/**
 * 複数アイテムをバッチ挿入
 */
export async function batchPutItems(
  items: Record<string, unknown>[]
): Promise<void> {
  // 25件ずつバッチ挿入（DynamoDBの制限）
  for (let i = 0; i < items.length; i += 25) {
    const batch = items.slice(i, i + 25);
    const putRequests = batch.map((item) => ({
      PutRequest: {
        Item: item,
      },
    }));

    await docClient.send(
      new BatchWriteCommand({
        RequestItems: {
          [TABLE_NAME]: putRequests,
        },
      })
    );
  }
}
