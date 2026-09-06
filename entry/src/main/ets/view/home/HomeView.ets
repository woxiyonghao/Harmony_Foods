import { AppTheme } from '../../common/constants/AppTheme'

@Component
export struct HomeView {
  build() {
    Scroll() {
      Column({ space: 20 }) {
        this.HeaderSection()
        this.ScoreAndEnergySection()
        this.MacrosSection()
        this.RiskIndicatorsSection()
        this.SuggestionSection()
      }
      .padding(20)
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F7F8FA') // 浅灰色背景，让卡片悬浮感更强
    .align(Alignment.Top)
  }

  @Builder
  HeaderSection() {
    Row() {
      Text('今日概览')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
      Blank()
      Text('9月6日')
        .fontSize(14)
        .fontColor(AppTheme.TEXT_COLOR_NORMAL)
    }
    .width('100%')
    .margin({ top: 10 })
  }

  @Builder
  ScoreAndEnergySection() {
    Row() {
      // 左侧：评分环形图
      Stack() {
        Progress({ value: 88, total: 100, type: ProgressType.Ring })
          .width(90)
          .height(90)
          .color(AppTheme.PRIMARY_COLOR)
          .backgroundColor('#EAEAEA')
          .style({ strokeWidth: 8 })
          
        Column() {
          Text('88').fontSize(26).fontWeight(FontWeight.Bold).fontColor(AppTheme.PRIMARY_COLOR)
          Text('分').fontSize(12).fontColor(AppTheme.TEXT_COLOR_NORMAL)
        }
      }
      
      // 右侧：能量进度条
      Column({ space: 8 }) {
        Text('饮食摄入 (千卡)').fontSize(13).fontColor('#666666')
        
        Row() {
          Text('1450').fontSize(22).fontWeight(FontWeight.Bold).fontColor('#333333')
          Text(' / 2100').fontSize(13).fontColor(AppTheme.TEXT_COLOR_NORMAL).margin({ bottom: 2 })
        }.alignItems(VerticalAlign.Bottom)
        
        Progress({ value: 1450, total: 2100, type: ProgressType.Linear })
          .width('100%')
          .color(AppTheme.PRIMARY_COLOR)
          .backgroundColor('#EAEAEA')
          // .style({ strokeWidth: 10 }) // 部分版本 API 支持设置 linear 宽度
          
        Text('还可摄入 650 千卡').fontSize(11).fontColor(AppTheme.TEXT_COLOR_NORMAL)
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
  }

  @Builder
  MacrosSection() {
    Column({ space: 15 }) {
      Text('三大营养素').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#333333').width('100%')
      
      Row() {
        this.MacroItem('碳水', 150, 250, '#FF9800')
        this.MacroItem('蛋白质', 65, 80, '#2196F3')
        this.MacroItem('脂肪', 40, 60, '#E91E63')
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
        Progress({ value: current, total: max, type: ProgressType.Ring })
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
      Text('风险指标 (今日)').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#333333').width('100%')
      
      Row({ space: 12 }) {
        this.RiskItem('嘌呤', '120mg', '正常', AppTheme.PRIMARY_COLOR, '#E8F5E9')
        this.RiskItem('钠', '1800mg', '偏高', '#FF9800', '#FFF3E0')
        this.RiskItem('胆固醇', '150mg', '正常', AppTheme.PRIMARY_COLOR, '#E8F5E9')
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
      
      Text('今日钠摄入已逼近上限，建议晚餐避免腌制食品和重口菜肴，尽量以清淡、水煮为主，并多喝水促进代谢。')
        .fontSize(13)
        .fontColor('#4A5568')
        .lineHeight(22)
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#F0FDF4') // 极淡的绿色背景，契合健康主题
    .borderRadius(16)
    .border({ width: 1, color: '#DCFCE7' })
    .shadow({ radius: 10, color: 'rgba(46, 139, 87, 0.05)', offsetY: 4 })
  }
}
