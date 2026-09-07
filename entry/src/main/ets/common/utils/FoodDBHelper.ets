import relationalStore from '@ohos.data.relationalStore';
import { FoodItem, DietRecordItem, FavoriteFoodItem } from '../models/FoodItem';

const STORE_CONFIG: relationalStore.StoreConfig = {
  name: 'HarmonyFoods.db',
  securityLevel: relationalStore.SecurityLevel.S1
};

const SQL_CREATE_CUSTOM_FOOD_TABLE = 'CREATE TABLE IF NOT EXISTS custom_food (id TEXT PRIMARY KEY, categoryId INTEGER, name TEXT, energy INTEGER, tags TEXT, protein REAL, fat REAL, carbs REAL)';
const SQL_CREATE_DIET_RECORD_TABLE = 'CREATE TABLE IF NOT EXISTS diet_record (id TEXT PRIMARY KEY, date TEXT, mealType TEXT, foodName TEXT, amount TEXT, energy INTEGER, protein REAL, fat REAL, carbs REAL, createdAt INTEGER)';
const SQL_CREATE_FAVORITE_FOOD_TABLE = 'CREATE TABLE IF NOT EXISTS favorite_food (id TEXT PRIMARY KEY, name TEXT, energy INTEGER, defaultAmount TEXT, categoryId INTEGER, createdAt INTEGER)';

let rdbStore: relationalStore.RdbStore | null = null;

export const DEFAULT_FOODS: FoodItem[] = [
  {
    id: 'b1', categoryId: 2,
    name: '苹果 (带皮)', energy: 53,
    protein: 0.2, fat: 0.2, carbs: 13.8,
    tags: [
      { label: '低嘌呤', color: '#2E8B57', bgColor: '#E8F5E9' },
      { label: '低钠', color: '#2E8B57', bgColor: '#E8F5E9' }
    ]
  },
  {
    id: 'b2', categoryId: 3,
    name: '猪肉 (瘦)', energy: 143,
    protein: 20.3, fat: 6.2, carbs: 1.5,
    tags: [
      { label: '中嘌呤 (150mg)', color: '#FF9800', bgColor: '#FFF3E0' },
      { label: '高蛋白', color: '#2196F3', bgColor: '#E3F2FD' }
    ]
  },
  {
    id: 'b3', categoryId: 3,
    name: '猪肝', energy: 130,
    protein: 19.3, fat: 3.5, carbs: 5.0,
    tags: [
      { label: '高嘌呤 (275mg)', color: '#F44336', bgColor: '#FFEBEE' },
      { label: '高胆固醇', color: '#F44336', bgColor: '#FFEBEE' }
    ]
  },
  {
    id: 'b4', categoryId: 1,
    name: '菠菜 (水煮)', energy: 28,
    protein: 2.9, fat: 0.4, carbs: 3.6,
    tags: [
      { label: '低热量', color: '#2E8B57', bgColor: '#E8F5E9' },
      { label: '草酸溶出', color: '#FF9800', bgColor: '#FFF3E0' }
    ]
  },
  {
    id: 'b5', categoryId: 4,
    name: '全脂牛奶', energy: 62,
    protein: 3.3, fat: 3.6, carbs: 4.8,
    tags: [
      { label: '高钙', color: '#2196F3', bgColor: '#E3F2FD' },
      { label: '极低嘌呤', color: '#2E8B57', bgColor: '#E8F5E9' }
    ]
  },
  {
    id: 'b6', categoryId: 5,
    name: '全麦面包', energy: 247,
    protein: 8.5, fat: 3.4, carbs: 46.0,
    tags: [
      { label: '高纤维', color: '#2E8B57', bgColor: '#E8F5E9' },
      { label: '低脂', color: '#2196F3', bgColor: '#E3F2FD' }
    ]
  },
  {
    id: 'b7', categoryId: 4,
    name: '纯牛奶', energy: 66,
    protein: 3.2, fat: 3.8, carbs: 4.8,
    tags: [
      { label: '高钙', color: '#2196F3', bgColor: '#E3F2FD' },
      { label: '低嘌呤', color: '#2E8B57', bgColor: '#E8F5E9' }
    ]
  },
  {
    id: 'b8', categoryId: 5,
    name: '米饭', energy: 116,
    protein: 2.6, fat: 0.3, carbs: 25.9,
    tags: [
      { label: '主食', color: '#FF9800', bgColor: '#FFF3E0' },
      { label: '低嘌呤', color: '#2E8B57', bgColor: '#E8F5E9' }
    ]
  },
  {
    id: 'b9', categoryId: 5,
    name: '西红柿炒鸡蛋', energy: 120,
    protein: 5.2, fat: 8.1, carbs: 6.5,
    tags: [
      { label: '家常菜', color: '#FF9800', bgColor: '#FFF3E0' },
      { label: '富含番茄红素', color: '#F44336', bgColor: '#FFEBEE' }
    ]
  },
  {
    id: 'b10', categoryId: 3,
    name: '水煮蛋', energy: 143,
    protein: 13.3, fat: 8.8, carbs: 2.8,
    tags: [
      { label: '优质蛋白', color: '#2196F3', bgColor: '#E3F2FD' },
      { label: '低嘌呤', color: '#2E8B57', bgColor: '#E8F5E9' }
    ]
  },
  {
    id: 'b11', categoryId: 2,
    name: '香蕉', energy: 93,
    protein: 1.4, fat: 0.2, carbs: 22.0,
    tags: [
      { label: '高钾', color: '#2E8B57', bgColor: '#E8F5E9' }
    ]
  },
  {
    id: 'b12', categoryId: 3,
    name: '鸡胸肉', energy: 133,
    protein: 24.6, fat: 1.9, carbs: 2.5,
    tags: [
      { label: '高蛋白', color: '#2196F3', bgColor: '#E3F2FD' },
      { label: '低脂肪', color: '#2E8B57', bgColor: '#E8F5E9' }
    ]
  }
];

