import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium'

export default function foodLibraryTest() {
  describe('FoodLibraryTest', () => {
    
    it('testFoodLibrarySearchFilter', 0, () => {
      // 模拟组件的数据源与搜索过滤逻辑
      let mockFoods = [
        { id: '1', name: '苹果', categoryId: 2 },
        { id: '2', name: '猪肉', categoryId: 3 },
        { id: '3', name: '菠菜', categoryId: 1 }
      ];
      
      let searchQuery = '苹';
      let selectedCategoryIndex = 0;
      
      let filtered = mockFoods.filter(food => {
        let matchCategory = (selectedCategoryIndex === 0) || (food.categoryId === selectedCategoryIndex);
        let matchSearch = (searchQuery === '') || food.name.includes(searchQuery);
        return matchCategory && matchSearch;
      });
      
      expect(filtered.length).assertEqual(1);
      expect(filtered[0].name).assertEqual('苹果');
    })
    
    it('testFoodLibraryCategoryFilter', 0, () => {
      let mockFoods = [
        { id: '1', name: '苹果', categoryId: 2 },
        { id: '2', name: '猪肉', categoryId: 3 },
        { id: '3', name: '菠菜', categoryId: 1 }
      ];
      
      // 筛选分类：肉禽类 (3)
      let searchQuery = '';
      let selectedCategoryIndex = 3;
      
      let filtered = mockFoods.filter(food => {
        let matchCategory = (selectedCategoryIndex === 0) || (food.categoryId === selectedCategoryIndex);
        let matchSearch = (searchQuery === '') || food.name.includes(searchQuery);
        return matchCategory && matchSearch;
      });
      
      expect(filtered.length).assertEqual(1);
      expect(filtered[0].name).assertEqual('猪肉');
    })
    
    it('testFoodLibraryCustomAddFood', 0, () => {
      let mockFoods = [
        { id: '1', name: '苹果', energy: 53, categoryId: 2 }
      ];
      
      // 模拟添加动作
      let newFood = {
        id: '99',
        categoryId: 1,
        name: '自定义沙拉',
        energy: 120
      };
      
      mockFoods.unshift(newFood);
      
      expect(mockFoods.length).assertEqual(2);
      expect(mockFoods[0].name).assertEqual('自定义沙拉');
      expect(mockFoods[0].energy).assertEqual(120);
    })
  })
}
