import { AppTheme } from '../../common/constants/AppTheme'

@Component
export struct AnalysisView {
  @State timeMode: string = '周';
  private timeModes: string[] = ['日', '周', '月'];

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
          // 2. 时间维度切换器 (Segmented Control)
          this.TimeSegmentSelector()

          // 3. 营养素摄入图表卡片
          this.NutritionChartCard()

          // 4. 风险指标趋势图卡片
          this.RiskChartCard()

          // 5. 历史评分变化趋势卡片
          this.ScoreChartCard()

          Blank().height(30) // 底部留白
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
          .padding({ left: 24, right: 24, top: 8, bottom: 8 })
          .borderRadius(16)
          .shadow(this.timeMode === mode ? { radius: 8, color: 'rgba(0,0,0,0.05)', offsetY: 2 } : { radius: 0 })
          .onClick(() => {
            this.timeMode = mode;
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

      // 模拟多色堆叠柱状图 (碳水/蛋白/脂肪)
      Row({ space: 12 }) {
        ForEach([
          { label: '一', vals: [40, 30, 20] },
          { label: '二', vals: [50, 20, 20] },
          { label: '三', vals: [45, 35, 15] },
          { label: '四', vals: [30, 40, 20] },
          { label: '五', vals: [60, 20, 10] },
          { label: '六', vals: [40, 40, 15] },
          { label: '日', vals: [55, 25, 25] }
        ], (item: any) => {
          Column() {
            Blank() // 占位把柱子往下压
            Column() {
              // 碳水
              Column().width('100%').height(`${item.vals[0]}%`).backgroundColor('#FF9800').borderRadius({ topLeft: 4, topRight: 4 })
              // 蛋白
              Column().width('100%').height(`${item.vals[1]}%`).backgroundColor('#2196F3')
              // 脂肪
              Column().width('100%').height(`${item.vals[2]}%`).backgroundColor('#E91E63').borderRadius({ bottomLeft: 4, bottomRight: 4 })
            }
            .width(16)
            
            Text(item.label).fontSize(11).fontColor('#999999').margin({ top: 8 })
          }
          .height(130)
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)
      
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
      Row({ space: 8 }) {
        Image($r('app.media.ic_risk')).width(18).height(18).fillColor('#F44336')
        Text('风险指标超标预警').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#333333')
      }
      .width('100%')
      .margin({ bottom: 16 })

      // 模拟风险指标的条形图展示 (嘌呤)
      Text('嘌呤摄入量 (mg)').fontSize(12).fontColor('#666666').width('100%').margin({ bottom: 12 })
      
      Row({ space: 14 }) {
        ForEach([150, 200, 320, 180, 120, 280, 190], (val: number, idx: number) => {
          Column() {
            Blank()
            // 超过300显示红色预警，否则绿色
            Column()
              .width(20)
              .height(`${Math.min((val / 400) * 100, 100)}%`)
              .backgroundColor(val > 300 ? '#F44336' : AppTheme.PRIMARY_COLOR)
              .borderRadius({ topLeft: 4, topRight: 4 })
            Text(['一','二','三','四','五','六','日'][idx]).fontSize(11).fontColor('#999999').margin({ top: 8 })
          }
          .height(110)
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)
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
        Text('均分 85').fontSize(12).fontColor(AppTheme.PRIMARY_COLOR).backgroundColor('#E8F5E9').padding({ left: 8, right: 8, top: 2, bottom: 2 }).borderRadius(10)
      }
      .width('100%')
      .margin({ bottom: 16 })

      // 模拟折线图/柱状图 (展示7天评分)
      Row({ space: 14 }) {
        ForEach([80, 85, 92, 78, 88, 95, 82], (score: number, idx: number) => {
          Column() {
            Blank()
            Text(`${score}`).fontSize(10).fontColor('#666666').margin({ bottom: 4 })
            Column()
              .width(20)
              .height(`${(score / 100) * 100}%`)
              .backgroundColor(AppTheme.PRIMARY_COLOR)
              .opacity(0.8)
              .borderRadius({ topLeft: 6, topRight: 6 })
            Text(['一','二','三','四','五','六','日'][idx]).fontSize(11).fontColor('#999999').margin({ top: 8 })
          }
          .height(110)
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)
    }
    .width('100%')
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .shadow({ radius: 8, color: 'rgba(0,0,0,0.03)', offsetY: 4 })
  }

  @Builder
  ChartLegend(color: string, label: string) {
    Row({ space: 4 }) {
      Circle({ width: 8, height: 8 }).fill(color)
      Text(label).fontSize(11).fontColor('#666666')
    }
  }
}