export class FoodDBHelper {
  static async init(context: Context): Promise<void> {
    if (rdbStore) {
      return;
    }
    try {
      rdbStore = await relationalStore.getRdbStore(context, STORE_CONFIG);
      if (rdbStore) {
        await rdbStore.executeSql(SQL_CREATE_CUSTOM_FOOD_TABLE);
        await rdbStore.executeSql(SQL_CREATE_DIET_RECORD_TABLE);
        await rdbStore.executeSql(SQL_CREATE_FAVORITE_FOOD_TABLE);
        await FoodDBHelper.cleanLegacySeedRecords();
        await FoodDBHelper.seedInitialFavoritesIfEmpty();
      }
    } catch (err) {
      console.error('FoodDBHelper', 'Init RDB failed', err);
    }
  }

  // 自定义食物相关
  static async insertFood(food: FoodItem): Promise<void> {
    if (!rdbStore) return;
    const valueBucket: relationalStore.ValuesBucket = {
      'id': food.id,
      'categoryId': food.categoryId,
      'name': food.name,
      'energy': food.energy,
      'tags': JSON.stringify(food.tags),
      'protein': food.protein || 0,
      'fat': food.fat || 0,
      'carbs': food.carbs || 0,
    };
    try {
      await rdbStore.insert('custom_food', valueBucket);
    } catch (err) {
      console.error('FoodDBHelper', 'Insert food failed', err);
    }
  }

  static async deleteFood(id: string): Promise<void> {
    if (!rdbStore) return;
    let predicates = new relationalStore.RdbPredicates('custom_food');
    predicates.equalTo('id', id);
    try {
      await rdbStore.delete(predicates);
    } catch (err) {
      console.error('FoodDBHelper', 'Delete food failed', err);
    }
  }

  static async getCustomFoods(): Promise<FoodItem[]> {
    if (!rdbStore) return [];
    let predicates = new relationalStore.RdbPredicates('custom_food');
    let foods: FoodItem[] = [];
    try {
      let resultSet = await rdbStore.query(predicates, ['id', 'categoryId', 'name', 'energy', 'tags', 'protein', 'fat', 'carbs']);
      while (resultSet.goToNextRow()) {
        foods.push({
          id: resultSet.getString(resultSet.getColumnIndex('id')),
          categoryId: resultSet.getLong(resultSet.getColumnIndex('categoryId')),
          name: resultSet.getString(resultSet.getColumnIndex('name')),
          energy: resultSet.getLong(resultSet.getColumnIndex('energy')),
          tags: JSON.parse(resultSet.getString(resultSet.getColumnIndex('tags'))),
          protein: resultSet.getDouble(resultSet.getColumnIndex('protein')),
          fat: resultSet.getDouble(resultSet.getColumnIndex('fat')),
          carbs: resultSet.getDouble(resultSet.getColumnIndex('carbs'))
        });
      }
      resultSet.close();
    } catch (err) {
      console.error('FoodDBHelper', 'Query foods failed', err);
    }
    return foods;
  }

  static async getAllFoods(): Promise<FoodItem[]> {
    let custom = await FoodDBHelper.getCustomFoods();
    return [...custom, ...DEFAULT_FOODS];
  }

