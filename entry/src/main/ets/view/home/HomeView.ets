import { AppTheme } from '../../common/constants/AppTheme'
import { FoodDBHelper } from '../../common/utils/FoodDBHelper'
import { DateHelper } from '../../common/utils/DateHelper'
import { DietRecordItem } from '../../common/models/FoodItem'
import {
  NutritionCalculator,
  MacroNutrientSummary,
  RiskNutrientSummary,
  ScoreSummary
} from '../../common/utils/NutritionCalculator'

interface RiskBadgeInfo {
  status: string;
  color: string;
  bgColor: string;
}

@Component
export struct HomeView {
  @Prop @Watch('onActiveTabChange') activeTab: number = 0;
  onNavigateToRecord: () => void = () => {};

  @State selectedDate: Date = new Date();
  @State dateText: string = '';
  @State todayRecords: DietRecordItem[] = [];

  // 能量与目标
  @State totalDailyEnergy: number = 0;
  @State targetEnergy: number = 2100;

  // 综合健康评分
  @State healthScore: number = 0;
  @State scoreEvaluation: string = '';

  // 三大宏量营养素 (实际摄入克重与目标)
  @State carbsGrams: number = 0;
  @State proteinGrams: number = 0;
  @State fatGrams: number = 0;
  @State targetCarbs: number = 250;
  @State targetProtein: number = 80;
  @State targetFat: number = 60;

  // 三大慢病风险指标
  @State purine: number = 0;
  @State sodium: number = 0;
  @State cholesterol: number = 0;

  // 动态健康建议
  @State suggestionText: string = '';

  async aboutToAppear() {
    let context = getContext(this);
    await FoodDBHelper.init(context);
    await this.loadTodayData();
  }

  onActiveTabChange() {
    // 切换至本首页 Tab (index 0) 时自动从数据库重新加载最新数据
    if (this.activeTab === 0) {
      this.loadTodayData();
    }
  }

  async loadTodayData() {
    this.dateText = DateHelper.formatDisplayDate(this.selectedDate);
    let dateKey = DateHelper.formatDateKey(this.selectedDate);

    try {
      this.todayRecords = await FoodDBHelper.getDietRecordsByDate(dateKey);
    } catch (err) {
      console.error('HomeView', 'getDietRecordsByDate failed', err);
      this.todayRecords = [];
    }

    // 1. 汇总热量
    let sumEnergy = 0;
    for (let r of this.todayRecords) {
      sumEnergy += r.energy;
    }
    this.totalDailyEnergy = sumEnergy;

    // 2. 宏量营养素计算
    let macro: MacroNutrientSummary = NutritionCalculator.aggregateMacros('今日', this.todayRecords);
    this.carbsGrams = Math.round(macro.carbsGrams * 10) / 10;
    this.proteinGrams = Math.round(macro.proteinGrams * 10) / 10;
    this.fatGrams = Math.round(macro.fatGrams * 10) / 10;

    // 3. 风险指标计算
    let risks: RiskNutrientSummary = NutritionCalculator.aggregateRisks('今日', this.todayRecords);
    this.purine = risks.purine;
    this.sodium = risks.sodium;
    this.cholesterol = risks.cholesterol;

    // 4. 健康评分计算
    let scoreRes: ScoreSummary = NutritionCalculator.calculateHealthScore(this.todayRecords, '今日');
    this.healthScore = scoreRes.score;
    this.scoreEvaluation = scoreRes.evaluation;

    // 5. 生成智能动态健康建议
    this.suggestionText = this.generateDynamicSuggestion();
  }

