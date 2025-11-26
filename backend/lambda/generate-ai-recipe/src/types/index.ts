export interface RequestBody {
  context: string;
  user_id?: string;
  user_name?: string;
}

export interface SecretValue {
  gemini_api_key: string;
}

export interface Ingredient {
  id: string;
  name: string;
  amount: string;
}

export interface Step {
  order_number: number;
  description: string;
}

export interface RecipeResponse {
  id: string;
  title: string;
  overview: string;
  image_url: string;
  is_ai_generated: boolean;
  created_at: string;
  user: {
    id: string;
    name: string;
    image_url: string;
    description: string;
    email_address: string;
  };
  notes: string;
  ingredients: Ingredient[];
  steps: Step[];
  comments: any[];
  is_liked_by_me: boolean;
  like_count: number;
}

export interface GeneratedRecipe {
  title: string;
  overview: string;
  notes: string;
  ingredients: Array<{ name: string; amount: string }>;
  steps: string[];
}
