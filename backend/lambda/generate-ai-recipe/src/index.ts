import { APIGatewayProxyEvent, APIGatewayProxyResult } from "aws-lambda";
import { v4 as uuidv4 } from "uuid";
import { RequestBody, RecipeResponse, Ingredient, Step } from "./types/index";
import { getGeminiApiKey } from "./services/secretsManagerService";
import { generateRecipeText } from "./services/geminiService";
import { generateRecipeImage } from "./services/imagenService";
import { uploadImageToS3, downloadImageFromS3 } from "./services/s3Service";
import { enrichRecipeContextWithImageIngredients } from "./services/ingredientDetectionService";

export const handler = async (
  event: APIGatewayProxyEvent | RequestBody
): Promise<APIGatewayProxyResult> => {
  console.log("Received event:", JSON.stringify(event, null, 2));

  let requestBody: RequestBody;

  if ("body" in event && event.body) {
    console.log("Event body:", event.body);
    requestBody =
      typeof event.body === "string" ? JSON.parse(event.body) : event.body;
  } else if ("context" in event) {
    console.log("Direct Lambda invocation");
    requestBody = event as RequestBody;
  } else {
    return {
      statusCode: 400,
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ error: "Request body is required" }),
    };
  }

  if (!requestBody.context || typeof requestBody.context !== "string") {
    return {
      statusCode: 400,
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        error: "context is required and must be a string",
      }),
    };
  }

  try {
    let recipeContext = requestBody.context;

    if (requestBody.image_s3_key) {
      const imageBuffer = await downloadImageFromS3(requestBody.image_s3_key);
      recipeContext = await enrichRecipeContextWithImageIngredients(
        imageBuffer,
        recipeContext
      );
    }

    const recipe = await generateRecipeText(
      await getGeminiApiKey(),
      recipeContext
    );

    const recipeId = uuidv4();
    const generatedImage = await generateRecipeImage(
      recipe.title,
      recipe.ingredients,
      recipe.overview
    );
    const imageUrl = await uploadImageToS3(generatedImage, `${recipeId}.png`);

    const ingredients: Ingredient[] = recipe.ingredients.map((ing) => ({
      id: uuidv4(),
      name: ing.name,
      amount: ing.amount,
    }));

    const steps: Step[] = recipe.steps.map((step, index) => ({
      order_number: index + 1,
      description: step,
    }));

    const response: RecipeResponse = {
      id: recipeId,
      title: recipe.title,
      overview: recipe.overview,
      image_url: imageUrl,
      is_ai_generated: true,
      created_at: new Date().toISOString(),
      user: {
        id: requestBody.user_id || "ai-system",
        name: requestBody.user_name || "AI Recipe Generator",
        image_url: "",
        description: "AI generated recipe",
        email_address: "",
      },
      notes: recipe.notes,
      ingredients,
      steps,
      comments: [],
      is_liked_by_me: false,
      like_count: 0,
    };

    return {
      statusCode: 200,
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(response),
    };
  } catch (error) {
    console.error("Error:", error);
    return {
      statusCode: 500,
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        error: "Internal server error",
        message: error instanceof Error ? error.message : "Unknown error",
      }),
    };
  }
};
