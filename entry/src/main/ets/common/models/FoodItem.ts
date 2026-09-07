export interface FoodTag {
  label: string;
  color: string;
  bgColor: string;
}

export interface FoodItem {
  id: string;
  categoryId: number; // 0=全部, 1=蔬菜, 2=水果, 3=肉禽, 4=饮品, 5=中式
  name: string;
  energy: number; // kcal per 100g
  tags: FoodTag[];
  protein?: number;
  fat?: number;
  carbs?: number;
}

export interface DietRecordItem {
  id: string;
  date: string; // 'YYYY-MM-DD'
  mealType: string; // '早餐' | '午餐' | '晚餐' | '加餐'
  foodName: string;
  amount: string; // e.g. '100g', '250ml'
  energy: number; // kcal
  protein?: number;
  fat?: number;
  carbs?: number;
  createdAt: number;
}

export interface FavoriteFoodItem {
  id: string;
  name: string;
  energy: number; // kcal per 100g
  defaultAmount: string;
  categoryId?: number;
  createdAt: number;
}

