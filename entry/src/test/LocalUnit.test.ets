import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium';
import { NutritionCalculator } from '../main/ets/common/utils/NutritionCalculator';
import { DietRecordItem, UserProfile, cloneUserProfile } from '../main/ets/common/models/FoodItem';

export default function localUnitTest() {
  describe('localUnitTest', () => {
    // Defines a test suite. Two parameters are supported: test suite name and test suite function.
    beforeAll(() => {
      // Presets an action, which is performed only once before all test cases of the test suite start.
      // This API supports only one parameter: preset action function.
    });
    beforeEach(() => {
      // Presets an action, which is performed before each unit test case starts.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: preset action function.
    });
    afterEach(() => {
      // Presets a clear action, which is performed after each unit test case ends.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: clear action function.
    });
    afterAll(() => {
      // Presets a clear action, which is performed after all test cases of the test suite end.
      // This API supports only one parameter: clear action function.
    });
    it('assertContain', 0, () => {
      // Defines a test case. This API supports three parameters: test case name, filter parameter, and test case function.
      let a = 'abc';
      let b = 'b';
      // Defines a variety of assertion methods, which are used to declare expected boolean conditions.
      expect(a).assertContain(b);
      expect(a).assertEqual(a);
    });

    it('profileCloneIsIndependent', 0, () => {
      let original: UserProfile = {
        id: '10000', nickname: '测试用户', avatar: '🍎', height: 175, weight: 70,
        targetGoal: '维持健康体重', targetEnergy: 2100, diseaseTags: '',
        scoreWeight: '均衡健康模式', lastBackupTime: '未备份'
      };
      let cloned = cloneUserProfile(original);
      cloned.targetEnergy = 1600;
      expect(original.targetEnergy).assertEqual(2100);
      expect(cloned.targetEnergy).assertEqual(1600);
    });

    it('healthGoalChangesMacroTargets', 0, () => {
      let maintain = NutritionCalculator.calculateTargetMacros(2000, '维持健康体重');
      let muscle = NutritionCalculator.calculateTargetMacros(2000, '增肌塑形');
      expect(maintain.protein).assertEqual(90);
      expect(muscle.protein).assertEqual(125);
      expect(muscle.carbs).assertEqual(250);
    });

    it('riskWeightChangesHealthScore', 0, () => {
      let record: DietRecordItem = {
        id: 'risk-test', date: '2026-09-11', mealType: '午餐', foodName: '猪肝',
        amount: '200g', energy: 260, protein: 38.6, fat: 7, carbs: 10, createdAt: 1
      };
      let balanced: UserProfile = {
        id: '10000', nickname: '测试用户', avatar: '🍎', height: 175, weight: 70,
        targetGoal: '维持健康体重', targetEnergy: 2100, diseaseTags: '高尿酸 / 轻度脂肪肝',
        scoreWeight: '均衡健康模式', lastBackupTime: '未备份'
      };
      let riskFocused = cloneUserProfile(balanced);
      riskFocused.scoreWeight = '已调高风险指标';
      let balancedScore = NutritionCalculator.calculateHealthScore([record], '今日', balanced);
      let riskScore = NutritionCalculator.calculateHealthScore([record], '今日', riskFocused);
      expect(riskScore.score < balancedScore.score).assertTrue();
    });
  });
}
