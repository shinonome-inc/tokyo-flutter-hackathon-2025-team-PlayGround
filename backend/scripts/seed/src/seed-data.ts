import { v4 as uuidv4 } from "uuid";

// 固定のUUIDを使用（再現性のため）
const USER_IDS = {
  user1: "seed-user-001",
  user2: "seed-user-002",
  user3: "seed-user-003",
};

const RECIPE_IDS = {
  recipe1: "seed-recipe-001",
  recipe2: "seed-recipe-002",
  recipe3: "seed-recipe-003",
};

// 現在時刻を基準にした日時を生成
function getISODate(daysAgo: number = 0): string {
  const date = new Date();
  date.setDate(date.getDate() - daysAgo);
  return date.toISOString();
}

/**
 * ユーザーシードデータ
 */
export function getUserSeedData(): Record<string, unknown>[] {
  return [
    {
      PK: `USER#${USER_IDS.user1}`,
      SK: "PROFILE",
      UserId: USER_IDS.user1,
      UserName: "田中太郎",
      EmailAddress: "tanaka@example.com",
      ImageUrl: "https://example.com/images/user1.jpg",
      Description: "料理が大好きな会社員です。週末は新しいレシピに挑戦しています。",
      CreatedAt: getISODate(30),
      UpdatedAt: getISODate(5),
      EntityType: "USER",
      GSI2PK: "USER_STATUS#ACTIVE",
      GSI2SK: getISODate(30),
      GSI3PK: "EMAIL#tanaka@example.com",
      GSI3SK: "PROFILE",
    },
    {
      PK: `USER#${USER_IDS.user2}`,
      SK: "PROFILE",
      UserId: USER_IDS.user2,
      UserName: "山田花子",
      EmailAddress: "yamada@example.com",
      ImageUrl: "https://example.com/images/user2.jpg",
      Description: "主婦歴10年。簡単で美味しいレシピを共有します！",
      CreatedAt: getISODate(25),
      UpdatedAt: getISODate(3),
      EntityType: "USER",
      GSI2PK: "USER_STATUS#ACTIVE",
      GSI2SK: getISODate(25),
      GSI3PK: "EMAIL#yamada@example.com",
      GSI3SK: "PROFILE",
    },
    {
      PK: `USER#${USER_IDS.user3}`,
      SK: "PROFILE",
      UserId: USER_IDS.user3,
      UserName: "佐藤健",
      EmailAddress: "sato@example.com",
      ImageUrl: "https://example.com/images/user3.jpg",
      Description: "プロの料理人です。家庭でも作れるプロの味を紹介します。",
      CreatedAt: getISODate(20),
      UpdatedAt: getISODate(1),
      EntityType: "USER",
      GSI2PK: "USER_STATUS#ACTIVE",
      GSI2SK: getISODate(20),
      GSI3PK: "EMAIL#sato@example.com",
      GSI3SK: "PROFILE",
    },
  ];
}

/**
 * レシピシードデータ
 */
