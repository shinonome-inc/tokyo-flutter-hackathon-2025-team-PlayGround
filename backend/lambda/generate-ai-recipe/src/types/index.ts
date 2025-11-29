export interface RequestBody {
  prompt: string;
  userId: string;
  userName?: string;
  imageS3Key?: string;
  requiresImageUpload?: boolean;
}

export interface PresignedUrlResponse {
  uploadUrl: string;
  imageS3Key: string;
}

// AWS Secrets Managerに保存されている実際のJSONキー名に合わせる
export interface SecretValue {
  gemini_api_key: string;
}

export interface Ingredient {
  id: string;
  name: string;
  amount: string;
}

export interface Step {
  orderNumber: number;
  description: string;
}

export interface RecipeResponse {
  id: string;
  title: string;
  overview: string;
  imageUrl: string;
  isAiGenerated: boolean;
  createdAt: string;
  user: {
    id: string;
    name: string;
    imageUrl: string;
    description: string;
    emailAddress: string;
  };
  notes: string;
  ingredients: Ingredient[];
  steps: Step[];
  comments: unknown[];
  isLikedByMe: boolean;
  likeCount: number;
}

export interface GeneratedRecipe {
  title: string;
  overview: string;
  notes: string;
  ingredients: Array<{ name: string; amount: string }>;
  steps: string[];
}
