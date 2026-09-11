import { DietRecordItem, FoodItem, UserProfile } from '../models/FoodItem';
import { DEFAULT_FOODS } from './FoodDBHelper';

export interface TargetMacroGoals {
  carbs: number;    // g
  protein: number;  // g
  fat: number;      // g
}

export interface MacroNutrientSummary {
  label: string;
  totalEnergy: number;
  carbsGrams: number;
  proteinGrams: number;
  fatGrams: number;
  carbsPercent: number;
  proteinPercent: number;
  fatPercent: number;
  recordCount: number;
}

export interface RiskNutrientSummary {
  label: string;
  purine: number;       // mg
  sodium: number;       // mg
  cholesterol: number;  // mg
  recordCount: number;
}

export interface ScoreSummary {
  label: string;
  score: number;
  evaluation: string;
  recordCount: number;
}

export interface BaseNutrientProfile {
  name: string;
  energy: number;      // kcal per 100g
  protein: number;     // g per 100g
  fat: number;         // g per 100g
  carbs: number;       // g per 100g
  purine: number;      // mg per 100g
  sodium: number;      // mg per 100g
  cholesterol: number; // mg per 100g
}

export interface CalculatedNutrients {
  energy: number;
  carbs: number;
  protein: number;
  fat: number;
  purine: number;
  sodium: number;
  cholesterol: number;
}

const KNOWN_FOOD_PROFILES: BaseNutrientProfile[] = [
  { name: '苹果', energy: 53, protein: 0.2, fat: 0.2, carbs: 13.8, purine: 5, sodium: 2, cholesterol: 0 },
  { name: '香蕉', energy: 93, protein: 1.4, fat: 0.2, carbs: 22.0, purine: 3, sodium: 1, cholesterol: 0 },
  { name: '菠菜', energy: 28, protein: 2.9, fat: 0.4, carbs: 3.6, purine: 25, sodium: 70, cholesterol: 0 },
  { name: '纯牛奶', energy: 66, protein: 3.2, fat: 3.8, carbs: 4.8, purine: 5, sodium: 50, cholesterol: 15 },
  { name: '全脂牛奶', energy: 62, protein: 3.3, fat: 3.6, carbs: 4.8, purine: 5, sodium: 50, cholesterol: 15 },
  { name: '全麦面包', energy: 247, protein: 8.5, fat: 3.4, carbs: 46.0, purine: 15, sodium: 450, cholesterol: 0 },
  { name: '米饭', energy: 116, protein: 2.6, fat: 0.3, carbs: 25.9, purine: 18, sodium: 5, cholesterol: 0 },
  { name: '西红柿炒鸡蛋', energy: 120, protein: 5.2, fat: 8.1, carbs: 6.5, purine: 40, sodium: 420, cholesterol: 180 },
  { name: '水煮蛋', energy: 143, protein: 13.3, fat: 8.8, carbs: 2.8, purine: 10, sodium: 140, cholesterol: 370 },
  { name: '猪肉', energy: 143, protein: 20.3, fat: 6.2, carbs: 1.5, purine: 150, sodium: 65, cholesterol: 70 },
  { name: '猪肝', energy: 130, protein: 19.3, fat: 3.5, carbs: 5.0, purine: 275, sodium: 80, cholesterol: 288 },
  { name: '鸡胸肉', energy: 133, protein: 24.6, fat: 1.9, carbs: 2.5, purine: 140, sodium: 70, cholesterol: 65 }
];

export class NutritionCalculator {
  /**
   * 解析克重，如 "100g" -> 100, "250ml" -> 250
   */
  static parseWeight(amountStr: string): number {
    if (!amountStr) return 100;
    let num = parseFloat(amountStr.replace(/[^0-9.]/g, ''));
    return isNaN(num) || num <= 0 ? 100 : num;
  }

