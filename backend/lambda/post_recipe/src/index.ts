import { APIGatewayProxyEvent, APIGatewayProxyResult } from "aws-lambda";
import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, PutCommand } from "@aws-sdk/lib-dynamodb";
import { v4 as uuidv4 } from "uuid";

const client = new DynamoDBClient();
const ddbDocClient = DynamoDBDocumentClient.from(client);

export const handler = async (
    event: APIGatewayProxyEvent
): Promise<APIGatewayProxyResult> => {
    const body = JSON.parse(event.body!);
    const recipeId = uuidv4();
    const ingredientId = uuidv4();
    const stepId = uuidv4();
    const ingredientList = body["ingredients"];
    const stepList = body["steps"];
    try {
        await ddbDocClient.send(new PutCommand({
            TableName: "recipes",
            Item: {
                RecipeId: recipeId,
                UserId: body["user_id"],
                CreatedAt: body["created_at"],
                UpdatedAt: body["updated_at"],
                ImageUrl: body["image_url"],
                Title: body["title"],
                Notes: body["notes"],
                isAiGenerated: body["is_ai_generated"],
                Overview: body["overview"],
            }
        }))
        for (let i = 0; i < ingredientList.length; i++) {
            const ingredient = ingredientList[i];
            await ddbDocClient.send(new PutCommand({
                TableName: "ingredients",
                Item: {
                    IngredientId: ingredientId,
                    RecipeId: recipeId,
                    Name: ingredient["name"],
                    Amount: ingredient["amount"],
                }
            }))
        }

        for (let i = 0; i < stepList.length; i++) {
            const step = stepList[i];
            await ddbDocClient.send(new PutCommand({
                TableName: "steps",
                Item: {
                    StepId: stepId,
                    RecipeId: recipeId,
                    OrderNumber: step["order_number"],
                    Description: step["description"],
                }
            }))
        }
        return {
            statusCode: 201,
            body: JSON.stringify({
                message: "レシピの作成に成功しました",
            }),
        }
    } catch (error) {
        return {
            statusCode: 500,
            body: JSON.stringify({
                message: `サーバーエラーが起きました: ${error}`,
            }),
        }
    }
}