  generateDynamicSuggestion(): string {
    if (this.todayRecords.length === 0) {
      return '今日尚未录入饮食。点击下方「去记录」添加早、中、晚餐，系统将为您实时计算营养结构与慢病风险。';
    }

    // 优先告警：钠超标或逼近上限 (2000mg)
    if (this.sodium > 1500) {
      let isOver = this.sodium > 2000;
      return `今日钠摄入已达 ${this.sodium}mg${isOver ? '（已超安全上限2000mg）' : '（逼近上限）'}，建议后续餐食避免腌制食品与重口菜肴，尽量以清淡、水煮为主，并多喝温水促进代谢。`;
    }

    // 告警：嘌呤超标或偏高 (300mg)
    if (this.purine > 200) {
      let isOver = this.purine > 300;
      return `今日嘌呤累计已达 ${this.purine}mg${isOver ? '（超标预警）' : '（偏高）'}，痛风与高尿酸人群需重点关注，避免浓肉汤、动物内脏及海鲜，建议每日多饮水（2000ml以上）促进尿酸排泄。`;
    }

    // 告警：胆固醇偏高 (300mg)
    if (this.cholesterol > 200) {
      let isOver = this.cholesterol > 300;
      return `今日胆固醇摄入已达 ${this.cholesterol}mg${isOver ? '（已超标）' : '（偏高）'}，建议减少蛋黄、动物油脂及油炸食物摄入，适当补充富含膳食纤维的燕麦与新鲜蔬菜。`;
    }

    // 告警：总热量超标
    if (this.totalDailyEnergy > this.targetEnergy) {
      let overEnergy = this.totalDailyEnergy - this.targetEnergy;
      return `今日摄入总热量已超出目标 ${overEnergy} 千卡，建议适当控制夜间加餐，餐后进行30分钟中低强度散步帮助能量消耗。`;
    }

    // 脂肪供能比偏高
    let macro: MacroNutrientSummary = NutritionCalculator.aggregateMacros('今日', this.todayRecords);
    if (macro.fatPercent > 35) {
      return `今日油脂供能比略高（${macro.fatPercent}%），建议减少烹饪用油，适度增加粗粮与新鲜叶菜摄入以平衡宏量结构。`;
    }

    return '今日三餐宏量营养素结构均衡，各项慢病风险指标平稳达标。建议继续保持规律作息与优质水分补给！';
  }

  getScoreColor(): string {
    if (this.todayRecords.length === 0) return '#CBD5E0';
    if (this.healthScore >= 80) return AppTheme.PRIMARY_COLOR;
    if (this.healthScore >= 60) return '#FF9800';
    return '#F44336';
  }

  getPurineBadge(): RiskBadgeInfo {
    if (this.todayRecords.length === 0) {
      let info: RiskBadgeInfo = { status: '未记录', color: '#888888', bgColor: '#F5F5F5' };
      return info;
    }
    if (this.purine > 300) {
      let info: RiskBadgeInfo = { status: '超标', color: '#F44336', bgColor: '#FFEBEE' };
      return info;
    }
    if (this.purine > 200) {
      let info: RiskBadgeInfo = { status: '偏高', color: '#FF9800', bgColor: '#FFF3E0' };
      return info;
    }
    let info: RiskBadgeInfo = { status: '正常', color: AppTheme.PRIMARY_COLOR, bgColor: '#E8F5E9' };
    return info;
  }

  getSodiumBadge(): RiskBadgeInfo {
    if (this.todayRecords.length === 0) {
      let info: RiskBadgeInfo = { status: '未记录', color: '#888888', bgColor: '#F5F5F5' };
      return info;
    }
    if (this.sodium > 2000) {
      let info: RiskBadgeInfo = { status: '超标', color: '#F44336', bgColor: '#FFEBEE' };
      return info;
    }
    if (this.sodium > 1500) {
      let info: RiskBadgeInfo = { status: '偏高', color: '#FF9800', bgColor: '#FFF3E0' };
      return info;
    }
    let info: RiskBadgeInfo = { status: '正常', color: AppTheme.PRIMARY_COLOR, bgColor: '#E8F5E9' };
    return info;
  }

  getCholesterolBadge(): RiskBadgeInfo {
    if (this.todayRecords.length === 0) {
      let info: RiskBadgeInfo = { status: '未记录', color: '#888888', bgColor: '#F5F5F5' };
      return info;
    }
    if (this.cholesterol > 300) {
      let info: RiskBadgeInfo = { status: '超标', color: '#F44336', bgColor: '#FFEBEE' };
      return info;
    }
    if (this.cholesterol > 200) {
      let info: RiskBadgeInfo = { status: '偏高', color: '#FF9800', bgColor: '#FFF3E0' };
      return info;
    }
    let info: RiskBadgeInfo = { status: '正常', color: AppTheme.PRIMARY_COLOR, bgColor: '#E8F5E9' };
    return info;
  }

