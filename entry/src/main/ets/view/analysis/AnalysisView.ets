import { AppTheme } from '../../common/constants/AppTheme'

import { DietRecordItem } from '../../common/models/FoodItem'
import { FoodDBHelper } from '../../common/utils/FoodDBHelper'
import { DateHelper } from '../../common/utils/DateHelper'

export interface NutritionBarData {
  label: string;
  carbsPercent: number;
  proteinPercent: number;
  fatPercent: number;
  carbsGrams: number;
  proteinGrams: number;
  fatGrams: number;
  totalEnergy: number;
}

export interface RiskBarData {
  label: string;
  value: number;
  threshold: number;
  isWarning: boolean;
  hint: string;
}

export interface ScoreBarData {
  label: string;
  score: number;
  evaluation: string;
}

export interface RiskTypeOption {
  key: string;
  name: string;
  unit: string;
  threshold: number;
  maxScale: number;
  desc: string;
}

@Component
export struct AnalysisView {
  @State timeMode: string = '周'; // '日' | '周' | '月'
  @State selectedRiskType: string = 'purine'; // 'purine' | 'sodium' | 'cholesterol'
  
  @State selectedNutritionIndex: number = -1;
  @State selectedRiskIndex: number = -1;
  @State selectedScoreIndex: number = -1;

  @State todayRecords: DietRecordItem[] = [];

  private timeModes: string[] = ['日', '周', '月'];
  private riskOptions: RiskTypeOption[] = [
    {
      key: 'purine',
      name: '嘌呤',
      unit: 'mg',
      threshold: 300,
      maxScale: 400,
      desc: '痛风与高尿酸关注指标，单日安全上限 300mg'
    },
    {
      key: 'sodium',
      name: '钠',
      unit: 'mg',
      threshold: 2000,
      maxScale: 2800,
      desc: '高血压关注指标，低盐饮食安全上限 2000mg'
    },
    {
      key: 'cholesterol',
      name: '胆固醇',
      unit: 'mg',
      threshold: 300,
      maxScale: 400,
      desc: '心血管健康指标，单日摄入建议控制在 300mg 以内'
    }
  ];

  async aboutToAppear() {
    let context = getContext(this);
    await FoodDBHelper.init(context);
    let todayKey = DateHelper.formatDateKey(new Date());
    this.todayRecords = await FoodDBHelper.getDietRecordsByDate(todayKey);
  }

  getCurrentRiskConfig(): RiskTypeOption {
    for (let opt of this.riskOptions) {
      if (opt.key === this.selectedRiskType) {
        return opt;
      }
    }
    return this.riskOptions[0];
  }