  // 饮食记录相关
  static async insertDietRecord(record: DietRecordItem): Promise<void> {
    if (!rdbStore) return;
    const valueBucket: relationalStore.ValuesBucket = {
      'id': record.id,
      'date': record.date,
      'mealType': record.mealType,
      'foodName': record.foodName,
      'amount': record.amount,
      'energy': record.energy,
      'protein': record.protein || 0,
      'fat': record.fat || 0,
      'carbs': record.carbs || 0,
      'createdAt': record.createdAt || Date.now()
    };
    try {
      await rdbStore.insert('diet_record', valueBucket);
    } catch (err) {
      console.error('FoodDBHelper', 'Insert diet record failed', err);
    }
  }

  static async deleteDietRecord(id: string): Promise<void> {
    if (!rdbStore) return;
    let predicates = new relationalStore.RdbPredicates('diet_record');
    predicates.equalTo('id', id);
    try {
      await rdbStore.delete(predicates);
    } catch (err) {
      console.error('FoodDBHelper', 'Delete diet record failed', err);
    }
  }

  static async getDietRecordsByDate(date: string): Promise<DietRecordItem[]> {
    if (!rdbStore) return [];
    let predicates = new relationalStore.RdbPredicates('diet_record');
    predicates.equalTo('date', date);
    predicates.orderByAsc('createdAt');
    let list: DietRecordItem[] = [];
    try {
      let resultSet = await rdbStore.query(predicates, ['id', 'date', 'mealType', 'foodName', 'amount', 'energy', 'protein', 'fat', 'carbs', 'createdAt']);
      while (resultSet.goToNextRow()) {
        list.push({
          id: resultSet.getString(resultSet.getColumnIndex('id')),
          date: resultSet.getString(resultSet.getColumnIndex('date')),
          mealType: resultSet.getString(resultSet.getColumnIndex('mealType')),
          foodName: resultSet.getString(resultSet.getColumnIndex('foodName')),
          amount: resultSet.getString(resultSet.getColumnIndex('amount')),
          energy: resultSet.getLong(resultSet.getColumnIndex('energy')),
          protein: resultSet.getDouble(resultSet.getColumnIndex('protein')),
          fat: resultSet.getDouble(resultSet.getColumnIndex('fat')),
          carbs: resultSet.getDouble(resultSet.getColumnIndex('carbs')),
          createdAt: resultSet.getLong(resultSet.getColumnIndex('createdAt'))
        });
      }
      resultSet.close();
    } catch (err) {
      console.error('FoodDBHelper', 'Query diet records failed', err);
    }
    return list;
  }

  static async getRecentDietFoods(limit: number = 8): Promise<DietRecordItem[]> {
    if (!rdbStore) return [];
    let predicates = new relationalStore.RdbPredicates('diet_record');
    predicates.orderByDesc('createdAt');
    let list: DietRecordItem[] = [];
    let seenNames: string[] = [];
    try {
      let resultSet = await rdbStore.query(predicates, ['id', 'date', 'mealType', 'foodName', 'amount', 'energy', 'protein', 'fat', 'carbs', 'createdAt']);
      while (resultSet.goToNextRow() && list.length < limit) {
        let name = resultSet.getString(resultSet.getColumnIndex('foodName'));
        if (seenNames.indexOf(name) === -1) {
          seenNames.push(name);
          list.push({
            id: resultSet.getString(resultSet.getColumnIndex('id')),
            date: resultSet.getString(resultSet.getColumnIndex('date')),
            mealType: resultSet.getString(resultSet.getColumnIndex('mealType')),
            foodName: name,
            amount: resultSet.getString(resultSet.getColumnIndex('amount')),
            energy: resultSet.getLong(resultSet.getColumnIndex('energy')),
            protein: resultSet.getDouble(resultSet.getColumnIndex('protein')),
            fat: resultSet.getDouble(resultSet.getColumnIndex('fat')),
            carbs: resultSet.getDouble(resultSet.getColumnIndex('carbs')),
            createdAt: resultSet.getLong(resultSet.getColumnIndex('createdAt'))
          });
        }
      }
      resultSet.close();
    } catch (err) {
      console.error('FoodDBHelper', 'Query recent diet foods failed', err);
    }
    return list;
  }

  // 收藏相关
  static async insertFavoriteFood(food: FavoriteFoodItem): Promise<void> {
    if (!rdbStore) return;
    const valueBucket: relationalStore.ValuesBucket = {
      'id': food.id,
      'name': food.name,
      'energy': food.energy,
      'defaultAmount': food.defaultAmount,
      'categoryId': food.categoryId || 0,
      'createdAt': food.createdAt || Date.now()
    };
    try {
      await rdbStore.insert('favorite_food', valueBucket);
    } catch (err) {
      console.error('FoodDBHelper', 'Insert favorite failed', err);
    }
  }