  /**
   * 根据食物名称匹配或推断单品营养参数 (每100g)
   */
  static getProfileByFoodName(foodName: string): BaseNutrientProfile {
    let cleanName = foodName.toLowerCase();
    for (let p of KNOWN_FOOD_PROFILES) {
      if (cleanName.includes(p.name.toLowerCase())) {
        return p;
      }
    }

    // 尝试在系统默认食物中查找
    for (let f of DEFAULT_FOODS) {
      if (cleanName.includes(f.name.toLowerCase()) || f.name.toLowerCase().includes(cleanName)) {
        let res: BaseNutrientProfile = {
          name: f.name,
          energy: f.energy,
          protein: f.protein || 5,
          fat: f.fat || 3,
          carbs: f.carbs || 15,
          purine: 25,
          sodium: 100,
          cholesterol: 10
        };
        return res;
      }
    }

    // 通用关键词推断
    if (cleanName.includes('蛋')) {
      let res: BaseNutrientProfile = { name: foodName, energy: 140, protein: 12, fat: 9, carbs: 3, purine: 15, sodium: 150, cholesterol: 250 };
      return res;
    }
    if (cleanName.includes('肉') || cleanName.includes('牛') || cleanName.includes('羊') || cleanName.includes('猪')) {
      let res: BaseNutrientProfile = { name: foodName, energy: 160, protein: 18, fat: 10, carbs: 2, purine: 140, sodium: 80, cholesterol: 70 };
      return res;
    }
    if (cleanName.includes('鱼') || cleanName.includes('虾') || cleanName.includes('海鲜')) {
      let res: BaseNutrientProfile = { name: foodName, energy: 110, protein: 18, fat: 2, carbs: 1, purine: 160, sodium: 120, cholesterol: 90 };
      return res;
    }
    if (cleanName.includes('奶') || cleanName.includes('拿铁')) {
      let res: BaseNutrientProfile = { name: foodName, energy: 65, protein: 3.2, fat: 3.6, carbs: 5, purine: 5, sodium: 50, cholesterol: 15 };
      return res;
    }
    if (cleanName.includes('饭') || cleanName.includes('面') || cleanName.includes('包') || cleanName.includes('粥')) {
      let res: BaseNutrientProfile = { name: foodName, energy: 130, protein: 3, fat: 1, carbs: 28, purine: 15, sodium: 100, cholesterol: 0 };
      return res;
    }
    if (cleanName.includes('菜') || cleanName.includes('果') || cleanName.includes('沙拉')) {
      let res: BaseNutrientProfile = { name: foodName, energy: 40, protein: 1.5, fat: 0.5, carbs: 8, purine: 10, sodium: 30, cholesterol: 0 };
      return res;
    }

    // 默认基准
    let def: BaseNutrientProfile = { name: foodName, energy: 100, protein: 4, fat: 3, carbs: 15, purine: 20, sodium: 100, cholesterol: 10 };
    return def;
  }

  /**
   * 计算单条饮食记录的具体营养值 (实际摄入量)
   */
  static calculateRecordNutrients(record: DietRecordItem): CalculatedNutrients {
    let weight = NutritionCalculator.parseWeight(record.amount);
    let ratio = weight / 100;
    let profile = NutritionCalculator.getProfileByFoodName(record.foodName);

    let energy = record.energy > 0 ? record.energy : Math.round(profile.energy * ratio);
    let carbs = record.carbs && record.carbs > 0 ? record.carbs : Math.round(profile.carbs * ratio * 10) / 10;
    let protein = record.protein && record.protein > 0 ? record.protein : Math.round(profile.protein * ratio * 10) / 10;
    let fat = record.fat && record.fat > 0 ? record.fat : Math.round(profile.fat * ratio * 10) / 10;

    let purine = Math.round(profile.purine * ratio);
    let sodium = Math.round(profile.sodium * ratio);
    let cholesterol = Math.round(profile.cholesterol * ratio);

    let res: CalculatedNutrients = {
      energy: energy,
      carbs: carbs,
      protein: protein,
      fat: fat,
      purine: purine,
      sodium: sodium,
      cholesterol: cholesterol
    };
    return res;
  }

