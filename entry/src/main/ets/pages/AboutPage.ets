import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { AppTheme } from '../common/constants/AppTheme';

@Entry
@Component
struct AboutPage {
  build() {
    Column() {
      // 1. 顶部导航栏
      Row() {
        Row() {
          Image($r('app.media.ic_arrow_left'))
            .width(24)
            .height(24)
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          try {
            router.back();
          } catch (e) {}
        })

        Text('关于膳管家')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .margin({ right: 44 })
      }
      .width('100%')
      .height(56)
      .backgroundColor(Color.White)
      .padding({ left: 4, right: 4 })
      .shadow({ radius: 4, color: 'rgba(0,0,0,0.02)', offsetY: 2 })

      // 2. 主体滚动区
      Scroll() {
        Column({ space: 16 }) {
          // App Logo & 版本信息
          Column({ space: 10 }) {
            Image($r('app.media.app_icon'))
              .width(80)
              .height(80)

            Text('膳管家')
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')

            Text('版本 v1.0.0 Release')
              .fontSize(12)
              .fontColor('#999999')
              .backgroundColor('#F5F5F5')
              .padding({ left: 10, right: 10, top: 4, bottom: 4 })
              .borderRadius(10)
          }
          .width('100%')
          .padding({ top: 24, bottom: 20 })
          .alignItems(HorizontalAlign.Center)

          // 应用核心理念卡片
          Column({ space: 12 }) {
            Text('产品理念与核心特性')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
              .width('100%')

            Row({ space: 10 }) {
              Text('🔒').fontSize(20)
              Column({ space: 2 }) {
                Text('100% 离线优先与数据自主').fontSize(14).fontWeight(FontWeight.Medium).fontColor('#333333')
                Text('所有饮食记录、身体档案均存储于本地 SQLite 数据库中，零远程服务器上传。').fontSize(12).fontColor('#777777')
              }.layoutWeight(1).alignItems(HorizontalAlign.Start)
            }.width('100%')

            Divider().color('#F2F2F2').strokeWidth(1)

            Row({ space: 10 }) {
              Text('🥗').fontSize(20)
              Column({ space: 2 }) {
                Text('重点营养素摄入参考').fontSize(14).fontWeight(FontWeight.Medium).fontColor('#333333')
                Text('基于《中国居民膳食指南》，提供嘌呤、钠与胆固醇等重点成分的日常摄入平衡参考。').fontSize(12).fontColor('#777777')
              }.layoutWeight(1).alignItems(HorizontalAlign.Start)
            }.width('100%')

            Divider().color('#F2F2F2').strokeWidth(1)

            Row({ space: 10 }) {
              Text('⚡').fontSize(20)
              Column({ space: 2 }) {
                Text('无依赖原生丝滑体验').fontSize(14).fontWeight(FontWeight.Medium).fontColor('#333333')
                Text('基于鸿蒙原生 ArkTS 纯手工打磨全套图表与交互，响应迅速，轻巧省电。').fontSize(12).fontColor('#777777')
              }.layoutWeight(1).alignItems(HorizontalAlign.Start)
            }.width('100%')
          }
          .width('100%')
          .padding(20)
          .backgroundColor(Color.White)
          .borderRadius(16)
          .shadow({ radius: 8, color: 'rgba(0,0,0,0.03)', offsetY: 4 })

          // 条款与法律信息卡片（带有隐私协议独立入口）
          Column() {
            // 隐私协议独立入口
            Row() {
              Image($r('app.media.ic_tag'))
                .width(20)
                .height(20)
                .margin({ right: 12 })
              Text('隐私政策与协议')
                .fontSize(15)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
              Blank()
              Text('点击查看')
                .fontSize(13)
                .fontColor(AppTheme.PRIMARY_COLOR)
                .margin({ right: 4 })
              Image($r('app.media.ic_arrow_right'))
                .width(14)
                .height(14)
            }
            .width('100%')
            .padding({ top: 16, bottom: 16, left: 16, right: 16 })
            .onClick(() => {
              try {
                router.pushUrl({
                  url: 'pages/PrivacyPolicyPage'
                });
              } catch (e) {}
            })

            Divider().color('#F2F2F2').strokeWidth(1).margin({ left: 48, right: 16 })

            // 用户服务协议
            Row() {
              Image($r('app.media.ic_record'))
                .width(20)
                .height(20)
                .margin({ right: 12 })
              Text('用户使用指南与规范')
                .fontSize(15)
                .fontColor('#333333')
              Blank()
              Image($r('app.media.ic_arrow_right'))
                .width(14)
                .height(14)
            }
            .width('100%')
            .padding({ top: 16, bottom: 16, left: 16, right: 16 })
            .onClick(() => {
              AlertDialog.show({
                title: '用户使用规范',
                message: '欢迎使用膳管家。本应用旨在为您提供日常饮食营养辅助参考。本软件所有计算模型基于公开《中国居民膳食指南》，不构成任何处方性医疗诊断结论，疾病人群请遵医嘱。',
                confirm: {
                  value: '我已知晓',
                  action: () => {}
                }
              });
            })

            Divider().color('#F2F2F2').strokeWidth(1).margin({ left: 48, right: 16 })

            // 应用版本与离线运行状态
            Row() {
              Image($r('app.media.ic_target'))
                .width(20)
                .height(20)
                .margin({ right: 12 })
              Text('应用运行状态')
                .fontSize(15)
                .fontColor('#333333')
              Blank()
              Text('v1.0.0 (离线单机版)')
                .fontSize(12)
                .fontColor('#888888')
            }
            .width('100%')
            .padding({ top: 16, bottom: 16, left: 16, right: 16 })
            .onClick(() => {
              AlertDialog.show({
                title: '运行模式说明',
                message: '膳管家采用端侧离线优先架构（Offline-First），无需联网即可在本地设备完整使用全部记录、分析与食物库功能，数据安全自主。',
                confirm: {
                  value: '我知道了',
                  action: () => {}
                }
              });
            })
          }
          .width('100%')
          .backgroundColor(Color.White)
          .borderRadius(16)
          .shadow({ radius: 8, color: 'rgba(0,0,0,0.03)', offsetY: 4 })

          // 底部版权标识
          Column({ space: 4 }) {
            Text('东莞市嘉致网络信息有限公司 版权所有')
              .fontSize(12)
              .fontColor('#AAAAAA')
            Text('Copyright © 2026 东莞市嘉致网络信息有限公司. All Rights Reserved.')
              .fontSize(10)
              .fontColor('#BBBBBB')
          }
          .width('100%')
          .padding({ top: 16, bottom: 32 })
          .alignItems(HorizontalAlign.Center)
        }
        .padding({ left: 16, right: 16, top: 12, bottom: 20 })
      }
      .layoutWeight(1)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F7F8FA')
  }
}
