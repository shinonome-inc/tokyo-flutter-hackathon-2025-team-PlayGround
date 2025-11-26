import { APIGatewayProxyEvent, APIGatewayProxyResult } from "aws-lambda";
import { v4 as uuidv4 } from "uuid";
import { RequestBody, RecipeResponse, Ingredient, Step } from "./types/index";
import { getGeminiApiKey } from "./services/secretsManagerService";
import { generateRecipeText } from "./services/geminiService";
import { generateRecipeImage } from "./services/imagenService";
import { uploadImageToS3 } from "./services/s3Service";

export const handler = async (
  event: APIGatewayProxyEvent
): Promise<APIGatewayProxyResult> => {
  try {
    console.log("Received event:", JSON.stringify(event));

    if (!event.body) {
      return {
        statusCode: 400,
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ error: "Request body is required" }),
      };
    }

    console.log("Event body:", event.body);
    console.log("Event body type:", typeof event.body);
    console.log("Event body length:", event.body.length);

    const requestBody: RequestBody =
      typeof event.body === "string" ? JSON.parse(event.body) : event.body;

    if (!requestBody.context || typeof requestBody.context !== "string") {
      return {
        statusCode: 400,
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          error: "context is required and must be a string",
        }),
      };
    }

    const recipe = await generateRecipeText(
      await getGeminiApiKey(),
      requestBody.context
    );

    const recipeId = uuidv4();
    const imageUrl = await uploadImageToS3(
      await generateRecipeImage(recipe.title, recipe.ingredients, recipe.overview),
      `${recipeId}.png`
    );

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