export function getRecipeSeedData(): Record<string, unknown>[] {
  const recipe1CreatedAt = getISODate(10);
  const recipe2CreatedAt = getISODate(7);
  const recipe3CreatedAt = getISODate(3);

  return [
    {
      PK: `RECIPE#${RECIPE_IDS.recipe1}`,
      SK: `RECIPE#${RECIPE_IDS.recipe1}`,
      RecipeId: RECIPE_IDS.recipe1,
      UserId: USER_IDS.user1,
      Title: "簡単！ふわふわ卵のオムライス",
      Overview:
        "ケチャップライスにふわふわ卵を乗せた、定番のオムライスです。コツさえ押さえれば誰でも簡単に作れます。",
      Notes: "卵は常温に戻しておくとよりふわふわに仕上がります。",
      ImageUrl: "https://example.com/images/omurice.jpg",
      IsAiGenerated: false,
      CreatedAt: recipe1CreatedAt,
      EntityType: "RECIPE",
      GSI1PK: `USER#${USER_IDS.user1}`,
      GSI1SK: `RECIPE#${recipe1CreatedAt}`,
      GSI2PK: "RECIPE_STATUS#PUB",
      GSI2SK: recipe1CreatedAt,
    },
    {
      PK: `RECIPE#${RECIPE_IDS.recipe2}`,
      SK: `RECIPE#${RECIPE_IDS.recipe2}`,
      RecipeId: RECIPE_IDS.recipe2,
      UserId: USER_IDS.user2,
      Title: "野菜たっぷり味噌汁",
      Overview:
        "旬の野菜をたっぷり使った、体が温まる味噌汁です。出汁から丁寧に取ることで深い味わいに。",
      Notes: "味噌は沸騰させると風味が飛ぶので、火を止めてから加えてください。",
      ImageUrl: "https://example.com/images/misosoup.jpg",
      IsAiGenerated: false,
      CreatedAt: recipe2CreatedAt,
      EntityType: "RECIPE",
      GSI1PK: `USER#${USER_IDS.user2}`,
      GSI1SK: `RECIPE#${recipe2CreatedAt}`,
      GSI2PK: "RECIPE_STATUS#PUB",
      GSI2SK: recipe2CreatedAt,
    },
    {
      PK: `RECIPE#${RECIPE_IDS.recipe3}`,
      SK: `RECIPE#${RECIPE_IDS.recipe3}`,
      RecipeId: RECIPE_IDS.recipe3,
      UserId: USER_IDS.user3,
      Title: "本格ペペロンチーノ",
      Overview:
        "シンプルな材料で作る本格的なペペロンチーノ。にんにくと唐辛子の香りが食欲をそそります。",
      Notes: "パスタの茹で汁を加えることで乳化させるのがポイントです。",
      ImageUrl: "https://example.com/images/peperoncino.jpg",
      IsAiGenerated: true,
      CreatedAt: recipe3CreatedAt,
      EntityType: "RECIPE",
      GSI1PK: `USER#${USER_IDS.user3}`,
      GSI1SK: `RECIPE#${recipe3CreatedAt}`,
      GSI2PK: "RECIPE_STATUS#PUB",
      GSI2SK: recipe3CreatedAt,
    },
  ];
}

/**
 * 材料シードデータ
 */
