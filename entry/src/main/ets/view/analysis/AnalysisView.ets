import { AppTheme } from '../../common/constants/AppTheme'
import { DietRecordItem } from '../../common/models/FoodItem'
import { FoodDBHelper } from '../../common/utils/FoodDBHelper'
import { DateHelper, WeekDayInfo, MonthWeekInfo } from '../../common/utils/DateHelper'
import { NutritionCalculator, MacroNutrientSummary, RiskNutrientSummary, ScoreSummary } from '../../common/utils/NutritionCalculator'

export interface NutritionBarData {
  label: string;
  carbsPercent: number;
  proteinPercent: number;
  fatPercent: number;
  carbsGrams: number;
  proteinGrams: number;
  fatGrams: number;
  totalEnergy: number;
  hasData: boolean;
}

export interface RiskBarData {
  label: string;
  value: number;
  threshold: number;
  isWarning: boolean;
  hint: string;
  hasData: boolean;
}

export interface ScoreBarData {
  label: string;
  score: number;
  evaluation: string;
  hasData: boolean;
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
  @Prop @Watch('onActiveTabChange') activeTab: number = 0;
  onNavigateToRecord: () => void = () => {};

  @State timeMode: string = '周'; // '日' | '周' | '月'
  @State selectedRiskType: string = 'purine'; // 'purine' | 'sodium' | 'cholesterol'
  
  @State selectedNutritionIndex: number = -1;
  @State selectedRiskIndex: number = -1;
  @State selectedScoreIndex: number = -1;

