import { deleteAllItems, batchPutItems } from "./dynamodb-client.js";
import {
  getUserSeedData,
  getRecipeSeedData,
  getIngredientSeedData,
  getStepSeedData,
  getCommentSeedData,
  getLikeSeedData,
} from "./seed-data.js";
import { TABLE_NAME } from "./config.js";

type Mode = "full" | "delete-only" | "insert-only";

function parseArgs(): Mode {
  const args = process.argv.slice(2);

  if (args.includes("--delete-only")) {
    return "delete-only";
  }
  if (args.includes("--insert-only")) {
    return "insert-only";
  }
  return "full";
}

async function insertSeedData(): Promise<void> {
  console.log("📝 シードデータを投入中...\n");

  // ユーザー
  const users = getUserSeedData();
  await batchPutItems(users);
  console.log(`  ✅ ユーザー: ${users.length} 件`);

  // レシピ
  const recipes = getRecipeSeedData();
  await batchPutItems(recipes);
  console.log(`  ✅ レシピ: ${recipes.length} 件`);

  // 材料
  const ingredients = getIngredientSeedData();
  await batchPutItems(ingredients);
  console.log(`  ✅ 材料: ${ingredients.length} 件`);

  // 手順
  const steps = getStepSeedData();
  await batchPutItems(steps);
  console.log(`  ✅ 手順: ${steps.length} 件`);

  // コメント
  const comments = getCommentSeedData();
  await batchPutItems(comments);
  console.log(`  ✅ コメント: ${comments.length} 件`);

  // いいね
  const likes = getLikeSeedData();
  await batchPutItems(likes);
  console.log(`  ✅ いいね: ${likes.length} 件`);

  const totalCount =
    users.length +
    recipes.length +
    ingredients.length +
    steps.length +
    comments.length +
    likes.length;

  console.log(`\n✅ 全 ${totalCount} 件のシードデータを投入しました`);
}

async function main(): Promise<void> {
  const mode = parseArgs();

  console.log("=".repeat(50));
  console.log(`🌱 DynamoDB シードスクリプト`);
  console.log(`📋 対象テーブル: ${TABLE_NAME}`);
  console.log(`🔧 モード: ${mode}`);
  console.log("=".repeat(50));
  console.log("");

  try {
    if (mode === "full" || mode === "delete-only") {
      await deleteAllItems();
    }

    if (mode === "full" || mode === "insert-only") {
      await insertSeedData();
    }

    console.log("\n🎉 シードスクリプトが正常に完了しました！");
  } catch (error) {
    console.error("\n❌ エラーが発生しました:", error);
    process.exit(1);
  }
}

main();