export function getIngredientSeedData(): Record<string, unknown>[] {
  return [
    // オムライスの材料
    {
      PK: `RECIPE#${RECIPE_IDS.recipe1}`,
      SK: `INGREDIENT#0#${uuidv4()}`,
      IngredientId: uuidv4(),
      RecipeId: RECIPE_IDS.recipe1,
      Name: "ご飯",
      Amount: "200g",
      OrderIndex: 0,
      EntityType: "INGREDIENT",
    },
    {
      PK: `RECIPE#${RECIPE_IDS.recipe1}`,
      SK: `INGREDIENT#1#${uuidv4()}`,
      IngredientId: uuidv4(),
      RecipeId: RECIPE_IDS.recipe1,
      Name: "卵",
      Amount: "3個",
      OrderIndex: 1,
      EntityType: "INGREDIENT",
    },
    {
      PK: `RECIPE#${RECIPE_IDS.recipe1}`,
      SK: `INGREDIENT#2#${uuidv4()}`,
      IngredientId: uuidv4(),
      RecipeId: RECIPE_IDS.recipe1,
      Name: "鶏もも肉",
      Amount: "100g",
      OrderIndex: 2,
      EntityType: "INGREDIENT",
    },
    {
      PK: `RECIPE#${RECIPE_IDS.recipe1}`,
      SK: `INGREDIENT#3#${uuidv4()}`,
      IngredientId: uuidv4(),
      RecipeId: RECIPE_IDS.recipe1,
      Name: "ケチャップ",
      Amount: "大さじ3",
      OrderIndex: 3,
      EntityType: "INGREDIENT",
    },
    // 味噌汁の材料
    {
      PK: `RECIPE#${RECIPE_IDS.recipe2}`,
      SK: `INGREDIENT#0#${uuidv4()}`,
      IngredientId: uuidv4(),
      RecipeId: RECIPE_IDS.recipe2,
      Name: "豆腐",
      Amount: "1/2丁",
      OrderIndex: 0,
      EntityType: "INGREDIENT",
    },
    {
      PK: `RECIPE#${RECIPE_IDS.recipe2}`,
      SK: `INGREDIENT#1#${uuidv4()}`,
      IngredientId: uuidv4(),
      RecipeId: RECIPE_IDS.recipe2,
      Name: "わかめ",
      Amount: "適量",
      OrderIndex: 1,
      EntityType: "INGREDIENT",
    },
    {
      PK: `RECIPE#${RECIPE_IDS.recipe2}`,
      SK: `INGREDIENT#2#${uuidv4()}`,
      IngredientId: uuidv4(),
      RecipeId: RECIPE_IDS.recipe2,
      Name: "味噌",
      Amount: "大さじ2",
      OrderIndex: 2,
      EntityType: "INGREDIENT",
    },
    {
      PK: `RECIPE#${RECIPE_IDS.recipe2}`,
      SK: `INGREDIENT#3#${uuidv4()}`,
      IngredientId: uuidv4(),
      RecipeId: RECIPE_IDS.recipe2,
      Name: "だし汁",
      Amount: "600ml",
      OrderIndex: 3,
      EntityType: "INGREDIENT",
    },
    // ペペロンチーノの材料
    {
      PK: `RECIPE#${RECIPE_IDS.recipe3}`,
      SK: `INGREDIENT#0#${uuidv4()}`,
      IngredientId: uuidv4(),
      RecipeId: RECIPE_IDS.recipe3,
      Name: "スパゲッティ",
      Amount: "100g",
      OrderIndex: 0,
      EntityType: "INGREDIENT",
    },
    {
      PK: `RECIPE#${RECIPE_IDS.recipe3}`,
      SK: `INGREDIENT#1#${uuidv4()}`,
      IngredientId: uuidv4(),
      RecipeId: RECIPE_IDS.recipe3,
      Name: "にんにく",
      Amount: "2片",
      OrderIndex: 1,
      EntityType: "INGREDIENT",
    },
    {
      PK: `RECIPE#${RECIPE_IDS.recipe3}`,
      SK: `INGREDIENT#2#${uuidv4()}`,
      IngredientId: uuidv4(),
      RecipeId: RECIPE_IDS.recipe3,
      Name: "唐辛子",
      Amount: "1本",
      OrderIndex: 2,
      EntityType: "INGREDIENT",
    },
    {
      PK: `RECIPE#${RECIPE_IDS.recipe3}`,
      SK: `INGREDIENT#3#${uuidv4()}`,
      IngredientId: uuidv4(),
      RecipeId: RECIPE_IDS.recipe3,
      Name: "オリーブオイル",
      Amount: "大さじ3",
      OrderIndex: 3,
      EntityType: "INGREDIENT",
    },
  ];
}

/**
 * 手順シードデータ
 */
