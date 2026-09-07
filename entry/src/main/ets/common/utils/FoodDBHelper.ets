import relationalStore from '@ohos.data.relationalStore';
import { FoodItem, DietRecordItem, FavoriteFoodItem, UserProfile, UserAccount, LoginResult } from '../models/FoodItem';

const STORE_CONFIG: relationalStore.StoreConfig = {
  name: 'HarmonyFoods.db',
  securityLevel: relationalStore.SecurityLevel.S1
};

const SQL_CREATE_CUSTOM_FOOD_TABLE = 'CREATE TABLE IF NOT EXISTS custom_food (id TEXT PRIMARY KEY, categoryId INTEGER, name TEXT, energy INTEGER, tags TEXT, protein REAL, fat REAL, carbs REAL)';
const SQL_CREATE_DIET_RECORD_TABLE = 'CREATE TABLE IF NOT EXISTS diet_record (id TEXT PRIMARY KEY, date TEXT, mealType TEXT, foodName TEXT, amount TEXT, energy INTEGER, protein REAL, fat REAL, carbs REAL, createdAt INTEGER)';
const SQL_CREATE_FAVORITE_FOOD_TABLE = 'CREATE TABLE IF NOT EXISTS favorite_food (id TEXT PRIMARY KEY, name TEXT, energy INTEGER, defaultAmount TEXT, categoryId INTEGER, createdAt INTEGER)';
const SQL_CREATE_USER_PROFILE_TABLE = 'CREATE TABLE IF NOT EXISTS user_profile (id TEXT PRIMARY KEY, nickname TEXT, avatar TEXT, height REAL, weight REAL, targetGoal TEXT, targetEnergy INTEGER, diseaseTags TEXT, scoreWeight TEXT, lastBackupTime TEXT)';
const SQL_CREATE_USER_ACCOUNT_TABLE = 'CREATE TABLE IF NOT EXISTS user_account (userId INTEGER PRIMARY KEY AUTOINCREMENT, account TEXT UNIQUE, password TEXT, nickname TEXT, avatar TEXT, createdAt INTEGER)';

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
        await rdbStore.executeSql(SQL_CREATE_USER_PROFILE_TABLE);
        await rdbStore.executeSql(SQL_CREATE_USER_ACCOUNT_TABLE);
        await FoodDBHelper.cleanLegacySeedRecords();
        await FoodDBHelper.seedInitialFavoritesIfEmpty();
        await FoodDBHelper.seedInitialAccountIfEmpty();
        await FoodDBHelper.seedInitialProfileIfEmpty();
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

  static async getDietRecordsBetween(startDate: string, endDate: string): Promise<DietRecordItem[]> {
    if (!rdbStore) return [];
    let predicates = new relationalStore.RdbPredicates('diet_record');
    predicates.between('date', startDate, endDate);
    predicates.orderByAsc('date');
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
      console.error('FoodDBHelper', 'Query diet records between failed', err);
    }
    return list;
  }

  static async getAllDietRecords(): Promise<DietRecordItem[]> {
    if (!rdbStore) return [];
    let predicates = new relationalStore.RdbPredicates('diet_record');
    predicates.orderByAsc('date');
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
      console.error('FoodDBHelper', 'Query all diet records failed', err);
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

  static async getFavoriteNames(): Promise<string[]> {
    if (!rdbStore) return [];
    let predicates = new relationalStore.RdbPredicates('favorite_food');
    let list: string[] = [];
    try {
      let resultSet = await rdbStore.query(predicates, ['name']);
      while (resultSet.goToNextRow()) {
        list.push(resultSet.getString(resultSet.getColumnIndex('name')));
      }
      resultSet.close();
    } catch (err) {
      console.error('FoodDBHelper', 'Query favorite names failed', err);
    }
    return list;
  }

  static async toggleFavorite(name: string, energy: number, defaultAmount: string = '100g', categoryId: number = 0): Promise<boolean> {
    if (!rdbStore) return false;
    let names = await FoodDBHelper.getFavoriteNames();
    if (names.indexOf(name) !== -1) {
      await FoodDBHelper.deleteFavoriteFood(name);
      return false;
    } else {
      await FoodDBHelper.insertFavoriteFood({
        id: `fav_${Date.now()}`,
        name: name,
        energy: energy,
        defaultAmount: defaultAmount,
        categoryId: categoryId,
        createdAt: Date.now()
      });
      return true;
    }
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

  // 恢复预置数据别名
  static async reseedPresets(): Promise<void> {
    await FoodDBHelper.seedInitialFavoritesIfEmpty();
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
    await FoodDBHelper.seedInitialProfileIfEmpty();
  }

  // 档案管理与数据导出
  static async seedInitialProfileIfEmpty(): Promise<void> {
    if (!rdbStore) return;
    try {
      let pred = new relationalStore.RdbPredicates('user_profile');
      let res = await rdbStore.query(pred, ['id']);
      let count = res.rowCount;
      res.close();
      if (count === 0) {
        await FoodDBHelper.saveUserProfile({
          id: '10000',
          nickname: '健康探索者',
          avatar: '🍎',
          height: 175,
          weight: 70,
          targetGoal: '减重 5kg',
          targetEnergy: 2100,
          diseaseTags: '高尿酸 / 轻度脂肪肝',
          scoreWeight: '已调高风险指标',
          lastBackupTime: '昨天'
        });
      }
    } catch (err) {
      console.error('FoodDBHelper', 'Seed profile failed', err);
    }
  }

  static async seedInitialAccountIfEmpty(): Promise<void> {
    if (!rdbStore) return;
    try {
      let pred = new relationalStore.RdbPredicates('user_account');
      let res = await rdbStore.query(pred, ['userId']);
      let count = res.rowCount;
      res.close();
      if (count === 0) {
        const bucket: relationalStore.ValuesBucket = {
          'userId': 10000,
          'account': '健康探索者',
          'password': '123456',
          'nickname': '健康探索者',
          'avatar': '🍎',
          'createdAt': Date.now()
        };
        await rdbStore.insert('user_account', bucket);
      }
    } catch (err) {
      console.error('FoodDBHelper', 'Seed user account failed', err);
    }
  }

  static async getUserProfile(): Promise<UserProfile> {
    let def: UserProfile = {
      id: '10000',
      nickname: '健康探索者',
      avatar: '🍎',
      height: 175,
      weight: 70,
      targetGoal: '减重 5kg',
      targetEnergy: 2100,
      diseaseTags: '高尿酸 / 轻度脂肪肝',
      scoreWeight: '已调高风险指标',
      lastBackupTime: '昨天'
    };
    if (!rdbStore) return def;
    try {
      let pred = new relationalStore.RdbPredicates('user_profile');
      let resultSet = await rdbStore.query(pred, ['id', 'nickname', 'avatar', 'height', 'weight', 'targetGoal', 'targetEnergy', 'diseaseTags', 'scoreWeight', 'lastBackupTime']);
      if (resultSet.goToNextRow()) {
        let loadedId = resultSet.getString(resultSet.getColumnIndex('id'));
        if (loadedId === 'default_user') {
          loadedId = '10000';
        }
        let p: UserProfile = {
          id: loadedId,
          nickname: resultSet.getString(resultSet.getColumnIndex('nickname')),
          avatar: resultSet.getString(resultSet.getColumnIndex('avatar')),
          height: resultSet.getDouble(resultSet.getColumnIndex('height')),
          weight: resultSet.getDouble(resultSet.getColumnIndex('weight')),
          targetGoal: resultSet.getString(resultSet.getColumnIndex('targetGoal')),
          targetEnergy: resultSet.getLong(resultSet.getColumnIndex('targetEnergy')),
          diseaseTags: resultSet.getString(resultSet.getColumnIndex('diseaseTags')),
          scoreWeight: resultSet.getString(resultSet.getColumnIndex('scoreWeight')),
          lastBackupTime: resultSet.getString(resultSet.getColumnIndex('lastBackupTime'))
        };
        resultSet.close();
        return p;
      }
      resultSet.close();
    } catch (err) {
      console.error('FoodDBHelper', 'getUserProfile failed', err);
    }
    return def;
  }

  static async saveUserProfile(profile: UserProfile): Promise<void> {
    if (!rdbStore) return;
    const valueBucket: relationalStore.ValuesBucket = {
      'id': profile.id || '10000',
      'nickname': profile.nickname || '健康探索者',
      'avatar': profile.avatar || '🍎',
      'height': profile.height || 175,
      'weight': profile.weight || 70,
      'targetGoal': profile.targetGoal || '保持健康',
      'targetEnergy': profile.targetEnergy || 2100,
      'diseaseTags': profile.diseaseTags || '',
      'scoreWeight': profile.scoreWeight || '均衡模式',
      'lastBackupTime': profile.lastBackupTime || '未备份'
    };
    try {
      let pred = new relationalStore.RdbPredicates('user_profile');
      pred.equalTo('id', valueBucket['id'] as string);
      let res = await rdbStore.query(pred, ['id']);
      let exists = res.rowCount > 0;
      res.close();
      if (exists) {
        await rdbStore.update(valueBucket, pred);
      } else {
        await rdbStore.insert('user_profile', valueBucket);
      }
    } catch (err) {
      console.error('FoodDBHelper', 'saveUserProfile failed', err);
    }
  }

  static async loginByName(name: string, pass: string): Promise<LoginResult> {
    if (!rdbStore) return { success: false, message: '数据库未就绪' };
    let cleanName = name.trim();
    let cleanPass = pass.trim();
    try {
      let pred = new relationalStore.RdbPredicates('user_account');
      pred.equalTo('nickname', cleanName).or().equalTo('account', cleanName);
      let res = await rdbStore.query(pred, ['userId', 'account', 'password', 'nickname', 'avatar', 'createdAt']);
      if (res.goToNextRow()) {
        let savedPass = res.getString(res.getColumnIndex('password'));
        if (savedPass !== cleanPass) {
          res.close();
          return { success: false, message: '密码错误，请重新输入' };
        }
        let u: UserAccount = {
          userId: res.getLong(res.getColumnIndex('userId')),
          account: res.getString(res.getColumnIndex('account')),
          password: savedPass,
          nickname: res.getString(res.getColumnIndex('nickname')),
          avatar: res.getString(res.getColumnIndex('avatar')),
          createdAt: res.getLong(res.getColumnIndex('createdAt'))
        };
        res.close();
        let p = await FoodDBHelper.getUserProfile();
        p.id = u.userId.toString();
        p.nickname = u.nickname;
        p.avatar = u.avatar;
        await FoodDBHelper.saveUserProfile(p);
        return { success: true, user: u, isNew: false };
      }
      res.close();

      // 用户名不存在，自动创建新账号并分配自增 ID (10000, 10001...)
      let now = Date.now();
      const bucket: relationalStore.ValuesBucket = {
        'account': cleanName,
        'password': cleanPass,
        'nickname': cleanName,
        'avatar': '🍎',
        'createdAt': now
      };
      let rowId = await rdbStore.insert('user_account', bucket);
      let newUser: UserAccount = {
        userId: rowId,
        account: cleanName,
        password: cleanPass,
        nickname: cleanName,
        avatar: '🍎',
        createdAt: now
      };
      let p = await FoodDBHelper.getUserProfile();
      p.id = rowId.toString();
      p.nickname = cleanName;
      p.avatar = '🍎';
      await FoodDBHelper.saveUserProfile(p);
      return { success: true, user: newUser, isNew: true };
    } catch (err) {
      console.error('FoodDBHelper', 'loginByName failed', err);
      return { success: false, message: '登录失败，请稍后重试' };
    }
  }

  static async loginUser(account: string, pass: string): Promise<UserAccount | null> {
    if (!rdbStore) return null;
    try {
      let pred = new relationalStore.RdbPredicates('user_account');
      pred.equalTo('account', account.trim());
      pred.equalTo('password', pass.trim());
      let res = await rdbStore.query(pred, ['userId', 'account', 'password', 'nickname', 'avatar', 'createdAt']);
      if (res.goToNextRow()) {
        let u: UserAccount = {
          userId: res.getLong(res.getColumnIndex('userId')),
          account: res.getString(res.getColumnIndex('account')),
          password: res.getString(res.getColumnIndex('password')),
          nickname: res.getString(res.getColumnIndex('nickname')),
          avatar: res.getString(res.getColumnIndex('avatar')),
          createdAt: res.getLong(res.getColumnIndex('createdAt'))
        };
        res.close();
        // 更新当前主 profile
        let p = await FoodDBHelper.getUserProfile();
        p.id = u.userId.toString();
        p.nickname = u.nickname;
        p.avatar = u.avatar;
        await FoodDBHelper.saveUserProfile(p);
        return u;
      }
      res.close();
    } catch (err) {
      console.error('FoodDBHelper', 'loginUser failed', err);
    }
    return null;
  }

  static async registerUser(account: string, pass: string, nickname?: string, avatar?: string): Promise<UserAccount | null> {
    if (!rdbStore) return null;
    try {
      let nick = nickname && nickname.trim() !== '' ? nickname.trim() : '健康新星';
      let av = avatar || '🥗';
      let now = Date.now();
      const bucket: relationalStore.ValuesBucket = {
        'account': account.trim(),
        'password': pass.trim(),
        'nickname': nick,
        'avatar': av,
        'createdAt': now
      };
      let rowId = await rdbStore.insert('user_account', bucket);
      let u: UserAccount = {
        userId: rowId,
        account: account.trim(),
        password: pass.trim(),
        nickname: nick,
        avatar: av,
        createdAt: now
      };
      let p = await FoodDBHelper.getUserProfile();
      p.id = rowId.toString();
      p.nickname = nick;
      p.avatar = av;
      await FoodDBHelper.saveUserProfile(p);
      return u;
    } catch (err) {
      console.error('FoodDBHelper', 'registerUser failed', err);
      return null;
    }
  }

  static async deleteAccount(): Promise<void> {
    if (!rdbStore) return;
    try {
      let p = await FoodDBHelper.getUserProfile();
      let uid = parseInt(p.id) || 10000;
      let predAcc = new relationalStore.RdbPredicates('user_account');
      predAcc.equalTo('userId', uid);
      await rdbStore.delete(predAcc);

      // 清空用户饮食记录与收藏
      await FoodDBHelper.clearAllDietRecords();
      let predFav = new relationalStore.RdbPredicates('favorite_food');
      await rdbStore.delete(predFav);

      // 重置资料为初始状态
      let def: UserProfile = {
        id: '10000',
        nickname: '健康探索者',
        avatar: '🍎',
        height: 175,
        weight: 70,
        targetGoal: '减重 5kg',
        targetEnergy: 2100,
        diseaseTags: '无特殊疾病',
        scoreWeight: '均衡模式',
        lastBackupTime: '未备份'
      };
      await FoodDBHelper.saveUserProfile(def);
    } catch (err) {
      console.error('FoodDBHelper', 'deleteAccount failed', err);
    }
  }

  static async exportAllDataAsJson(): Promise<string> {
    let profile = await FoodDBHelper.getUserProfile();
    let records = await FoodDBHelper.getAllDietRecords();
    let favorites = await FoodDBHelper.getFavoriteFoods();
    let customFoods = await FoodDBHelper.getCustomFoods();

    // 更新备份时间
    let now = new Date();
    let month = now.getMonth() + 1;
    let day = now.getDate();
    let hours = now.getHours().toString().padStart(2, '0');
    let minutes = now.getMinutes().toString().padStart(2, '0');
    profile.lastBackupTime = `今天 ${hours}:${minutes}`;
    await FoodDBHelper.saveUserProfile(profile);

    let exportObj: Record<string, Object> = {
      'version': '1.0.0',
      'exportTime': now.toISOString(),
      'profile': profile as Object,
      'dietRecordsCount': records.length as Object,
      'dietRecords': records as Object,
      'favoriteFoods': favorites as Object,
      'customFoods': customFoods as Object
    };
    return JSON.stringify(exportObj, null, 2);
  }

  static async exportAllDataAsCsv(): Promise<string> {
    let records = await FoodDBHelper.getAllDietRecords();
    let header = '日期,餐段,食物名称,份量,摄入热量(kcal),蛋白质(g),脂肪(g),碳水(g)\n';
    let rows = records.map((r: DietRecordItem) => {
      let date = r.date || '';
      let meal = r.mealType || '';
      let name = (r.foodName || '').replace(/,/g, '，');
      let amt = (r.amount || '').replace(/,/g, ' ');
      let cal = r.energy || 0;
      let p = r.protein || 0;
      let f = r.fat || 0;
      let c = r.carbs || 0;
      return `${date},${meal},${name},${amt},${cal},${p},${f},${c}`;
    }).join('\n');
    return header + rows;
  }

  static async updateBackupTime(): Promise<string> {
    let profile = await FoodDBHelper.getUserProfile();
    let now = new Date();
    let hours = now.getHours().toString().padStart(2, '0');
    let minutes = now.getMinutes().toString().padStart(2, '0');
    let timeStr = `今天 ${hours}:${minutes}`;
    profile.lastBackupTime = timeStr;
    await FoodDBHelper.saveUserProfile(profile);
    return timeStr;
  }
}