  static async deleteFavoriteFood(idOrName: string): Promise<void> {
    if (!rdbStore) return;
    let predicates = new relationalStore.RdbPredicates('favorite_food');
    predicates.equalTo('id', idOrName).or().equalTo('name', idOrName);
    try {
      await rdbStore.delete(predicates);
    } catch (err) {
      console.error('FoodDBHelper', 'Delete favorite failed', err);
    }
  }

  static async getFavoriteFoods(): Promise<FavoriteFoodItem[]> {
    if (!rdbStore) return [];
    let predicates = new relationalStore.RdbPredicates('favorite_food');
    predicates.orderByDesc('createdAt');
    let list: FavoriteFoodItem[] = [];
    try {
      let resultSet = await rdbStore.query(predicates, ['id', 'name', 'energy', 'defaultAmount', 'categoryId', 'createdAt']);
      while (resultSet.goToNextRow()) {
        list.push({
          id: resultSet.getString(resultSet.getColumnIndex('id')),
          name: resultSet.getString(resultSet.getColumnIndex('name')),
          energy: resultSet.getLong(resultSet.getColumnIndex('energy')),
          defaultAmount: resultSet.getString(resultSet.getColumnIndex('defaultAmount')),
          categoryId: resultSet.getLong(resultSet.getColumnIndex('categoryId')),
          createdAt: resultSet.getLong(resultSet.getColumnIndex('createdAt'))
        });
      }
      resultSet.close();
    } catch (err) {
      console.error('FoodDBHelper', 'Query favorites failed', err);
    }
    return list;
  }

  // 清理历史种子/默认记录数据（删除以 seed_ 开头的记录）
  static async cleanLegacySeedRecords(): Promise<void> {
    if (!rdbStore) return;
    try {
      let predicates = new relationalStore.RdbPredicates('diet_record');
      predicates.beginsWith('id', 'seed_');
      await rdbStore.delete(predicates);
    } catch (err) {
      console.error('FoodDBHelper', 'Clean legacy seed records failed', err);
    }
  }

  // 清空所有饮食记录
  static async clearAllDietRecords(): Promise<void> {
    if (!rdbStore) return;
    try {
      let predicates = new relationalStore.RdbPredicates('diet_record');
      await rdbStore.delete(predicates);
    } catch (err) {
      console.error('FoodDBHelper', 'Clear all diet records failed', err);
    }
  }

  // 清空指定日期的饮食记录
  static async clearDietRecordsByDate(date: string): Promise<void> {
    if (!rdbStore) return;
    try {
      let predicates = new relationalStore.RdbPredicates('diet_record');
      predicates.equalTo('date', date);
      await rdbStore.delete(predicates);
    } catch (err) {
      console.error('FoodDBHelper', 'Clear diet records by date failed', err);
    }
  }

  // 初始化收藏夹种子（若为空）
  static async seedInitialFavoritesIfEmpty(): Promise<void> {
    if (!rdbStore) return;
    try {
      let favPred = new relationalStore.RdbPredicates('favorite_food');
      let favCount = await rdbStore.query(favPred, ['id']);
      let hasFav = favCount.rowCount > 0;
      favCount.close();
      if (!hasFav) {
        await FoodDBHelper.insertFavoriteFood({
          id: 'fav_1',
          name: '全麦面包',
          energy: 247,
          defaultAmount: '100g',
          categoryId: 5,
          createdAt: Date.now()
        });
        await FoodDBHelper.insertFavoriteFood({
          id: 'fav_2',
          name: '纯牛奶',
          energy: 66,
          defaultAmount: '250ml',
          categoryId: 4,
          createdAt: Date.now()
        });
        await FoodDBHelper.insertFavoriteFood({
          id: 'fav_3',
          name: '苹果 (带皮)',
          energy: 53,
          defaultAmount: '200g',
          categoryId: 2,
          createdAt: Date.now()
        });
      }
    } catch (err) {
      console.error('FoodDBHelper', 'Seed favorites failed', err);
    }
  }

  // 保留兼容函数，不再自动生成任何饮食记录种子，确保记录干净清爽
  static async seedInitialDietRecordsIfEmpty(initialDateKey?: string): Promise<void> {
    await FoodDBHelper.cleanLegacySeedRecords();
    await FoodDBHelper.seedInitialFavoritesIfEmpty();
  }
}