export function getStepSeedData(): Record<string, unknown>[] {
  return [
    // オムライスの手順
    {
      PK: `RECIPE#${RECIPE_IDS.recipe1}`,
      SK: `STEP#1#${uuidv4()}`,
      StepId: uuidv4(),
      RecipeId: RECIPE_IDS.recipe1,
      OrderNumber: 1,
      Description: "鶏もも肉を一口大に切り、フライパンで炒めます。",
      EntityType: "STEP",
    },
    {
      PK: `RECIPE#${RECIPE_IDS.recipe1}`,
      SK: `STEP#2#${uuidv4()}`,
      StepId: uuidv4(),
      RecipeId: RECIPE_IDS.recipe1,
      OrderNumber: 2,
      Description: "ご飯を加えて炒め、ケチャップで味付けしてケチャップライスを作ります。",
      EntityType: "STEP",
    },
    {
      PK: `RECIPE#${RECIPE_IDS.recipe1}`,
      SK: `STEP#3#${uuidv4()}`,
      StepId: uuidv4(),
      RecipeId: RECIPE_IDS.recipe1,
      OrderNumber: 3,
      Description: "別のフライパンでバターを溶かし、溶き卵を流し入れてふわふわの卵を作ります。",
      EntityType: "STEP",
    },
    {
      PK: `RECIPE#${RECIPE_IDS.recipe1}`,
      SK: `STEP#4#${uuidv4()}`,
      StepId: uuidv4(),
      RecipeId: RECIPE_IDS.recipe1,
      OrderNumber: 4,
      Description: "ケチャップライスの上に卵を乗せて完成です。",
      EntityType: "STEP",
    },
    // 味噌汁の手順
    {
      PK: `RECIPE#${RECIPE_IDS.recipe2}`,
      SK: `STEP#1#${uuidv4()}`,
      StepId: uuidv4(),
      RecipeId: RECIPE_IDS.recipe2,
      OrderNumber: 1,
      Description: "鍋にだし汁を入れて火にかけます。",
      EntityType: "STEP",
    },
    {
      PK: `RECIPE#${RECIPE_IDS.recipe2}`,
      SK: `STEP#2#${uuidv4()}`,
      StepId: uuidv4(),
      RecipeId: RECIPE_IDS.recipe2,
      OrderNumber: 2,
      Description: "豆腐を食べやすい大きさに切って加えます。",
      EntityType: "STEP",
    },
    {
      PK: `RECIPE#${RECIPE_IDS.recipe2}`,
      SK: `STEP#3#${uuidv4()}`,
      StepId: uuidv4(),
      RecipeId: RECIPE_IDS.recipe2,
      OrderNumber: 3,
      Description: "わかめを加えてさっと煮ます。",
      EntityType: "STEP",
    },
    {
      PK: `RECIPE#${RECIPE_IDS.recipe2}`,
      SK: `STEP#4#${uuidv4()}`,
      StepId: uuidv4(),
      RecipeId: RECIPE_IDS.recipe2,
      OrderNumber: 4,
      Description: "火を止めて味噌を溶き入れて完成です。",
      EntityType: "STEP",
    },
    // ペペロンチーノの手順
    {
      PK: `RECIPE#${RECIPE_IDS.recipe3}`,
      SK: `STEP#1#${uuidv4()}`,
      StepId: uuidv4(),
      RecipeId: RECIPE_IDS.recipe3,
      OrderNumber: 1,
      Description: "たっぷりの湯に塩を入れ、パスタを茹でます。",
      EntityType: "STEP",
    },
    {
      PK: `RECIPE#${RECIPE_IDS.recipe3}`,
      SK: `STEP#2#${uuidv4()}`,
      StepId: uuidv4(),
      RecipeId: RECIPE_IDS.recipe3,
      OrderNumber: 2,
      Description: "フライパンにオリーブオイルとスライスしたにんにく、唐辛子を入れて弱火で加熱します。",
      EntityType: "STEP",
    },
    {
      PK: `RECIPE#${RECIPE_IDS.recipe3}`,
      SK: `STEP#3#${uuidv4()}`,
      StepId: uuidv4(),
      RecipeId: RECIPE_IDS.recipe3,
      OrderNumber: 3,
      Description: "にんにくが色づいたら、パスタの茹で汁をお玉1杯分加えて乳化させます。",
      EntityType: "STEP",
    },
    {
      PK: `RECIPE#${RECIPE_IDS.recipe3}`,
      SK: `STEP#4#${uuidv4()}`,
      StepId: uuidv4(),
      RecipeId: RECIPE_IDS.recipe3,
      OrderNumber: 4,
      Description: "茹で上がったパスタを加えてよく絡めて完成です。",
      EntityType: "STEP",
    },
  ];
}

/**
 * コメントシードデータ
 */
