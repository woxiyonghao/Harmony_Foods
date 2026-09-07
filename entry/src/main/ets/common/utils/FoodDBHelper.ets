import relationalStore from '@ohos.data.relationalStore';
import { FoodItem } from '../../view/food/FoodLibraryView';

const STORE_CONFIG: relationalStore.StoreConfig = {
  name: 'HarmonyFoods.db',
  securityLevel: relationalStore.SecurityLevel.S1
};

const SQL_CREATE_TABLE = 'CREATE TABLE IF NOT EXISTS custom_food (id TEXT PRIMARY KEY, categoryId INTEGER, name TEXT, energy INTEGER, tags TEXT, protein REAL, fat REAL, carbs REAL)';

let rdbStore: relationalStore.RdbStore | null = null;

export class FoodDBHelper {
  static async init(context: Context): Promise<void> {
    if (rdbStore) {
      return;
    }
    try {
      rdbStore = await relationalStore.getRdbStore(context, STORE_CONFIG);
      if (rdbStore) {
        await rdbStore.executeSql(SQL_CREATE_TABLE);
      }
    } catch (err) {
      console.error('FoodDBHelper', 'Init RDB failed', err);
    }
  }

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
}
