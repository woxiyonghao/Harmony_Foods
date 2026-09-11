import { AppTheme } from '../../common/constants/AppTheme'
import { FoodDBHelper } from '../../common/utils/FoodDBHelper'
import { DateHelper } from '../../common/utils/DateHelper'
import { DietRecordItem, UserProfile, cloneUserProfile } from '../../common/models/FoodItem'
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
  @Prop @Watch('onRefreshTriggerChange') refreshTrigger: number = 0;
  onNavigateToRecord: () => void = () => {};

  @StorageLink('profileVersion') @Watch('onProfileVersionChange') profileVersion: number = 0;
  @State userProfile: UserProfile = {
    id: '',
    nickname: '健康探索者',
    avatar: '🍎',
    height: 175,
    weight: 70,
    targetGoal: '维持健康体重',
    targetEnergy: 2100,
    diseaseTags: '无特殊关注',
    scoreWeight: '均衡健康模式',
    lastBackupTime: '未备份'
  };

  @State userHeight: number = 175;
  @State userWeight: number = 70;
  @State userGoal: string = '维持健康体重';
  @State diseaseTags: string = '无特殊关注';
  @State scoreWeight: string = '均衡健康模式';

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

  private isLoadingData: boolean = false;

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

  onRefreshTriggerChange() {
    this.loadTodayData();
  }

  onProfileVersionChange() {
    this.loadTodayData();
  }

  loadTodayDataSync() {
    let mem = AppStorage.get<UserProfile>('userProfile');
    if (mem) {
      this.userProfile = cloneUserProfile(mem);
      this.userHeight = mem.height || 175;
      this.userWeight = mem.weight || 70;
      this.userGoal = mem.targetGoal || '维持健康体重';
      this.diseaseTags = mem.diseaseTags || '无特殊关注';
      this.scoreWeight = mem.scoreWeight || '均衡健康模式';
      if (this.userProfile.targetEnergy > 0) {
        this.targetEnergy = this.userProfile.targetEnergy;
      }
      let targetMacros = NutritionCalculator.calculateTargetMacros(this.targetEnergy, this.userGoal);
      this.targetCarbs = targetMacros.carbs;
      this.targetProtein = targetMacros.protein;
      this.targetFat = targetMacros.fat;
      this.suggestionText = this.generateDynamicSuggestion();
    }
  }

  async loadTodayData() {
    this.loadTodayDataSync();
    if (this.isLoadingData) return;
    this.isLoadingData = true;
    try {
      let p = await FoodDBHelper.getUserProfile();
      this.userProfile = cloneUserProfile(p);
      this.userHeight = p.height || 175;
      this.userWeight = p.weight || 70;
      this.userGoal = p.targetGoal || '维持健康体重';
      this.diseaseTags = p.diseaseTags || '无特殊关注';
      this.scoreWeight = p.scoreWeight || '均衡健康模式';
      this.dateText = DateHelper.formatDisplayDate(this.selectedDate);
      let dateKey = DateHelper.formatDateKey(this.selectedDate);

      // 动态同步用户目标热量与宏量配比
      if (this.userProfile && this.userProfile.targetEnergy > 0) {
        this.targetEnergy = this.userProfile.targetEnergy;
      }
      let targetMacros = NutritionCalculator.calculateTargetMacros(this.targetEnergy, this.userGoal);
      this.targetCarbs = targetMacros.carbs;
      this.targetProtein = targetMacros.protein;
      this.targetFat = targetMacros.fat;

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

      // 4. 健康评分计算 (支持动态联动个性化慢病标签与自定义评分维度权重)
      let scoreRes: ScoreSummary = NutritionCalculator.calculateHealthScore(this.todayRecords, '今日', this.userProfile);
      this.healthScore = scoreRes.score;
      this.scoreEvaluation = scoreRes.evaluation;

      // 5. 生成智能动态健康建议
      this.suggestionText = this.generateDynamicSuggestion();
    } finally {
      this.isLoadingData = false;
    }
  }

  getHomeBmi(): number {
    let h = this.userHeight;
    let w = this.userWeight;
    if (h <= 0) return 22.0;
    let hm = h / 100;
    return Math.round((w / (hm * hm)) * 10) / 10;
  }

  getHomeBmiStatus(): string {
    let bmi = this.getHomeBmi();
    if (bmi < 18.5) return '偏瘦';
    if (bmi < 24.0) return '正常';
    if (bmi < 28.0) return '偏重';
    return '肥胖';
  }

  getHomeBmiColor(): string {
    let bmi = this.getHomeBmi();
    if (bmi >= 18.5 && bmi < 24.0) return AppTheme.PRIMARY_COLOR;
    if (bmi >= 24.0 && bmi < 28.0) return '#FF9800';
    return '#F44336';
  }

  generateDynamicSuggestion(): string {
    let tags = this.diseaseTags || '无特殊关注';
    let goal = this.userGoal || '维持健康体重';
    let h = this.userHeight;
    let w = this.userWeight;
    let bmi = this.getHomeBmi();

    if (this.todayRecords.length === 0) {
      let advice = '全天保持规律均衡饮食，足量温水摄入。';
      if (goal.includes('减重')) {
        advice = '全天建议适当控制精制碳水，适度提高优质蛋白质摄入并创造适度热量缺口。';
      } else if (goal.includes('增肌')) {
        advice = '全天建议每公斤体重摄入 1.5-2.0g 优质蛋白质，搭配优质慢碳储备运动糖原。';
      } else if (goal.includes('血压') || goal.includes('控盐') || tags.includes('血压')) {
        advice = '全天控盐建议 ≤ 5g（钠 ≤ 1500mg），避免酱腌制品，多补充香蕉、菠菜等高钾蔬果。';
      } else if (goal.includes('尿酸') || goal.includes('痛风') || tags.includes('尿酸')) {
        advice = '全天严格限制动物内脏与浓肉汤，全天温水饮用 ≥ 2000ml 以促进尿酸平稳代谢。';
      } else if (goal.includes('血脂') || goal.includes('胆固醇') || tags.includes('血脂')) {
        advice = '控制烹调用油与肥肉摄入，多食用燕麦、木耳与豆制品等水溶性膳食纤维。';
      }
      return `当前身体指标：${h}cm / ${w}kg (BMI ${bmi} ${this.getHomeBmiStatus()})，健康目标【${goal}】。今日建议：${advice} 点击下方「去记录」添加今日饮食。`;
    }

    let macro: MacroNutrientSummary = NutritionCalculator.aggregateMacros('今日', this.todayRecords);

    // 个性化慢病标签优先提醒
    if ((tags.includes('尿酸') || tags.includes('痛风')) && this.purine > 180) {
      return `关注痛风/尿酸健康：今日累计嘌呤已达 ${this.purine}mg，建议控制浓肉汤、海鲜与动物内脏，全天保证2000ml温水促进尿酸排泄。`;
    }

    if ((tags.includes('血压') || tags.includes('控盐')) && this.sodium > 1400) {
      return `关注高血压/控盐健康：今日钠摄入已达 ${this.sodium}mg，建议减少酱油、腌腊制品与咸味零食，优选蒸煮低盐菜肴。`;
    }

    if ((tags.includes('血脂') || tags.includes('脂肪肝')) && (this.cholesterol > 180 || macro.fatPercent > 32)) {
      return `关注血脂与脂肪肝：建议后续餐食适度减少动物油脂与高油煎炸，增加粗粮、深色蔬菜等膳食纤维以辅助代谢。`;
    }

    // 健康目标联动提醒
    if (goal.includes('增肌') && this.proteinGrams < (this.targetProtein * 0.5)) {
      return `增肌目标指引：今日蛋白质已摄入 ${this.proteinGrams}g（目标 ${this.targetProtein}g），可适当补充水煮蛋、鸡胸肉或豆制品等优质蛋白。`;
    }

    if (goal.includes('减重') && this.totalDailyEnergy > this.targetEnergy) {
      let overEnergy = this.totalDailyEnergy - this.targetEnergy;
      return `减重目标指引：今日能量已超出预设目标 ${overEnergy} 千卡，建议晚间避免加餐并适度散步活动，促进热量消耗。`;
    }

    // 钠摄入偏高提醒
    if (this.sodium > 1500) {
      let isOver = this.sodium > 2000;
      return `今日钠摄入已达 ${this.sodium}mg${isOver ? '（高于膳食推荐参考值2000mg）' : '（接近推荐值）'}，建议后续餐食以清淡少盐为主，减少高盐调味品，适当多饮水保持水分平衡。`;
    }

    // 嘌呤偏高提醒
    if (this.purine > 200) {
      let isOver = this.purine > 300;
      return `今日嘌呤累计已达 ${this.purine}mg${isOver ? '（处于较高水平）' : '（略微偏高）'}，关注嘌呤的朋友建议后续餐食适度减少动物内脏与浓肉汤，保证充足温水摄入。`;
    }

    // 胆固醇偏高提醒
    if (this.cholesterol > 200) {
      let isOver = this.cholesterol > 300;
      return `今日胆固醇摄入已达 ${this.cholesterol}mg${isOver ? '（高于推荐参考值300mg）' : '（偏高）'}，建议适度控制动物油脂与煎炸食物，适当补充富含膳食纤维的蔬菜与粗粮。`;
    }

    // 总热量提醒
    if (this.totalDailyEnergy > this.targetEnergy) {
      let overEnergy = this.totalDailyEnergy - this.targetEnergy;
      return `今日摄入总能量已超出预设目标 ${overEnergy} 千卡，建议适当控制夜间加餐，餐后适度散步活动帮助能量平衡。`;
    }

    // 脂肪供能比偏高
    if (macro.fatPercent > 35) {
      return `今日油脂供能比略高（${macro.fatPercent}%），建议烹饪时适当减少食用油用量，适度增加粗粮与新鲜蔬菜以平衡营养比例。`;
    }

    return '今日三餐宏量营养素结构良好，各项营养成分摄入平稳均衡。建议继续保持规律作息与充足水分补给！';
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
      let info: RiskBadgeInfo = { status: '偏高', color: '#FF9800', bgColor: '#FFF3E0' };
      return info;
    }
    if (this.purine > 200) {
      let info: RiskBadgeInfo = { status: '适中', color: AppTheme.PRIMARY_COLOR, bgColor: '#E8F5E9' };
      return info;
    }
    let info: RiskBadgeInfo = { status: '理想', color: AppTheme.PRIMARY_COLOR, bgColor: '#E8F5E9' };
    return info;
  }

  getSodiumBadge(): RiskBadgeInfo {
    if (this.todayRecords.length === 0) {
      let info: RiskBadgeInfo = { status: '未记录', color: '#888888', bgColor: '#F5F5F5' };
      return info;
    }
    if (this.sodium > 2000) {
      let info: RiskBadgeInfo = { status: '偏高', color: '#FF9800', bgColor: '#FFF3E0' };
      return info;
    }
    if (this.sodium > 1500) {
      let info: RiskBadgeInfo = { status: '适中', color: AppTheme.PRIMARY_COLOR, bgColor: '#E8F5E9' };
      return info;
    }
    let info: RiskBadgeInfo = { status: '理想', color: AppTheme.PRIMARY_COLOR, bgColor: '#E8F5E9' };
    return info;
  }

  getCholesterolBadge(): RiskBadgeInfo {
    if (this.todayRecords.length === 0) {
      let info: RiskBadgeInfo = { status: '未记录', color: '#888888', bgColor: '#F5F5F5' };
      return info;
    }
    if (this.cholesterol > 300) {
      let info: RiskBadgeInfo = { status: '偏高', color: '#FF9800', bgColor: '#FFF3E0' };
      return info;
    }
    if (this.cholesterol > 200) {
      let info: RiskBadgeInfo = { status: '适中', color: AppTheme.PRIMARY_COLOR, bgColor: '#E8F5E9' };
      return info;
    }
    let info: RiskBadgeInfo = { status: '理想', color: AppTheme.PRIMARY_COLOR, bgColor: '#E8F5E9' };
    return info;
  }

  isTodaySelected(): boolean {
    return DateHelper.formatDateKey(this.selectedDate) === DateHelper.formatDateKey(new Date());
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        this.HeaderSection()

        // 核心健康档案与目标概览卡片 (直观联动身体数据、目标、膳食关注、评分模式 4 大设置)
        this.HealthProfileOverviewCard()

        // 当今日暂无记录时，展示友好的引导提示条
        if (this.todayRecords.length === 0) {
          this.EmptyStateBanner()
        }

        this.ScoreAndEnergySection()
        this.MacrosSection()
        this.RiskIndicatorsSection()
        this.SuggestionSection()

        Blank().height(80)
      }
      .padding({ left: 16, right: 16, top: 16, bottom: 20 })
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F7F8FA')
    .align(Alignment.Top)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
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
  HealthProfileOverviewCard() {
    Column({ space: 10 }) {
      // 头部标题与当前目标
      Row() {
        Row({ space: 6 }) {
          Image($r('app.media.ic_target'))
            .width(18)
            .height(18)
          Text(`目标：${this.userGoal}`)
            .fontSize(15)
            .fontWeight(FontWeight.Bold)
            .fontColor(AppTheme.PRIMARY_COLOR)
        }

        Blank()

        Text(`${this.targetEnergy} kcal/日`)
          .fontSize(12)
          .fontColor(AppTheme.PRIMARY_COLOR)
          .backgroundColor('#E8F5E9')
          .padding({ left: 8, right: 8, top: 3, bottom: 3 })
          .borderRadius(8)
          .fontWeight(FontWeight.Medium)
      }
      .width('100%')

      Divider().color('#F0F0F0').strokeWidth(1)

      // 第一行：身体指标与 BMI 状态（完整横向展开，充裕空间）
      Row() {
        Row({ space: 6 }) {
          Image($r('app.media.ic_body'))
            .width(16)
            .height(16)
          Text('身体指标:')
            .fontSize(12)
            .fontColor('#888888')
          Text(`${this.userHeight}cm / ${this.userWeight}kg`)
            .fontSize(13)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
        }

        Blank()

        Row({ space: 4 }) {
          Text(`BMI ${this.getHomeBmi()}`)
            .fontSize(12)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.getHomeBmiColor())
          Text(`(${this.getHomeBmiStatus()})`)
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.getHomeBmiColor())
        }
        .backgroundColor('#F7F8FA')
        .padding({ left: 8, right: 8, top: 2, bottom: 2 })
        .borderRadius(6)
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      // 第二行：膳食关注与评分模式（胶囊徽标展示，充裕空间，无截断）
      Row({ space: 8 }) {
        // 膳食关注
        Row({ space: 5 }) {
          Image($r('app.media.ic_tag'))
            .width(14)
            .height(14)
          Text(this.diseaseTags || '无特殊关注')
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .fontColor('#2E7D32')
        }
        .padding({ left: 8, right: 8, top: 5, bottom: 5 })
        .backgroundColor('#E8F5E9')
        .borderRadius(8)
        .layoutWeight(1)

        // 评分模式
        Row({ space: 5 }) {
          Image($r('app.media.ic_slider'))
            .width(14)
            .height(14)
          Text(this.scoreWeight || '均衡健康模式')
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1565C0')
        }
        .padding({ left: 8, right: 8, top: 5, bottom: 5 })
        .backgroundColor('#E3F2FD')
        .borderRadius(8)
      }
      .width('100%')
    }
    .width('100%')
    .padding(14)
    .backgroundColor(Color.White)
    .borderRadius(14)
    .shadow({ radius: 8, color: 'rgba(0,0,0,0.03)', offsetY: 4 })
  }

  @Builder
  EmptyStateBanner() {
    Row({ space: 12 }) {
      Image($r('app.media.ic_record'))
        .width(22)
        .height(22)

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
          Text(`饮食摄入 (${this.userProfile ? (this.userProfile.targetGoal || '维持健康体重') : '维持健康体重'})`).fontSize(12).fontColor('#666666')
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
        // 碳水
        Column({ space: 6 }) {
          Text('碳水').fontSize(13).fontColor('#555555').fontWeight(FontWeight.Medium)
          Stack() {
            Progress({
              value: Math.min(this.carbsGrams, this.targetCarbs),
              total: this.targetCarbs,
              type: ProgressType.Ring
            })
              .width(55).height(55)
              .color('#FF9800').backgroundColor('#F0F0F0')
              .style({ strokeWidth: 5 })
            Text(`${this.carbsGrams}g`).fontSize(12).fontWeight(FontWeight.Bold).fontColor('#333333')
          }
          Text(`目标 ${this.targetCarbs}g`).fontSize(11).fontColor(AppTheme.TEXT_COLOR_NORMAL)
        }

        // 蛋白质
        Column({ space: 6 }) {
          Text('蛋白质').fontSize(13).fontColor('#555555').fontWeight(FontWeight.Medium)
          Stack() {
            Progress({
              value: Math.min(this.proteinGrams, this.targetProtein),
              total: this.targetProtein,
              type: ProgressType.Ring
            })
              .width(55).height(55)
              .color('#2196F3').backgroundColor('#F0F0F0')
              .style({ strokeWidth: 5 })
            Text(`${this.proteinGrams}g`).fontSize(12).fontWeight(FontWeight.Bold).fontColor('#333333')
          }
          Text(`目标 ${this.targetProtein}g`).fontSize(11).fontColor(AppTheme.TEXT_COLOR_NORMAL)
        }

        // 脂肪
        Column({ space: 6 }) {
          Text('脂肪').fontSize(13).fontColor('#555555').fontWeight(FontWeight.Medium)
          Stack() {
            Progress({
              value: Math.min(this.fatGrams, this.targetFat),
              total: this.targetFat,
              type: ProgressType.Ring
            })
              .width(55).height(55)
              .color('#E91E63').backgroundColor('#F0F0F0')
              .style({ strokeWidth: 5 })
            Text(`${this.fatGrams}g`).fontSize(12).fontWeight(FontWeight.Bold).fontColor('#333333')
          }
          Text(`目标 ${this.targetFat}g`).fontSize(11).fontColor(AppTheme.TEXT_COLOR_NORMAL)
        }
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
  RiskIndicatorsSection() {
    Column({ space: 15 }) {
      Row() {
        Text('重点营养素关注 (今日)').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#333333')
        Blank()
        Text('膳食平衡参考')
          .fontSize(11)
          .fontColor('#999999')
      }
      .width('100%')

      Row({ space: 12 }) {
        // 嘌呤
        Column({ space: 8 }) {
          Text('嘌呤').fontSize(13).fontColor('#666666')
          Text(`${this.purine}mg`).fontSize(15).fontWeight(FontWeight.Bold).fontColor('#333333')
          Text(this.getPurineBadge().status)
            .fontSize(11)
            .fontColor(this.getPurineBadge().color)
            .backgroundColor(this.getPurineBadge().bgColor)
            .padding({ left: 6, right: 6, top: 3, bottom: 3 })
            .borderRadius(10)
        }
        .layoutWeight(1)
        .padding(12)
        .backgroundColor(Color.White)
        .borderRadius(12)
        .shadow({ radius: 10, color: 'rgba(0,0,0,0.03)', offsetY: 4 })
        .alignItems(HorizontalAlign.Center)

        // 钠
        Column({ space: 8 }) {
          Text('钠').fontSize(13).fontColor('#666666')
          Text(`${this.sodium}mg`).fontSize(15).fontWeight(FontWeight.Bold).fontColor('#333333')
          Text(this.getSodiumBadge().status)
            .fontSize(11)
            .fontColor(this.getSodiumBadge().color)
            .backgroundColor(this.getSodiumBadge().bgColor)
            .padding({ left: 6, right: 6, top: 3, bottom: 3 })
            .borderRadius(10)
        }
        .layoutWeight(1)
        .padding(12)
        .backgroundColor(Color.White)
        .borderRadius(12)
        .shadow({ radius: 10, color: 'rgba(0,0,0,0.03)', offsetY: 4 })
        .alignItems(HorizontalAlign.Center)

        // 胆固醇
        Column({ space: 8 }) {
          Text('胆固醇').fontSize(13).fontColor('#666666')
          Text(`${this.cholesterol}mg`).fontSize(15).fontWeight(FontWeight.Bold).fontColor('#333333')
          Text(this.getCholesterolBadge().status)
            .fontSize(11)
            .fontColor(this.getCholesterolBadge().color)
            .backgroundColor(this.getCholesterolBadge().bgColor)
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
      .width('100%')
    }
    .width('100%')
  }

  @Builder
  SuggestionSection() {
    Column({ space: 10 }) {
      Row({ space: 8 }) {
        Text('💡').fontSize(18)
        Text('日常膳食平衡建议').fontSize(16).fontWeight(FontWeight.Bold).fontColor(AppTheme.PRIMARY_COLOR)
      }.width('100%')

      Text(this.suggestionText)
        .fontSize(13)
        .fontColor('#4A5568')
        .lineHeight(22)

      Divider().color('#DCFCE7').strokeWidth(1).margin({ top: 4, bottom: 2 })

      // 常驻医疗免责声明
      Row({ space: 4 }) {
        Text('⚠️ 免责声明：本应用所有数据与建议基于《中国居民膳食指南》等公开营养资料提供健康生活参考，不构成任何医疗诊断或治疗方案，慢病及特殊人群请遵医嘱。')
          .fontSize(11)
          .fontColor('#718096')
          .lineHeight(16)
      }
      .width('100%')
      .padding({ top: 4 })
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#F0FDF4')
    .borderRadius(16)
    .border({ width: 1, color: '#DCFCE7' })
    .shadow({ radius: 10, color: 'rgba(46, 139, 87, 0.05)', offsetY: 4 })
  }
}
