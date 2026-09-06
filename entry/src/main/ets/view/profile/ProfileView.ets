import { AppTheme } from '../../common/constants/AppTheme'

@Component
export struct ProfileView {
  @State bioAuthEnabled: boolean = true;

  build() {
    Column() {
      Scroll() {
        Column({ space: 16 }) {
          this.HeaderSection()
          this.HealthProfileCard()
          this.SettingsCard()
          this.DataManagementCard()
          Blank().height(30)
        }
        .padding({ left: 16, right: 16, top: 20, bottom: 20 })
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
  HeaderSection() {
    Row({ space: 16 }) {
      Stack() {
        Circle({ width: 64, height: 64 }).fill('#EAEAEA')
        Text('😊').fontSize(36)
      }
      
      Column({ space: 4 }) {
        Text('健康探索者').fontSize(20).fontWeight(FontWeight.Bold).fontColor('#333333')
        Text('ID: 88481234')
          .fontSize(12).fontColor('#999999')
        
        Row({ space: 4 }) {
          Circle({ width: 8, height: 8 }).fill(AppTheme.PRIMARY_COLOR)
          Text('健康状态: 良好').fontSize(12).fontColor(AppTheme.PRIMARY_COLOR)
        }
        .padding({ left: 8, right: 8, top: 4, bottom: 4 })
        .backgroundColor('#E8F5E9')
        .borderRadius(12)
        .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      
      Blank()
      
      Text('编辑')
        .fontSize(14)
        .fontColor('#666666')
    }
    .width('100%')
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .shadow({ radius: 8, color: 'rgba(0,0,0,0.03)', offsetY: 4 })
  }

  @Builder
  HealthProfileCard() {
    Column() {
      Row() {
        Text('健康档案').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#333333')
      }.width('100%').padding({ left: 16, top: 16, bottom: 8 })
      
      this.MenuRow($r('app.media.ic_body'), '基础身体数据', '175cm / 70kg')
      Divider().color('#F0F0F0').strokeWidth(1).margin({ left: 50, right: 16 })
      this.MenuRow($r('app.media.ic_target'), '健康目标', '减重 5kg')
      Divider().color('#F0F0F0').strokeWidth(1).margin({ left: 50, right: 16 })
      this.MenuRow($r('app.media.ic_tag'), '特殊疾病标签', '高尿酸 / 轻度脂肪肝')
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(16)
    .shadow({ radius: 8, color: 'rgba(0,0,0,0.03)', offsetY: 4 })
  }

  @Builder
  SettingsCard() {
    Column() {
      Row() {
        Text('核心设置').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#333333')
      }.width('100%').padding({ left: 16, top: 16, bottom: 8 })
      
      this.MenuRow($r('app.media.ic_slider'), '评分维度权重自定义', '已调高风险指标')
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(16)
    .shadow({ radius: 8, color: 'rgba(0,0,0,0.03)', offsetY: 4 })
  }

  @Builder
  DataManagementCard() {
    Column() {
      Row() {
        Text('数据安全与管理').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#333333')
      }.width('100%').padding({ left: 16, top: 16, bottom: 8 })
      
      this.MenuRow($r('app.media.ic_backup'), '本地数据导出 (JSON/CSV)', '上次备份: 昨天')
      Divider().color('#F0F0F0').strokeWidth(1).margin({ left: 50, right: 16 })
      this.MenuRow($r('app.media.ic_restore'), '恢复本地数据', '')
      Divider().color('#F0F0F0').strokeWidth(1).margin({ left: 50, right: 16 })
      
      // 生物识别解锁 (带 Switch)
      Row() {
        Image($r('app.media.ic_lock')).width(20).height(20).fillColor('#666666').margin({ right: 12 })
        Text('生物识别解锁').fontSize(15).fontColor('#333333')
        Blank()
        Toggle({ type: ToggleType.Switch, isOn: this.bioAuthEnabled })
          .selectedColor(AppTheme.PRIMARY_COLOR)
          .onChange((isOn: boolean) => {
            this.bioAuthEnabled = isOn;
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 16 })
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(16)
    .shadow({ radius: 8, color: 'rgba(0,0,0,0.03)', offsetY: 4 })
  }

  @Builder
  MenuRow(icon: Resource, title: string, value: string) {
    Row() {
      Image(icon).width(20).height(20).fillColor('#666666').margin({ right: 12 })
      Text(title).fontSize(15).fontColor('#333333')
      Blank()
      Text(value).fontSize(13).fontColor('#999999').margin({ right: 8 })
      Text('>').fontSize(16).fontColor('#CCCCCC')
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 16, bottom: 16 })
    .alignItems(VerticalAlign.Center)
  }
}