  getNutritionData(): NutritionBarData[] {
    if (this.timeMode === '日') {
      return [
        { label: '早餐', carbsPercent: 45, proteinPercent: 30, fatPercent: 25, carbsGrams: 48, proteinGrams: 18, fatGrams: 12, totalEnergy: 372 },
        { label: '午餐', carbsPercent: 55, proteinPercent: 25, fatPercent: 20, carbsGrams: 90, proteinGrams: 28, fatGrams: 16, totalEnergy: 616 },
        { label: '晚餐', carbsPercent: 40, proteinPercent: 35, fatPercent: 25, carbsGrams: 52, proteinGrams: 26, fatGrams: 14, totalEnergy: 438 },
        { label: '加餐', carbsPercent: 60, proteinPercent: 20, fatPercent: 20, carbsGrams: 22, proteinGrams: 4, fatGrams: 3, totalEnergy: 131 }
      ];
    } else if (this.timeMode === '月') {
      return [
        { label: '第1周', carbsPercent: 48, proteinPercent: 30, fatPercent: 22, carbsGrams: 220, proteinGrams: 75, fatGrams: 42, totalEnergy: 1840 },
        { label: '第2周', carbsPercent: 52, proteinPercent: 28, fatPercent: 20, carbsGrams: 245, proteinGrams: 72, fatGrams: 40, totalEnergy: 1910 },
        { label: '第3周', carbsPercent: 45, proteinPercent: 35, fatPercent: 20, carbsGrams: 210, proteinGrams: 88, fatGrams: 44, totalEnergy: 1880 },
        { label: '第4周', carbsPercent: 50, proteinPercent: 28, fatPercent: 22, carbsGrams: 230, proteinGrams: 70, fatGrams: 45, totalEnergy: 1860 }
      ];
    }

    return [
      { label: '一', carbsPercent: 40, proteinPercent: 30, fatPercent: 20, carbsGrams: 180, proteinGrams: 65, fatGrams: 38, totalEnergy: 1780 },
      { label: '二', carbsPercent: 50, proteinPercent: 20, fatPercent: 20, carbsGrams: 230, proteinGrams: 52, fatGrams: 41, totalEnergy: 1890 },
      { label: '三', carbsPercent: 45, proteinPercent: 35, fatPercent: 15, carbsGrams: 205, proteinGrams: 82, fatGrams: 32, totalEnergy: 1820 },
      { label: '四', carbsPercent: 30, proteinPercent: 40, fatPercent: 20, carbsGrams: 145, proteinGrams: 90, fatGrams: 40, totalEnergy: 1720 },
      { label: '五', carbsPercent: 60, proteinPercent: 20, fatPercent: 10, carbsGrams: 280, proteinGrams: 50, fatGrams: 25, totalEnergy: 2050 },
      { label: '六', carbsPercent: 40, proteinPercent: 40, fatPercent: 15, carbsGrams: 195, proteinGrams: 92, fatGrams: 35, totalEnergy: 1960 },
      { label: '日', carbsPercent: 55, proteinPercent: 25, fatPercent: 25, carbsGrams: 240, proteinGrams: 62, fatGrams: 48, totalEnergy: 1910 }
    ];
  }