  @State periodRecords: DietRecordItem[] = [];
  @State isDataLoaded: boolean = false;

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
    await this.loadRealData();
  }

  onActiveTabChange() {
    // 切换到本分析标签页时 (index 3) 自动重新加载真实记录
    if (this.activeTab === 3) {
      this.loadRealData();
    }
  }

  async loadRealData() {
    this.selectedNutritionIndex = -1;
    this.selectedRiskIndex = -1;
    this.selectedScoreIndex = -1;

    try {
      if (this.timeMode === '日') {
        let todayKey = DateHelper.formatDateKey(new Date());
        this.periodRecords = await FoodDBHelper.getDietRecordsByDate(todayKey);
      } else if (this.timeMode === '周') {
        let weekDays = DateHelper.getWeekDates(new Date());
        let startDate = weekDays[0].dateKey;
        let endDate = weekDays[6].dateKey;
        this.periodRecords = await FoodDBHelper.getDietRecordsBetween(startDate, endDate);
      } else {
        let monthWeeks = DateHelper.getMonthWeeks(new Date());
        let startDate = monthWeeks[0].startDateKey;
        let endDate = monthWeeks[3].endDateKey;
        this.periodRecords = await FoodDBHelper.getDietRecordsBetween(startDate, endDate);
      }
    } catch (err) {
      console.error('AnalysisView', 'loadRealData failed', err);
      this.periodRecords = [];
    }
    this.isDataLoaded = true;
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
    let result: NutritionBarData[] = [];
    if (this.timeMode === '日') {
      const meals = ['早餐', '午餐', '晚餐', '加餐'];
      for (let meal of meals) {
        let recs = this.periodRecords.filter((r: DietRecordItem) => r.mealType === meal);
        let macro: MacroNutrientSummary = NutritionCalculator.aggregateMacros(meal, recs);
        let item: NutritionBarData = {
          label: meal,
          carbsPercent: macro.carbsPercent,
          proteinPercent: macro.proteinPercent,
          fatPercent: macro.fatPercent,
          carbsGrams: macro.carbsGrams,
          proteinGrams: macro.proteinGrams,
          fatGrams: macro.fatGrams,
          totalEnergy: macro.totalEnergy,
          hasData: recs.length > 0
        };
        result.push(item);
      }
      return result;
    } else if (this.timeMode === '月') {
      let monthWeeks = DateHelper.getMonthWeeks(new Date());
      for (let w of monthWeeks) {
        let recs = this.periodRecords.filter((r: DietRecordItem) => r.date >= w.startDateKey && r.date <= w.endDateKey);
        let macro: MacroNutrientSummary = NutritionCalculator.aggregateMacros(w.weekLabel, recs);
        let item: NutritionBarData = {
          label: w.weekLabel,
          carbsPercent: macro.carbsPercent,
          proteinPercent: macro.proteinPercent,
          fatPercent: macro.fatPercent,
          carbsGrams: macro.carbsGrams,
          proteinGrams: macro.proteinGrams,
          fatGrams: macro.fatGrams,
          totalEnergy: macro.totalEnergy,
          hasData: recs.length > 0
        };
        result.push(item);
      }
      return result;
    }

    // 周模式 (周一 至 周日 7 天)
    let weekDays = DateHelper.getWeekDates(new Date());
    for (let d of weekDays) {
      let recs = this.periodRecords.filter((r: DietRecordItem) => r.date === d.dateKey);
      let macro: MacroNutrientSummary = NutritionCalculator.aggregateMacros(d.dayLabel, recs);
      let item: NutritionBarData = {
        label: d.dayLabel,
        carbsPercent: macro.carbsPercent,
        proteinPercent: macro.proteinPercent,
        fatPercent: macro.fatPercent,
        carbsGrams: macro.carbsGrams,
        proteinGrams: macro.proteinGrams,
        fatGrams: macro.fatGrams,
        totalEnergy: macro.totalEnergy,
        hasData: recs.length > 0
      };
      result.push(item);
    }
    return result;
  }

  getRiskData(): RiskBarData[] {
    let cfg = this.getCurrentRiskConfig();
    let result: RiskBarData[] = [];

    if (this.timeMode === '日') {
      const meals = ['早餐', '午餐', '晚餐', '加餐'];
      for (let meal of meals) {
        let recs = this.periodRecords.filter((r: DietRecordItem) => r.mealType === meal);
        let risk: RiskNutrientSummary = NutritionCalculator.aggregateRisks(meal, recs);
        let val = this.selectedRiskType === 'purine' ? risk.purine : (this.selectedRiskType === 'sodium' ? risk.sodium : risk.cholesterol);
        let isWarn = val > cfg.threshold;
        let hint = recs.length === 0 ? '未记录餐食' : (isWarn ? `已超单餐安全阈值(${cfg.threshold}${cfg.unit})` : '处于健康安全范围');
        let item: RiskBarData = {
          label: meal,
          value: val,
          threshold: cfg.threshold,
          isWarning: isWarn,
          hint: hint,
          hasData: recs.length > 0
        };
        result.push(item);
      }
      return result;
    } else if (this.timeMode === '月') {
      let monthWeeks = DateHelper.getMonthWeeks(new Date());
      for (let w of monthWeeks) {
        let recs = this.periodRecords.filter((r: DietRecordItem) => r.date >= w.startDateKey && r.date <= w.endDateKey);
        let risk: RiskNutrientSummary = NutritionCalculator.aggregateRisks(w.weekLabel, recs);
        let val = this.selectedRiskType === 'purine' ? risk.purine : (this.selectedRiskType === 'sodium' ? risk.sodium : risk.cholesterol);
        let isWarn = val > cfg.threshold;
        let hint = recs.length === 0 ? '该周暂无记录' : (isWarn ? `该周累计超标，需适度调整` : '摄入良好受控');
        let item: RiskBarData = {
          label: w.weekLabel,
          value: val,
          threshold: cfg.threshold,
          isWarning: isWarn,
          hint: hint,
          hasData: recs.length > 0
        };
        result.push(item);
      }
      return result;
    }

    // 周模式
    let weekDays = DateHelper.getWeekDates(new Date());
    for (let d of weekDays) {
      let recs = this.periodRecords.filter((r: DietRecordItem) => r.date === d.dateKey);
      let risk: RiskNutrientSummary = NutritionCalculator.aggregateRisks(d.dayLabel, recs);
      let val = this.selectedRiskType === 'purine' ? risk.purine : (this.selectedRiskType === 'sodium' ? risk.sodium : risk.cholesterol);
      let isWarn = val > cfg.threshold;
      let hint = recs.length === 0 ? '当日无记录' : (isWarn ? `超过建议安全上限(${cfg.threshold}${cfg.unit})` : '摄入正常达标');
      let item: RiskBarData = {
        label: d.dayLabel,
        value: val,
        threshold: cfg.threshold,
        isWarning: isWarn,
        hint: hint,
        hasData: recs.length > 0
      };
      result.push(item);
    }
    return result;
  }

  getScoreData(): ScoreBarData[] {
    let result: ScoreBarData[] = [];

    if (this.timeMode === '日') {
      const meals = ['早餐', '午餐', '晚餐', '加餐'];
      for (let meal of meals) {
        let recs = this.periodRecords.filter((r: DietRecordItem) => r.mealType === meal);
        let s: ScoreSummary = NutritionCalculator.calculateHealthScore(recs, meal);
        let item: ScoreBarData = {
          label: meal,
          score: s.score,
          evaluation: s.evaluation,
          hasData: recs.length > 0
        };
        result.push(item);
      }
      return result;
    } else if (this.timeMode === '月') {
      let monthWeeks = DateHelper.getMonthWeeks(new Date());
      for (let w of monthWeeks) {
        let recs = this.periodRecords.filter((r: DietRecordItem) => r.date >= w.startDateKey && r.date <= w.endDateKey);
        let s: ScoreSummary = NutritionCalculator.calculateHealthScore(recs, w.weekLabel);
        let item: ScoreBarData = {
          label: w.weekLabel,
          score: s.score,
          evaluation: s.evaluation,
          hasData: recs.length > 0
        };
        result.push(item);
      }
      return result;
    }

    // 周模式
    let weekDays = DateHelper.getWeekDates(new Date());
    for (let d of weekDays) {
      let recs = this.periodRecords.filter((r: DietRecordItem) => r.date === d.dateKey);
      let s: ScoreSummary = NutritionCalculator.calculateHealthScore(recs, d.dayLabel);
      let item: ScoreBarData = {
        label: d.dayLabel,
        score: s.score,
        evaluation: s.evaluation,
        hasData: recs.length > 0
      };
      result.push(item);
    }
    return result;
  }

  getAverageScore(): number {
    let scores = this.getScoreData();
    let validScores = scores.filter((s: ScoreBarData) => s.hasData && s.score > 0);
    if (validScores.length === 0) return 0;
    let sum = 0;
    for (let s of validScores) {
      sum += s.score;
    }
    return Math.round(sum / validScores.length);
  }

  getWarningCount(): number {
    let risks = this.getRiskData();
    let count = 0;
    for (let r of risks) {
      if (r.hasData && r.isWarning) count++;
    }
    return count;
  }

  getPeriodAverageEnergy(): number {
    if (this.periodRecords.length === 0) return 0;
    let totalKcal = 0;
    for (let r of this.periodRecords) {
      totalKcal += r.energy;
    }
    if (this.timeMode === '日') {
      return Math.round(totalKcal);
    } else if (this.timeMode === '周') {
      // 按实际有记录的天数平均
      let dates: string[] = [];
      for (let r of this.periodRecords) {
        if (dates.indexOf(r.date) === -1) {
          dates.push(r.date);
        }
      }
      return Math.round(totalKcal / Math.max(1, dates.length));
    } else {
      return Math.round(totalKcal / 4);
    }
  }

  getPeriodMacroRatioText(): string {
    if (this.periodRecords.length === 0) {
      return '—';
    }
    let macro = NutritionCalculator.aggregateMacros('total', this.periodRecords);
    if (macro.totalEnergy === 0) {
      return '—';
    }
    return `${macro.carbsPercent}:${macro.proteinPercent}:${macro.fatPercent}`;
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

        Blank()

        if (this.periodRecords.length > 0) {
          Text(`已记录 ${this.periodRecords.length} 条`)
            .fontSize(12)
            .fontColor(AppTheme.PRIMARY_COLOR)
            .backgroundColor('#E8F5E9')
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .borderRadius(12)
        }
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 16, bottom: 8 })

      Scroll() {
        Column({ space: 16 }) {
          // 2. 时间维度切换器 (日 / 周 / 月)
          this.TimeSegmentSelector()

          // 空状态温馨提示栏 (当当前周期没有任何记录时呈现)
          if (this.periodRecords.length === 0) {
            this.EmptyStateBanner()
          }

          // 3. 营养素摄入图表卡片 (堆叠柱状图，独立隔离绘图区与图例，杜绝重叠)
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
  EmptyStateBanner() {
    Row({ space: 12 }) {
      Image($r('app.media.ic_record'))
        .width(22)
        .height(22)

      Column({ space: 2 }) {
        Text(`${this.timeMode}维度暂无饮食记录`)
          .fontSize(13)
          .fontWeight(FontWeight.Bold)
          .fontColor('#2D3748')
        Text('添加饮食后将自动生成营养比例与慢病指标预警')
          .fontSize(11)
          .fontColor('#718096')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Button('去记录')
        .fontSize(12)
        .fontWeight(FontWeight.Medium)
        .fontColor(Color.White)
        .backgroundColor(AppTheme.PRIMARY_COLOR)
        .height(28)
        .padding({ left: 12, right: 12 })
        .borderRadius(14)
        .onClick(() => {
          this.onNavigateToRecord();
        })
    }
    .width('100%')
    .padding({ left: 14, right: 14, top: 10, bottom: 10 })
    .backgroundColor('#E8F5E9')
    .borderRadius(12)
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
            this.loadRealData();
          })
      })
    }
    .backgroundColor('#EAEAEA')
    .borderRadius(20)
    .padding(4)
    .margin({ bottom: 4 })
  }

  // 3. 营养素摄入趋势卡片 (三段式独立隔离布局，杜绝重合)
  @Builder
  NutritionChartCard() {
    Column() {
      // 头部
      Row({ space: 8 }) {
        Image($r('app.media.ic_trend')).width(18).height(18)
        Text('营养素摄入趋势').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#333333')
        Blank()
        if (this.periodRecords.length === 0) {
          Text('暂无数据').fontSize(11).fontColor('#A0AEC0')
        }
      }
      .width('100%')
      .margin({ bottom: 14 })

      // Zone 1: 独立绘图区 (固定高度 105vp，精确计算柱条高度，绝不溢出)
      Row() {
        ForEach(this.getNutritionData(), (item: NutritionBarData, idx: number) => {
          Column() {
            Blank()
            if (item.hasData && item.totalEnergy > 0) {
              // 多色堆叠柱 (总高度 90vp)
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
              .width(this.timeMode === '周' ? 18 : 26)
              .height(90)
              .clip(true)
              .border(this.selectedNutritionIndex === idx ? { width: 2, color: AppTheme.PRIMARY_COLOR } : { width: 0 })
            } else {
              // 空数据态：展示干净整齐的基准占位短线
              Column()
                .width(this.timeMode === '周' ? 18 : 26)
                .height(4)
                .backgroundColor('#E2E8F0')
                .borderRadius(2)
                .margin({ bottom: 2 })
            }
          }
          .height(105)
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center)
          .justifyContent(FlexAlign.End)
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
      .height(105)

      // 基准分割线 (浅灰)
      Divider().color('#EDF2F7').strokeWidth(1).margin({ top: 4, bottom: 8 })

      // Zone 2: 独立 X 轴标签行 (独立一行，与图例与绘图区分开，绝不重叠)
      Row() {
        ForEach(this.getNutritionData(), (item: NutritionBarData, idx: number) => {
          Text(item.label)
            .fontSize(11)
            .fontColor(this.selectedNutritionIndex === idx ? AppTheme.PRIMARY_COLOR : '#718096')
            .fontWeight(this.selectedNutritionIndex === idx ? FontWeight.Bold : FontWeight.Normal)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
        })
      }
      .width('100%')
      
      // 交互反馈：选中柱子展示明细
      if (this.getSelectedNutritionItem() !== null) {
        Row() {
          if (this.getSelectedNutritionItem()?.hasData) {
            Text(`${this.getSelectedNutritionItem()?.label}: 碳水 ${this.getSelectedNutritionItem()?.carbsPercent}% (${this.getSelectedNutritionItem()?.carbsGrams}g) · 蛋白 ${this.getSelectedNutritionItem()?.proteinPercent}% (${this.getSelectedNutritionItem()?.proteinGrams}g) · 脂肪 ${this.getSelectedNutritionItem()?.fatPercent}% (${this.getSelectedNutritionItem()?.fatGrams}g) · 约 ${this.getSelectedNutritionItem()?.totalEnergy} 千卡`)
              .fontSize(11)
              .fontColor('#4A5568')
              .lineHeight(16)
          } else {
            Text(`${this.getSelectedNutritionItem()?.label}: 暂无饮食记录`)
              .fontSize(11)
              .fontColor('#A0AEC0')
          }
        }
        .width('100%')
        .padding({ left: 10, right: 10, top: 6, bottom: 6 })
        .backgroundColor('#F7FAFC')
        .borderRadius(8)
        .margin({ top: 10 })
      }

      // Zone 3: 独立图例行 (留有充足的呼吸间距，杜绝紧贴或碰撞)
      Row({ space: 24 }) {
        this.ChartLegend('#FF9800', '碳水')
        this.ChartLegend('#2196F3', '蛋白质')
        this.ChartLegend('#E91E63', '脂肪')
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .margin({ top: 14 })
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 16, bottom: 16 })
    .backgroundColor(Color.White)
    .borderRadius(16)
    .shadow({ radius: 8, color: 'rgba(0,0,0,0.03)', offsetY: 4 })
  }

  // 4. 风险指标超标预警卡片
  @Builder
  RiskChartCard() {
    Column() {
      // 头部：标题与指标切换按钮
      Row() {
        Row({ space: 8 }) {
          Image($r('app.media.ic_risk')).width(18).height(18)
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
      .margin({ bottom: 10 })

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
      
      // Zone 1: 独立条形图绘图区 (固定高度 105vp)
      Row() {
        ForEach(this.getRiskData(), (item: RiskBarData, idx: number) => {
          Column() {
            Blank()
            if (item.hasData && item.value > 0) {
              Column()
                .width(this.timeMode === '周' ? 18 : 26)
                .height(`${Math.max(Math.min((item.value / this.getCurrentRiskConfig().maxScale) * 100, 100), 8)}%`)
                .backgroundColor(item.isWarning ? '#F44336' : AppTheme.PRIMARY_COLOR)
                .borderRadius({ topLeft: 4, topRight: 4 })
                .border(this.selectedRiskIndex === idx ? { width: 2, color: '#333333' } : { width: 0 })
            } else {
              Column()
                .width(this.timeMode === '周' ? 18 : 26)
                .height(4)
                .backgroundColor('#E2E8F0')
                .borderRadius(2)
                .margin({ bottom: 2 })
            }
          }
          .height(105)
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center)
          .justifyContent(FlexAlign.End)
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
      .height(105)

      // 基准分割线
      Divider().color('#EDF2F7').strokeWidth(1).margin({ top: 4, bottom: 8 })

      // Zone 2: 独立 X 轴标签行
      Row() {
        ForEach(this.getRiskData(), (item: RiskBarData, idx: number) => {
          Text(item.label)
            .fontSize(11)
            .fontColor(item.isWarning ? '#F44336' : (this.selectedRiskIndex === idx ? AppTheme.PRIMARY_COLOR : '#718096'))
            .fontWeight(item.isWarning || this.selectedRiskIndex === idx ? FontWeight.Bold : FontWeight.Normal)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
        })
      }
      .width('100%')

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
    .padding({ left: 18, right: 18, top: 16, bottom: 16 })
    .backgroundColor(Color.White)
    .borderRadius(16)
    .shadow({ radius: 8, color: 'rgba(0,0,0,0.03)', offsetY: 4 })
  }

  // 5. 历史评分变化卡片
  @Builder
  ScoreChartCard() {
    Column() {
      Row({ space: 8 }) {
        Image($r('app.media.ic_score')).width(18).height(18)
        Text('历史评分变化').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#333333')
        Blank()
        Text(this.getAverageScore() > 0 ? `均分 ${this.getAverageScore()}` : '暂无评分')
          .fontSize(12)
          .fontColor(this.getAverageScore() > 0 ? AppTheme.PRIMARY_COLOR : '#A0AEC0')
          .backgroundColor(this.getAverageScore() > 0 ? '#E8F5E9' : '#F7FAFC')
          .padding({ left: 8, right: 8, top: 2, bottom: 2 })
          .borderRadius(10)
      }
      .width('100%')
      .margin({ bottom: 14 })

      // Zone 1: 独立评分柱状图绘图区 (固定高度 105vp)
      Row() {
        ForEach(this.getScoreData(), (item: ScoreBarData, idx: number) => {
          Column() {
            Blank()
            if (item.hasData && item.score > 0) {
              Text(`${item.score}`)
                .fontSize(10)
                .fontColor('#666666')
                .fontWeight(FontWeight.Medium)
                .margin({ bottom: 4 })

              Column()
                .width(this.timeMode === '周' ? 18 : 26)
                .height(`${Math.max((item.score / 100) * 75, 10)}%`)
                .backgroundColor(AppTheme.PRIMARY_COLOR)
                .opacity(0.85)
                .borderRadius({ topLeft: 4, topRight: 4 })
                .border(this.selectedScoreIndex === idx ? { width: 2, color: '#333333' } : { width: 0 })
            } else {
              Text('-')
                .fontSize(10)
                .fontColor('#CBD5E0')
                .margin({ bottom: 4 })

              Column()
                .width(this.timeMode === '周' ? 18 : 26)
                .height(4)
                .backgroundColor('#E2E8F0')
                .borderRadius(2)
                .margin({ bottom: 2 })
            }
          }
          .height(105)
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center)
          .justifyContent(FlexAlign.End)
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
      .height(105)

      // 基准分割线
      Divider().color('#EDF2F7').strokeWidth(1).margin({ top: 4, bottom: 8 })

      // Zone 2: 独立 X 轴标签行
      Row() {
        ForEach(this.getScoreData(), (item: ScoreBarData, idx: number) => {
          Text(item.label)
            .fontSize(11)
            .fontColor(this.selectedScoreIndex === idx ? AppTheme.PRIMARY_COLOR : '#718096')
            .fontWeight(this.selectedScoreIndex === idx ? FontWeight.Bold : FontWeight.Normal)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
        })
      }
      .width('100%')

      // 交互反馈：展示评语
      if (this.getSelectedScoreItem() !== null) {
        Row() {
          if (this.getSelectedScoreItem()?.hasData) {
            Text(`${this.getSelectedScoreItem()?.label} · 得分 ${this.getSelectedScoreItem()?.score}分: ${this.getSelectedScoreItem()?.evaluation}`)
              .fontSize(11)
              .fontColor('#4A5568')
              .lineHeight(16)
          } else {
            Text(`${this.getSelectedScoreItem()?.label}: 暂无饮食记录`)
              .fontSize(11)
              .fontColor('#A0AEC0')
          }
        }
        .width('100%')
        .padding({ left: 10, right: 10, top: 6, bottom: 6 })
        .backgroundColor('#F7FAFC')
        .borderRadius(8)
        .margin({ top: 12 })
      }
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 16, bottom: 16 })
    .backgroundColor(Color.White)
    .borderRadius(16)
    .shadow({ radius: 8, color: 'rgba(0,0,0,0.03)', offsetY: 4 })
  }

  // 6. 周期健康评估与饮食指导卡片 (基于真实数据动态生成)
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

      // 三大核心指标概览 (真实计算数据)
      Row() {
        Column({ space: 4 }) {
          Text(this.timeMode === '日' ? '今日摄入' : '周期日均').fontSize(11).fontColor('#718096')
          Text(`${this.getPeriodAverageEnergy()} kcal`).fontSize(14).fontWeight(FontWeight.Bold).fontColor('#2D3748')
          Text(this.getPeriodAverageEnergy() > 0 ? (this.getPeriodAverageEnergy() <= 2200 ? '正常达标' : '略微偏高') : '暂无数据')
            .fontSize(10)
            .fontColor(AppTheme.PRIMARY_COLOR)
            .backgroundColor('#DCFCE7')
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .borderRadius(6)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)

        Column({ space: 4 }) {
          Text('供能比').fontSize(11).fontColor('#718096')
          Text(this.getPeriodMacroRatioText()).fontSize(14).fontWeight(FontWeight.Bold).fontColor('#2D3748')
          Text(this.periodRecords.length > 0 ? '宏量结构' : '待记录')
            .fontSize(10)
            .fontColor(AppTheme.PRIMARY_COLOR)
            .backgroundColor('#DCFCE7')
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .borderRadius(6)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)

        Column({ space: 4 }) {
          Text('超标预警').fontSize(11).fontColor('#718096')
          Text(`${this.getWarningCount()} 次`).fontSize(14).fontWeight(FontWeight.Bold).fontColor('#2D3748')
          Text(this.getWarningCount() > 0 ? `${this.getCurrentRiskConfig().name}超标` : '安全稳定')
            .fontSize(10)
            .fontColor(AppTheme.PRIMARY_COLOR)
            .backgroundColor('#DCFCE7')
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .borderRadius(6)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
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

  getDynamicSuggestion(): string {
    if (this.periodRecords.length === 0) {
      return `当前${this.timeMode}维度内暂无饮食记录。请前往「记录」录入您的日常三餐，系统将为您生成详尽的三大营养素宏量供能比分析与痛风、高血压等风险预警。`;
    }

    let warnCount = this.getWarningCount();
    let avgEnergy = this.getPeriodAverageEnergy();

    if (this.selectedRiskType === 'purine') {
      if (warnCount > 0) {
        return `监测到该周期内有 ${warnCount} 次嘌呤超出安全上限（300mg）。建议日常多饮温水（每日 2000ml 以上）促进尿酸排泄，避免内脏浓肉汤，增加新鲜叶菜与脱脂奶摄入。`;
      }
      return '当前周期嘌呤摄入量整体控制良好，处于安全平稳范围。建议继续保持合理荤素搭配，维持良好的水分补给。';
    } else if (this.selectedRiskType === 'sodium') {
      if (warnCount > 0) {
        return `监测到有 ${warnCount} 次钠盐摄入超过建议上限（2000mg）。建议烹饪时适当减少生抽与酱料用量，少食腌制加工品，多选高钾新鲜蔬果。`;
      }
      return '钠摄入量保持良好，符合低盐膳食健康标准，有利于维持平稳血压。';
    } else {
      if (warnCount > 0) {
        return `监测到胆固醇偏高（超过 300mg 上限）。建议控制蛋黄、动物内脏及肥肉摄入量，增加富含膳食纤维的燕麦与豆制品。`;
      }
      return '胆固醇与脂肪摄入良好，心血管负担较低，建议维持均衡的优质蛋白与蔬菜搭配。';
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