  isTodaySelected(): boolean {
    return DateHelper.formatDateKey(this.selectedDate) === DateHelper.formatDateKey(new Date());
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        this.HeaderSection()

        // 当今日暂无记录时，展示友好的引导提示条
        if (this.todayRecords.length === 0) {
          this.EmptyStateBanner()
        }

        this.ScoreAndEnergySection()
        this.MacrosSection()
        this.RiskIndicatorsSection()
        this.SuggestionSection()

        Blank().height(20)
      }
      .padding({ left: 16, right: 16, top: 12, bottom: 20 })
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F7F8FA')
    .align(Alignment.Top)
    .scrollBar(BarState.Off)
  }

  @Builder
  HeaderSection() {
    Row() {
      Text(this.isTodaySelected() ? '今日概览' : '饮食概览')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')

      Blank()

      Row({ space: 6 }) {
        Text(this.dateText)
          .fontSize(14)
          .fontColor(AppTheme.TEXT_COLOR_NORMAL)

        if (!this.isTodaySelected()) {
          Text('回到今天')
            .fontSize(11)
            .fontColor(AppTheme.PRIMARY_COLOR)
            .backgroundColor('#E8F5E9')
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .borderRadius(8)
            .onClick(() => {
              this.selectedDate = new Date();
              this.loadTodayData();
            })
        }
      }
      .onClick(() => {
        DatePickerDialog.show({
          selected: this.selectedDate,
          onAccept: (value: DatePickerResult) => {
            if (value.year !== undefined && value.month !== undefined && value.day !== undefined) {
              this.selectedDate = new Date(value.year, value.month, value.day);
              this.loadTodayData();
            }
          }
        });
      })
    }
    .width('100%')
    .margin({ top: 8, bottom: 4 })
  }

  @Builder
  EmptyStateBanner() {
    Row({ space: 12 }) {
      Image($r('app.media.ic_record'))
        .width(22)
        .height(22)
        .fillColor(AppTheme.PRIMARY_COLOR)

      Column({ space: 2 }) {
        Text('今日暂无饮食记录')
          .fontSize(13)
          .fontWeight(FontWeight.Bold)
          .fontColor('#2D3748')
        Text('点击右侧按钮开始记录今日三餐')
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
        .padding({ left: 14, right: 14 })
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
  ScoreAndEnergySection() {
    Row() {
      // 左侧：评分环形图 (基于真实记录动态计算)
      Stack() {
        Progress({
          value: this.todayRecords.length > 0 ? this.healthScore : 0,
          total: 100,
          type: ProgressType.Ring
        })
          .width(90)
          .height(90)
          .color(this.getScoreColor())
          .backgroundColor('#EAEAEA')
          .style({ strokeWidth: 8 })

        Column() {
          if (this.todayRecords.length > 0) {
            Text(`${this.healthScore}`)
              .fontSize(26)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.getScoreColor())
            Text('分')
              .fontSize(12)
              .fontColor(AppTheme.TEXT_COLOR_NORMAL)
          } else {
            Text('--')
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor('#A0AEC0')
            Text('暂无')
              .fontSize(11)
              .fontColor(AppTheme.TEXT_COLOR_NORMAL)
          }
        }
      }

      // 右侧：能量进度条与摄入详情
      Column({ space: 8 }) {
        Row() {
          Text('饮食摄入 (千卡)').fontSize(13).fontColor('#666666')
          Blank()
          if (this.todayRecords.length > 0) {
            Text(`${this.todayRecords.length} 项记录`).fontSize(11).fontColor('#999999')
          }
        }
        .width('100%')

        Row() {
          Text(`${this.totalDailyEnergy}`).fontSize(22).fontWeight(FontWeight.Bold).fontColor('#333333')
          Text(` / ${this.targetEnergy}`).fontSize(13).fontColor(AppTheme.TEXT_COLOR_NORMAL).margin({ bottom: 2 })
        }.alignItems(VerticalAlign.Bottom)

        Progress({
          value: Math.min(this.totalDailyEnergy, this.targetEnergy),
          total: this.targetEnergy,
          type: ProgressType.Linear
        })
          .width('100%')
          .color(this.totalDailyEnergy > this.targetEnergy ? '#FF9800' : AppTheme.PRIMARY_COLOR)
          .backgroundColor('#EAEAEA')

        if (this.totalDailyEnergy <= this.targetEnergy) {
          Text(`还可摄入 ${this.targetEnergy - this.totalDailyEnergy} 千卡`)
            .fontSize(11)
            .fontColor(AppTheme.TEXT_COLOR_NORMAL)
        } else {
          Text(`已超出 ${this.totalDailyEnergy - this.targetEnergy} 千卡`)
            .fontSize(11)
            .fontColor('#F44336')
            .fontWeight(FontWeight.Medium)
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 24 })
    }
    .width('100%')
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .shadow({ radius: 10, color: 'rgba(0,0,0,0.03)', offsetY: 4 })
    .onClick(() => {
      this.onNavigateToRecord();
    })
  }

  @Builder
  MacrosSection() {
    Column({ space: 15 }) {
      Text('三大营养素').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#333333').width('100%')

      Row() {
        this.MacroItem('碳水', this.carbsGrams, this.targetCarbs, '#FF9800')
        this.MacroItem('蛋白质', this.proteinGrams, this.targetProtein, '#2196F3')
        this.MacroItem('脂肪', this.fatGrams, this.targetFat, '#E91E63')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .shadow({ radius: 10, color: 'rgba(0,0,0,0.03)', offsetY: 4 })
  }

  @Builder
  MacroItem(name: string, current: number, max: number, color: string) {
    Column({ space: 6 }) {
      Text(name).fontSize(13).fontColor('#555555').fontWeight(FontWeight.Medium)
      Stack() {
        Progress({ value: Math.min(current, max), total: max, type: ProgressType.Ring })
          .width(55).height(55)
          .color(color).backgroundColor('#F0F0F0')
          .style({ strokeWidth: 5 })
        Text(`${current}g`).fontSize(12).fontWeight(FontWeight.Bold).fontColor('#333333')
      }
      Text(`目标 ${max}g`).fontSize(11).fontColor(AppTheme.TEXT_COLOR_NORMAL)
    }
  }

  @Builder
  RiskIndicatorsSection() {
    Column({ space: 15 }) {
      Row() {
        Text('风险指标 (今日)').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#333333')
        Blank()
        Text('痛风 / 血压 / 血脂')
          .fontSize(11)
          .fontColor('#999999')
      }
      .width('100%')

      Row({ space: 12 }) {
        this.RiskItem('嘌呤', `${this.purine}mg`, this.getPurineBadge().status, this.getPurineBadge().color, this.getPurineBadge().bgColor)
        this.RiskItem('钠', `${this.sodium}mg`, this.getSodiumBadge().status, this.getSodiumBadge().color, this.getSodiumBadge().bgColor)
        this.RiskItem('胆固醇', `${this.cholesterol}mg`, this.getCholesterolBadge().status, this.getCholesterolBadge().color, this.getCholesterolBadge().bgColor)
      }
      .width('100%')
    }
    .width('100%')
  }

  @Builder
  RiskItem(name: string, value: string, status: string, statusColor: string, bgColor: string) {
    Column({ space: 8 }) {
      Text(name).fontSize(13).fontColor('#666666')
      Text(value).fontSize(15).fontWeight(FontWeight.Bold).fontColor('#333333')
      Text(status)
        .fontSize(11)
        .fontColor(statusColor)
        .backgroundColor(bgColor)
        .padding({ left: 6, right: 6, top: 3, bottom: 3 })
        .borderRadius(10)
    }
    .layoutWeight(1)
    .padding(12)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .shadow({ radius: 10, color: 'rgba(0,0,0,0.03)', offsetY: 4 })
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  SuggestionSection() {
    Column({ space: 10 }) {
      Row({ space: 8 }) {
        Text('💡').fontSize(18)
        Text('健康建议').fontSize(16).fontWeight(FontWeight.Bold).fontColor(AppTheme.PRIMARY_COLOR)
      }.width('100%')

      Text(this.suggestionText)
        .fontSize(13)
        .fontColor('#4A5568')
        .lineHeight(22)
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#F0FDF4')
    .borderRadius(16)
    .border({ width: 1, color: '#DCFCE7' })
    .shadow({ radius: 10, color: 'rgba(46, 139, 87, 0.05)', offsetY: 4 })
  }
}