  /**
   * 聚合一组记录为三大营养素摘要
   */
  static aggregateMacros(label: string, records: DietRecordItem[]): MacroNutrientSummary {
    if (records.length === 0) {
      let emptyRes: MacroNutrientSummary = {
        label: label,
        totalEnergy: 0,
        carbsGrams: 0,
        proteinGrams: 0,
        fatGrams: 0,
        carbsPercent: 0,
        proteinPercent: 0,
        fatPercent: 0,
        recordCount: 0
      };
      return emptyRes;
    }

    let totalEnergy = 0;
    let totalCarbs = 0;
    let totalProtein = 0;
    let totalFat = 0;

    for (let r of records) {
      let n = NutritionCalculator.calculateRecordNutrients(r);
      totalEnergy += n.energy;
      totalCarbs += n.carbs;
      totalProtein += n.protein;
      totalFat += n.fat;
    }

    // 供能比计算: 碳水 4kcal/g, 蛋白 4kcal/g, 脂肪 9kcal/g
    let carbsKcal = totalCarbs * 4;
    let proteinKcal = totalProtein * 4;
    let fatKcal = totalFat * 9;
    let sumMacroKcal = carbsKcal + proteinKcal + fatKcal;

    let carbsPercent = 0;
    let proteinPercent = 0;
    let fatPercent = 0;

    if (sumMacroKcal > 0) {
      carbsPercent = Math.round((carbsKcal / sumMacroKcal) * 100);
      proteinPercent = Math.round((proteinKcal / sumMacroKcal) * 100);
      fatPercent = Math.max(0, 100 - carbsPercent - proteinPercent);
    }

    let summary: MacroNutrientSummary = {
      label: label,
      totalEnergy: Math.round(totalEnergy),
      carbsGrams: Math.round(totalCarbs * 10) / 10,
      proteinGrams: Math.round(totalProtein * 10) / 10,
      fatGrams: Math.round(totalFat * 10) / 10,
      carbsPercent: carbsPercent,
      proteinPercent: proteinPercent,
      fatPercent: fatPercent,
      recordCount: records.length
    };
    return summary;
  }

  /**
   * 聚合一组记录为风险指标 (嘌呤、钠、胆固醇)
   */
  static aggregateRisks(label: string, records: DietRecordItem[]): RiskNutrientSummary {
    let purine = 0;
    let sodium = 0;
    let cholesterol = 0;

    for (let r of records) {
      let n = NutritionCalculator.calculateRecordNutrients(r);
      purine += n.purine;
      sodium += n.sodium;
      cholesterol += n.cholesterol;
    }

    let res: RiskNutrientSummary = {
      label: label,
      purine: Math.round(purine),
      sodium: Math.round(sodium),
      cholesterol: Math.round(cholesterol),
      recordCount: records.length
    };
    return res;
  }

  /**
   * 根据目标能量与健康目标动态推荐三大宏量营养素克数
   */
  static calculateTargetMacros(targetEnergy: number, targetGoal: string = '维持健康体重'): TargetMacroGoals {
    let energy = targetEnergy > 0 ? targetEnergy : 2100;
    let carbsRatio = 0.55;  // 55%
    let proteinRatio = 0.18; // 18%
    let fatRatio = 0.27;    // 27%

    if (targetGoal.includes('增肌')) {
      carbsRatio = 0.50;
      proteinRatio = 0.25;
      fatRatio = 0.25;
    } else if (targetGoal.includes('减重')) {
      carbsRatio = 0.45;
      proteinRatio = 0.25;
      fatRatio = 0.30;
    } else if (targetGoal.includes('尿酸') || targetGoal.includes('痛风')) {
      carbsRatio = 0.60;
      proteinRatio = 0.15;
      fatRatio = 0.25;
    } else if (targetGoal.includes('低脂') || targetGoal.includes('胆固醇')) {
      carbsRatio = 0.60;
      proteinRatio = 0.20;
      fatRatio = 0.20;
    } else if (targetGoal.includes('血压') || targetGoal.includes('控盐')) {
      carbsRatio = 0.55;
      proteinRatio = 0.20;
      fatRatio = 0.25;
    }

    let carbsGrams = Math.round((energy * carbsRatio) / 4);
    let proteinGrams = Math.round((energy * proteinRatio) / 4);
    let fatGrams = Math.round((energy * fatRatio) / 9);

    return {
      carbs: carbsGrams,
      protein: proteinGrams,
      fat: fatGrams
    };
  }