export function getCommentSeedData(): Record<string, unknown>[] {
  const comment1CreatedAt = getISODate(5);
  const comment2CreatedAt = getISODate(4);
  const comment3CreatedAt = getISODate(2);

  return [
    {
      PK: `RECIPE#${RECIPE_IDS.recipe1}`,
      SK: `COMMENT#${comment1CreatedAt}#${uuidv4()}`,
      CommentId: uuidv4(),
      RecipeId: RECIPE_IDS.recipe1,
      UserId: USER_IDS.user2,
      UserName: "山田花子",
      Description: "ふわふわ卵のコツがとても参考になりました！家族にも好評でした。",
      CreatedAt: comment1CreatedAt,
      EntityType: "COMMENT",
    },
    {
      PK: `RECIPE#${RECIPE_IDS.recipe1}`,
      SK: `COMMENT#${comment2CreatedAt}#${uuidv4()}`,
      CommentId: uuidv4(),
      RecipeId: RECIPE_IDS.recipe1,
      UserId: USER_IDS.user3,
      UserName: "佐藤健",
      Description: "プロの立場から見ても良いレシピですね。バターを少し多めにするとさらに美味しくなりますよ。",
      CreatedAt: comment2CreatedAt,
      EntityType: "COMMENT",
    },
    {
      PK: `RECIPE#${RECIPE_IDS.recipe2}`,
      SK: `COMMENT#${comment3CreatedAt}#${uuidv4()}`,
      CommentId: uuidv4(),
      RecipeId: RECIPE_IDS.recipe2,
      UserId: USER_IDS.user1,
      UserName: "田中太郎",
      Description: "シンプルだけど出汁が効いていて美味しかったです！",
      CreatedAt: comment3CreatedAt,
      EntityType: "COMMENT",
    },
  ];
}

/**
 * いいねシードデータ
 */
export function getLikeSeedData(): Record<string, unknown>[] {
  const like1CreatedAt = getISODate(8);
  const like2CreatedAt = getISODate(6);
  const like3CreatedAt = getISODate(5);
  const like4CreatedAt = getISODate(4);
  const like5CreatedAt = getISODate(2);

  return [
    // recipe1へのいいね（user2, user3）
    {
      PK: `RECIPE#${RECIPE_IDS.recipe1}`,
      SK: `LIKE#${USER_IDS.user2}`,
      RecipeId: RECIPE_IDS.recipe1,
      UserId: USER_IDS.user2,
      CreatedAt: like1CreatedAt,
      EntityType: "LIKE",
      GSI1PK: `USER#${USER_IDS.user2}`,
      GSI1SK: `LIKE#${like1CreatedAt}`,
    },
    {
      PK: `RECIPE#${RECIPE_IDS.recipe1}`,
      SK: `LIKE#${USER_IDS.user3}`,
      RecipeId: RECIPE_IDS.recipe1,
      UserId: USER_IDS.user3,
      CreatedAt: like2CreatedAt,
      EntityType: "LIKE",
      GSI1PK: `USER#${USER_IDS.user3}`,
      GSI1SK: `LIKE#${like2CreatedAt}`,
    },
    // recipe2へのいいね（user1, user3）
    {
      PK: `RECIPE#${RECIPE_IDS.recipe2}`,
      SK: `LIKE#${USER_IDS.user1}`,
      RecipeId: RECIPE_IDS.recipe2,
      UserId: USER_IDS.user1,
      CreatedAt: like3CreatedAt,
      EntityType: "LIKE",
      GSI1PK: `USER#${USER_IDS.user1}`,
      GSI1SK: `LIKE#${like3CreatedAt}`,
    },
    {
      PK: `RECIPE#${RECIPE_IDS.recipe2}`,
      SK: `LIKE#${USER_IDS.user3}`,
      RecipeId: RECIPE_IDS.recipe2,
      UserId: USER_IDS.user3,
      CreatedAt: like4CreatedAt,
      EntityType: "LIKE",
      GSI1PK: `USER#${USER_IDS.user3}`,
      GSI1SK: `LIKE#${like4CreatedAt}`,
    },
    // recipe3へのいいね（user1）
    {
      PK: `RECIPE#${RECIPE_IDS.recipe3}`,
      SK: `LIKE#${USER_IDS.user1}`,
      RecipeId: RECIPE_IDS.recipe3,
      UserId: USER_IDS.user1,
      CreatedAt: like5CreatedAt,
      EntityType: "LIKE",
      GSI1PK: `USER#${USER_IDS.user1}`,
      GSI1SK: `LIKE#${like5CreatedAt}`,
    },
  ];
}