  getRiskData(): RiskBarData[] {
    let cfg = this.getCurrentRiskConfig();

    if (this.timeMode === '日') {
      if (this.selectedRiskType === 'purine') {
        return [
          { label: '早餐', value: 35, threshold: 300, isWarning: false, hint: '牛奶面包，极低嘌呤' },
          { label: '午餐', value: 145, threshold: 300, isWarning: false, hint: '肉禽适量，处于安全线' },
          { label: '晚餐', value: 85, threshold: 300, isWarning: false, hint: '水煮蔬菜豆腐，低嘌呤' },
          { label: '加餐', value: 15, threshold: 300, isWarning: false, hint: '苹果水饮，安全' }
        ];
      } else if (this.selectedRiskType === 'sodium') {
        return [
          { label: '早餐', value: 420, threshold: 2000, isWarning: false, hint: '清淡早餐，钠摄入平稳' },
          { label: '午餐', value: 920, threshold: 2000, isWarning: false, hint: '炒菜咸度适中' },
          { label: '晚餐', value: 680, threshold: 2000, isWarning: false, hint: '清淡炖汤' },
          { label: '加餐', value: 60, threshold: 2000, isWarning: false, hint: '水果基本无钠' }
        ];
      } else {
        return [
          { label: '早餐', value: 95, threshold: 300, isWarning: false, hint: '含蛋类，胆固醇适中' },
          { label: '午餐', value: 120, threshold: 300, isWarning: false, hint: '瘦肉蛋白，控制良好' },
          { label: '晚餐', value: 65, threshold: 300, isWarning: false, hint: '清淡蔬菜搭配' },
          { label: '加餐', value: 0, threshold: 300, isWarning: false, hint: '无胆固醇' }
        ];
      }
    } else if (this.timeMode === '月') {
      if (this.selectedRiskType === 'purine') {
        return [
          { label: '第1周', value: 195, threshold: 300, isWarning: false, hint: '均值良好' },
          { label: '第2周', value: 240, threshold: 300, isWarning: false, hint: '周末略有上升' },
          { label: '第3周', value: 310, threshold: 300, isWarning: true, hint: '有聚餐导致单日嘌呤峰值超标' },
          { label: '第4周', value: 220, threshold: 300, isWarning: false, hint: '及时回归清淡饮食' }
        ];
      } else if (this.selectedRiskType === 'sodium') {
        return [
          { label: '第1周', value: 1680, threshold: 2000, isWarning: false, hint: '达标控盐' },
          { label: '第2周', value: 1850, threshold: 2000, isWarning: false, hint: '接近上限，建议少用酱料' },
          { label: '第3周', value: 2150, threshold: 2000, isWarning: true, hint: '聚餐重口导致钠超标' },
          { label: '第4周', value: 1720, threshold: 2000, isWarning: false, hint: '控盐恢复良好' }
        ];
      } else {
        return [
          { label: '第1周', value: 200, threshold: 300, isWarning: false, hint: '结构优良' },
          { label: '第2周', value: 230, threshold: 300, isWarning: false, hint: '摄入平稳' },
          { label: '第3周', value: 320, threshold: 300, isWarning: true, hint: '动物内脏与红肉较多' },
          { label: '第4周', value: 210, threshold: 300, isWarning: false, hint: '清淡恢复' }
        ];
      }
    }

    if (this.selectedRiskType === 'purine') {
      let rawVals: number[] = [150, 200, 320, 180, 120, 280, 190];
      let labels: string[] = ['一', '二', '三', '四', '五', '六', '日'];
      let result: RiskBarData[] = [];
      for (let i = 0; i < rawVals.length; i++) {
        let v = rawVals[i];
        result.push({
          label: labels[i],
          value: v,
          threshold: cfg.threshold,
          isWarning: v > cfg.threshold,
          hint: v > cfg.threshold ? '超标！可能引发痛风或关节不适，建议多喝水促进排泄' : '正常安全范围'
        });
      }
      return result;
    } else if (this.selectedRiskType === 'sodium') {
      let rawVals: number[] = [1400, 1650, 2250, 1800, 1500, 2100, 1750];
      let labels: string[] = ['一', '二', '三', '四', '五', '六', '日'];
      let result: RiskBarData[] = [];
      for (let i = 0; i < rawVals.length; i++) {
        let v = rawVals[i];
        result.push({
          label: labels[i],
          value: v,
          threshold: cfg.threshold,
          isWarning: v > cfg.threshold,
          hint: v > cfg.threshold ? '超标！钠摄入过高可能引起水肿与血压波动，建议清淡少盐' : '正常安全范围'
        });
      }
      return result;
    } else {
      let rawVals: number[] = [180, 210, 340, 190, 160, 260, 200];
      let labels: string[] = ['一', '二', '三', '四', '五', '六', '日'];
      let result: RiskBarData[] = [];
      for (let i = 0; i < rawVals.length; i++) {
        let v = rawVals[i];
        result.push({
          label: labels[i],
          value: v,
          threshold: cfg.threshold,
          isWarning: v > cfg.threshold,
          hint: v > cfg.threshold ? '超标！饱和脂肪与胆固醇过高，建议减少蛋黄与肥肉' : '正常安全范围'
        });
      }
      return result;
    }
  }

  getScoreData(): ScoreBarData[] {
    if (this.timeMode === '日') {
      return [
        { label: '早餐', score: 88, evaluation: '优质高钙营养搭配良好' },
        { label: '午餐', score: 82, evaluation: '碳水稍多，膳食纤维充足' },
        { label: '晚餐', score: 86, evaluation: '低脂清淡，热量把控优秀' },
        { label: '加餐', score: 92, evaluation: '新鲜低糖水果补充' }
      ];
    } else if (this.timeMode === '月') {
      return [
        { label: '第1周', score: 84, evaluation: '初期健康计划执行良好' },
        { label: '第2周', score: 86, evaluation: '营养摄入平稳达标' },
        { label: '第3周', score: 82, evaluation: '偶有单日嘌呤钠超标' },
        { label: '第4周', score: 88, evaluation: '严格自律，综合指标优秀' }
      ];
    }

    return [
      { label: '一', score: 80, evaluation: '基础摄入平衡，低脂良好' },
      { label: '二', score: 85, evaluation: '蛋白质达标，无超标指标' },
      { label: '三', score: 92, evaluation: '高纤维摄入优秀，但需注意嘌呤' },
      { label: '四', score: 78, evaluation: '高蛋白低碳水，注意补充优质蔬菜' },
      { label: '五', score: 88, evaluation: '低脂饮食达标，水分补充充足' },
      { label: '六', score: 95, evaluation: '营养黄金配比，各指标全绿' },
      { label: '日', score: 82, evaluation: '周末控盐良好，综合健康' }
    ];
  }