  /**
   * 计算健康评分 (0 - 100)，支持联动用户个性化疾病标签与自定义评分维度权重
   */
  static calculateHealthScore(records: DietRecordItem[], label: string, profile?: UserProfile): ScoreSummary {
    if (records.length === 0) {
      let emptyScore: ScoreSummary = {
        label: label,
        score: 0,
        evaluation: '暂无饮食记录',
        recordCount: 0
      };
      return emptyScore;
    }

    let macro = NutritionCalculator.aggregateMacros(label, records);
    let risk = NutritionCalculator.aggregateRisks(label, records);

    let score = 90; // 基础达标分
    let scoreWeight = profile ? (profile.scoreWeight || '均衡健康模式') : '均衡健康模式';
    let diseaseTags = profile ? (profile.diseaseTags || '') : '';

    // 权重模式系数
    let isRiskFocused = scoreWeight.includes('调高风险') || scoreWeight.includes('风险指标');
    let isMacroFocused = scoreWeight.includes('宏量') || scoreWeight.includes('营养优先');

    // 疾病标签警戒阈值适配
    let purineThreshold = 300;
    let sodiumThreshold = 2000;
    let cholesterolThreshold = 300;

    if (diseaseTags.includes('尿酸') || diseaseTags.includes('痛风')) {
      purineThreshold = 200;
    }
    if (diseaseTags.includes('高血压') || diseaseTags.includes('控盐')) {
      sodiumThreshold = 1500;
    }
    if (diseaseTags.includes('高血脂') || diseaseTags.includes('脂肪肝')) {
      cholesterolThreshold = 200;
    }

    // 宏量供能比评估
    let fatPenalty = isMacroFocused ? 12 : 8;
    let proteinPenalty = isMacroFocused ? 10 : 6;

    if (macro.fatPercent > 35) score -= fatPenalty;
    if (macro.fatPercent > 45) score -= (fatPenalty - 2);
    if (macro.proteinPercent < 12) score -= proteinPenalty;
    if (macro.proteinPercent >= 18 && macro.proteinPercent <= 25) score += 4;

    // 风险指标超标评估
    let riskPenalty = isRiskFocused ? 18 : 12;
    let warnings: string[] = [];

    if (risk.purine > purineThreshold) {
      score -= riskPenalty;
      warnings.push(diseaseTags.includes('尿酸') ? '嘌呤超过个性化警戒线' : '嘌呤偏高');
    }
    if (risk.sodium > sodiumThreshold) {
      score -= riskPenalty;
      warnings.push(diseaseTags.includes('血压') ? '钠盐超过控盐警戒线' : '钠盐超标');
    }
    if (risk.cholesterol > cholesterolThreshold) {
      score -= Math.round(riskPenalty * 0.85);
      warnings.push(diseaseTags.includes('血脂') ? '胆固醇超标' : '胆固醇偏高');
    }

    score = Math.max(50, Math.min(98, score));

    // 生成评价文案
    let evalText = '营养摄入均衡，搭配合理';
    if (warnings.length > 0) {
      evalText = `${warnings.join('、')}，建议清淡并适度控制肉汤咸食`;
    } else if (macro.fatPercent > 35) {
      evalText = '油脂摄入略高，建议减少煎炸炒菜用油';
    } else if (macro.proteinPercent >= 18) {
      evalText = '优质蛋白质充足，各项代谢指标优良';
    }

    let finalRes: ScoreSummary = {
      label: label,
      score: score,
      evaluation: evalText,
      recordCount: records.length
    };
    return finalRes;
  }
}
