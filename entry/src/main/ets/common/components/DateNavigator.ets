import { AppTheme } from '../constants/AppTheme'

@Component
export struct DateNavigator {
  @Prop dateText: string = '';
  @Prop subText: string = '';
  
  // 左右点击事件回调
  onPrevClick?: () => void;
  onNextClick?: () => void;

  build() {
    Row() {
      // 左侧箭头
      Button({ type: ButtonType.Circle, stateEffect: true }) {
        Image($r('app.media.ic_arrow_left'))
          .width(24)
          .height(24)
          .fillColor('#666666')
      }
      .width(40)
      .height(40)
      .backgroundColor(Color.Transparent)
      .onClick(() => {
        if (this.onPrevClick) {
          this.onPrevClick();
        }
      })
      
      // 日期与汇总信息
      Column() {
        Text(this.dateText)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
        
        if (this.subText) {
          Text(this.subText)
            .fontSize(12)
            .fontColor(AppTheme.PRIMARY_COLOR)
            .margin({ top: 4 })
            .backgroundColor('#E8F5E9')
            .padding({ left: 10, right: 10, top: 2, bottom: 2 })
            .borderRadius(10)
        }
      }.alignItems(HorizontalAlign.Center)
      
      // 右侧箭头
      Button({ type: ButtonType.Circle, stateEffect: true }) {
        Image($r('app.media.ic_arrow_right'))
          .width(24)
          .height(24)
          .fillColor('#CCCCCC') // 默认今天不能看明天的，先置灰
      }
      .width(40)
      .height(40)
      .backgroundColor(Color.Transparent)
      .onClick(() => {
        if (this.onNextClick) {
          this.onNextClick();
        }
      })
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({ left: 16, right: 16, top: 10, bottom: 10 })
    .backgroundColor(Color.White)
    .shadow({ radius: 8, color: 'rgba(0,0,0,0.02)', offsetY: 4 })
  }
}