  getAverageScore(): number {
    let scores = this.getScoreData();
    if (scores.length === 0) return 0;
    let sum = 0;
    for (let s of scores) {
      sum += s.score;
    }
    return Math.round(sum / scores.length);
  }

  getWarningCount(): number {
    let risks = this.getRiskData();
    let count = 0;
    for (let r of risks) {
      if (r.isWarning) count++;
    }
    return count;
  }

  getSelectedNutritionItem(): NutritionBarData | null {
    let list = this.getNutritionData();
    if (this.selectedNutritionIndex >= 0 && this.selectedNutritionIndex < list.length) {
      return list[this.selectedNutritionIndex];
    }
    return null;
  }

  getSelectedRiskItem(): RiskBarData | null {
    let list = this.getRiskData();
    if (this.selectedRiskIndex >= 0 && this.selectedRiskIndex < list.length) {
      return list[this.selectedRiskIndex];
    }
    return null;
  }

  getSelectedScoreItem(): ScoreBarData | null {
    let list = this.getScoreData();
    if (this.selectedScoreIndex >= 0 && this.selectedScoreIndex < list.length) {
      return list[this.selectedScoreIndex];
    }
    return null;
  }

  build() {
    Column() {
      // 1. 顶部标题
      Row() {
        Text('数据分析')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 16, bottom: 8 })

      Scroll() {
        Column({ space: 16 }) {
          // 2. 时间维度切换器 (日 / 周 / 月)
          this.TimeSegmentSelector()

          // 3. 营养素摄入图表卡片 (堆叠柱状图)
          this.NutritionChartCard()

          // 4. 风险指标趋势图卡片 (超标红绿柱状预警)
          this.RiskChartCard()

          // 5. 历史评分变化趋势卡片 (含均分与分值柱)
          this.ScoreChartCard()

          // 6. 周期健康评估与饮食指导卡片
          this.AssessmentReportCard()

          Blank().height(30)
        }
        .padding({ left: 16, right: 16, top: 8, bottom: 20 })
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F7F8FA')
  }

  @Builder
  TimeSegmentSelector() {
    Row() {
      ForEach(this.timeModes, (mode: string) => {
        Text(mode)
          .fontSize(14)
          .fontWeight(this.timeMode === mode ? FontWeight.Bold : FontWeight.Normal)
          .fontColor(this.timeMode === mode ? AppTheme.PRIMARY_COLOR : '#666666')
          .backgroundColor(this.timeMode === mode ? Color.White : 'transparent')
          .padding({ left: 28, right: 28, top: 8, bottom: 8 })
          .borderRadius(16)
          .shadow(this.timeMode === mode ? { radius: 8, color: 'rgba(0,0,0,0.05)', offsetY: 2 } : { radius: 0 })
          .onClick(() => {
            this.timeMode = mode;
            this.selectedNutritionIndex = -1;
            this.selectedRiskIndex = -1;
            this.selectedScoreIndex = -1;
          })
      })
    }
    .backgroundColor('#EAEAEA')
    .borderRadius(20)
    .padding(4)
    .margin({ bottom: 8 })
  }

  @Builder
  NutritionChartCard() {
    Column() {
      // 头部
      Row({ space: 8 }) {
        Image($r('app.media.ic_trend')).width(18).height(18).fillColor('#333333')
        Text('营养素摄入趋势').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#333333')
      }
      .width('100%')
      .margin({ bottom: 16 })

      // 多色堆叠柱状图 (碳水/蛋白/脂肪)
      Row({ space: 12 }) {
        ForEach(this.getNutritionData(), (item: NutritionBarData, idx: number) => {
          Column() {
            Blank() // 占位把柱子往下压
            
            Column() {
              // 碳水 (橙色)
              Column()
                .width('100%')
                .height(`${item.carbsPercent}%`)
                .backgroundColor('#FF9800')
                .borderRadius({ topLeft: 4, topRight: 4 })
              
              // 蛋白 (蓝色)
              Column()
                .width('100%')
                .height(`${item.proteinPercent}%`)
                .backgroundColor('#2196F3')
              
              // 脂肪 (粉红)
              Column()
                .width('100%')
                .height(`${item.fatPercent}%`)
                .backgroundColor('#E91E63')
                .borderRadius({ bottomLeft: 4, bottomRight: 4 })
            }
            .width(16)
            .border(this.selectedNutritionIndex === idx ? { width: 2, color: AppTheme.PRIMARY_COLOR } : { width: 0 })
            
            Text(item.label)
              .fontSize(11)
              .fontColor(this.selectedNutritionIndex === idx ? AppTheme.PRIMARY_COLOR : '#999999')
              .fontWeight(this.selectedNutritionIndex === idx ? FontWeight.Bold : FontWeight.Normal)
              .margin({ top: 8 })
          }
          .height(130)
          .onClick(() => {
            if (this.selectedNutritionIndex === idx) {
              this.selectedNutritionIndex = -1;
            } else {
              this.selectedNutritionIndex = idx;
            }
          })
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)
      
      // 交互反馈：选中柱子展示明细
      if (this.getSelectedNutritionItem() !== null) {
        Row() {
          Text(`${this.getSelectedNutritionItem()?.label}: 碳水 ${this.getSelectedNutritionItem()?.carbsPercent}% (${this.getSelectedNutritionItem()?.carbsGrams}g) · 蛋白 ${this.getSelectedNutritionItem()?.proteinPercent}% (${this.getSelectedNutritionItem()?.proteinGrams}g) · 脂肪 ${this.getSelectedNutritionItem()?.fatPercent}% (${this.getSelectedNutritionItem()?.fatGrams}g) · 约 ${this.getSelectedNutritionItem()?.totalEnergy} 千卡`)
            .fontSize(11)
            .fontColor('#4A5568')
            .lineHeight(16)
        }
        .width('100%')
        .padding({ left: 10, right: 10, top: 6, bottom: 6 })
        .backgroundColor('#F7FAFC')
        .borderRadius(8)
        .margin({ top: 12 })
      }

      // 图例
      Row({ space: 16 }) {
        this.ChartLegend('#FF9800', '碳水')
        this.ChartLegend('#2196F3', '蛋白质')
        this.ChartLegend('#E91E63', '脂肪')
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .margin({ top: 16 })
    }
    .width('100%')
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .shadow({ radius: 8, color: 'rgba(0,0,0,0.03)', offsetY: 4 })
  }

  @Builder
  RiskChartCard() {
    Column() {
      // 头部：标题与指标切换按钮
      Row() {
        Row({ space: 8 }) {
          Image($r('app.media.ic_risk')).width(18).height(18).fillColor('#F44336')
          Text('风险指标超标预警').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#333333')
        }
        
        Blank()

        // 切换指标 Chip 按钮组
        Row({ space: 6 }) {
          ForEach(this.riskOptions, (opt: RiskTypeOption) => {
            Text(opt.name)
              .fontSize(11)
              .fontColor(this.selectedRiskType === opt.key ? AppTheme.PRIMARY_COLOR : '#888888')
              .fontWeight(this.selectedRiskType === opt.key ? FontWeight.Bold : FontWeight.Normal)
              .backgroundColor(this.selectedRiskType === opt.key ? '#E8F5E9' : '#F5F5F5')
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .borderRadius(10)
              .onClick(() => {
                this.selectedRiskType = opt.key;
                this.selectedRiskIndex = -1;
              })
          })
        }
      }
      .width('100%')
      .margin({ bottom: 12 })

      // 当前监测指标提示与单位
      Row() {
        Text(`${this.getCurrentRiskConfig().name}摄入量 (${this.getCurrentRiskConfig().unit})`)
          .fontSize(12)
          .fontColor('#666666')
        
        Blank()
        
        Text(`建议上限 ≤ ${this.getCurrentRiskConfig().threshold}${this.getCurrentRiskConfig().unit}`)
          .fontSize(11)
          .fontColor('#999999')
      }
      .width('100%')
      .margin({ bottom: 12 })
      
      // 条形图展示 (超过上限阈值显示告警红条，否则正常绿条)
      Row({ space: 14 }) {
        ForEach(this.getRiskData(), (item: RiskBarData, idx: number) => {
          Column() {
            Blank()
            
            Column()
              .width(20)
              .height(`${Math.min((item.value / this.getCurrentRiskConfig().maxScale) * 100, 100)}%`)
              .backgroundColor(item.isWarning ? '#F44336' : AppTheme.PRIMARY_COLOR)
              .borderRadius({ topLeft: 4, topRight: 4 })
              .border(this.selectedRiskIndex === idx ? { width: 2, color: '#333333' } : { width: 0 })

            Text(item.label)
              .fontSize(11)
              .fontColor(item.isWarning ? '#F44336' : (this.selectedRiskIndex === idx ? AppTheme.PRIMARY_COLOR : '#999999'))
              .fontWeight(item.isWarning || this.selectedRiskIndex === idx ? FontWeight.Bold : FontWeight.Normal)
              .margin({ top: 8 })
          }
          .height(110)
          .onClick(() => {
            if (this.selectedRiskIndex === idx) {
              this.selectedRiskIndex = -1;
            } else {
              this.selectedRiskIndex = idx;
            }
          })
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)

      // 交互反馈：选中柱子展示明细与告警提醒
      if (this.getSelectedRiskItem() !== null) {
        Row() {
          Text(`${this.getSelectedRiskItem()?.label} · ${this.getSelectedRiskItem()?.value}${this.getCurrentRiskConfig().unit}: ${this.getSelectedRiskItem()?.hint}`)
            .fontSize(11)
            .fontColor(this.getSelectedRiskItem()?.isWarning ? '#E53E3E' : '#2D3748')
            .lineHeight(16)
        }
        .width('100%')
        .padding({ left: 10, right: 10, top: 6, bottom: 6 })
        .backgroundColor(this.getSelectedRiskItem()?.isWarning ? '#FFF5F5' : '#F0FDF4')
        .borderRadius(8)
        .margin({ top: 12 })
      }
    }
    .width('100%')
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .shadow({ radius: 8, color: 'rgba(0,0,0,0.03)', offsetY: 4 })
  }

  @Builder
  ScoreChartCard() {
    Column() {
      Row({ space: 8 }) {
        Image($r('app.media.ic_score')).width(18).height(18).fillColor('#FFC107')
        Text('历史评分变化').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#333333')
        Blank()
        Text(`均分 ${this.getAverageScore()}`)
          .fontSize(12)
          .fontColor(AppTheme.PRIMARY_COLOR)
          .backgroundColor('#E8F5E9')
          .padding({ left: 8, right: 8, top: 2, bottom: 2 })
          .borderRadius(10)
      }
      .width('100%')
      .margin({ bottom: 16 })

      // 展示评分柱状图 (柱顶数字 + 绿色质感柱条)
      Row({ space: 14 }) {
        ForEach(this.getScoreData(), (item: ScoreBarData, idx: number) => {
          Column() {
            Blank()
            Text(`${item.score}`)
              .fontSize(10)
              .fontColor('#666666')
              .fontWeight(FontWeight.Medium)
              .margin({ bottom: 4 })

            Column()
              .width(20)
              .height(`${Math.max((item.score / 100) * 100, 10)}%`)
              .backgroundColor(AppTheme.PRIMARY_COLOR)
              .opacity(0.85)
              .borderRadius({ topLeft: 6, topRight: 6 })
              .border(this.selectedScoreIndex === idx ? { width: 2, color: '#333333' } : { width: 0 })

            Text(item.label)
              .fontSize(11)
              .fontColor(this.selectedScoreIndex === idx ? AppTheme.PRIMARY_COLOR : '#999999')
              .fontWeight(this.selectedScoreIndex === idx ? FontWeight.Bold : FontWeight.Normal)
              .margin({ top: 8 })
          }
          .height(110)
          .onClick(() => {
            if (this.selectedScoreIndex === idx) {
              this.selectedScoreIndex = -1;
            } else {
              this.selectedScoreIndex = idx;
            }
          })
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)

      // 交互反馈：展示评语
      if (this.getSelectedScoreItem() !== null) {
        Row() {
          Text(`${this.getSelectedScoreItem()?.label} · 得分 ${this.getSelectedScoreItem()?.score}分: ${this.getSelectedScoreItem()?.evaluation}`)
            .fontSize(11)
            .fontColor('#4A5568')
            .lineHeight(16)
        }
        .width('100%')
        .padding({ left: 10, right: 10, top: 6, bottom: 6 })
        .backgroundColor('#F7FAFC')
        .borderRadius(8)
        .margin({ top: 12 })
      }
    }
    .width('100%')
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .shadow({ radius: 8, color: 'rgba(0,0,0,0.03)', offsetY: 4 })
  }

  @Builder
  AssessmentReportCard() {
    Column({ space: 12 }) {
      Row({ space: 8 }) {
        Text('💡').fontSize(18)
        Text('周期健康评估与饮食指导')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppTheme.PRIMARY_COLOR)
      }
      .width('100%')

      // 三大核心指标概览
      Row() {
        this.ReportStatItem('日均能量', '1860 kcal', '正常达标')
        this.ReportStatItem('供能比', '50:28:22', '黄金配比')
        this.ReportStatItem('超标预警', `${this.getWarningCount()} 次`, this.getWarningCount() > 0 ? `${this.getCurrentRiskConfig().name}偏高` : '全线达标')
      }
      .width('100%')
      .padding({ top: 6, bottom: 6 })

      Divider().color('#E2E8F0').strokeWidth(0.5)

      // 针对性建议
      Text(this.getDynamicSuggestion())
        .fontSize(12)
        .fontColor('#4A5568')
        .lineHeight(20)
    }
    .width('100%')
    .padding(18)
    .backgroundColor('#F0FDF4')
    .borderRadius(16)
    .border({ width: 1, color: '#DCFCE7' })
    .shadow({ radius: 8, color: 'rgba(46, 139, 87, 0.05)', offsetY: 4 })
  }

  @Builder
  ReportStatItem(label: string, value: string, badge: string) {
    Column({ space: 4 }) {
      Text(label).fontSize(11).fontColor('#718096')
      Text(value).fontSize(14).fontWeight(FontWeight.Bold).fontColor('#2D3748')
      Text(badge)
        .fontSize(10)
        .fontColor(AppTheme.PRIMARY_COLOR)
        .backgroundColor('#DCFCE7')
        .padding({ left: 6, right: 6, top: 2, bottom: 2 })
        .borderRadius(6)
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
  }

  getDynamicSuggestion(): string {
    if (this.selectedRiskType === 'purine') {
      if (this.timeMode === '日') {
        return '今日三餐嘌呤摄入量处于安全范围，建议保持清淡蔬菜与低脂牛奶摄入，晚餐避免动物内脏与浓肉汤，多饮温水保持排泄通畅。';
      } else if (this.timeMode === '周') {
        return '监测到本周三嘌呤摄入达到 320mg 超过安全上限（300mg），主要由外食荤腥引起。建议日常多饮温水（每日 2000ml 以上），少喝啤酒与含糖饮料，多选新鲜绿叶蔬菜。';
      } else {
        return '本月整体嘌呤控制良好，有 1 次阶段性波动，痛风人群长期稳定在 300mg 以下有利于血尿酸达标并降低关节发作几率。';
      }
    } else if (this.selectedRiskType === 'sodium') {
      if (this.timeMode === '日') {
        return '今日钠摄入表现良好，注意烹饪时少放豆瓣酱、生抽等调味酱料，多用葱姜蒜及柠檬汁天然提味。';
      } else {
        return '监测到周期内偶有钠超标（逼近或超过 2000mg 上限），建议减少咸菜、腌制品摄入，多食用富钾新鲜蔬果（如香蕉、菠菜）以协助电解质平衡。';
      }
    } else {
      return '胆固醇与脂肪供能比整体良好，建议坚持全麦谷物与优质蛋白摄入，控制蛋黄（每日不多于1个）及肥肉摄入量。';
    }
  }

  @Builder
  ChartLegend(color: string, label: string) {
    Row({ space: 4 }) {
      Circle({ width: 8, height: 8 }).fill(color)
      Text(label).fontSize(11).fontColor('#666666')
    }
  }
}
