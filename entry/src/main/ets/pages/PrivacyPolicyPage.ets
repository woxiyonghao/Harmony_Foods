import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import pasteboard from '@ohos.pasteboard';
import { AppTheme } from '../common/constants/AppTheme';

@Entry
@Component
struct PrivacyPolicyPage {
  // 复制文本到系统剪贴板
  private async copyToClipboard(text: string, tip: string) {
    try {
      let pasteData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text);
      let systemPasteboard = pasteboard.getSystemPasteboard();
      await systemPasteboard.setData(pasteData);
      promptAction.showToast({ message: tip });
    } catch (e) {
      promptAction.showToast({ message: text });
    }
  }

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

        Text('关于膳管家与隐私的声明')
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

      // 2. 正文滚动区
      Scroll() {
        Column({ space: 16 }) {
          // 标题与更新时间卡片
          Column({ space: 6 }) {
            Text('关于膳管家与隐私的声明')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1A1A1A')
              .textAlign(TextAlign.Center)

            Text('更新日期：2026.9.8')
              .fontSize(13)
              .fontColor('#888888')
              .textAlign(TextAlign.Center)
          }
          .width('100%')
          .padding({ top: 12, bottom: 4 })
          .alignItems(HorizontalAlign.Center)

          // 核心引言卡片
          Column({ space: 12 }) {
            Text('膳管家 是由 东莞市嘉致网络信息有限公司 （以下简称“我们”）为您提供的，用于查看各类食物营养及记录每日餐食应用的应用。本隐私声明由我们为处理您的个人信息而制定。')
              .fontSize(14)
              .fontColor('#333333')
              .lineHeight(22)

            Text('我们非常重视您的个人信息和隐私保护，将会按照法律要求和业界成熟的安全标准，为您的个人信息提供相应的安全保护措施。')
              .fontSize(14)
              .fontColor('#333333')
              .lineHeight(22)
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#F0F7F2')
          .borderRadius(14)

          // 条款详细卡片
          Column({ space: 20 }) {
            // 第1节
            Column({ space: 8 }) {
              Text('1. 我们如何收集和使用您的个人信息')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#222222')

              Text('我们仅在有合法性基础的情形下才会使用您的个人信息。根据适用的法律，我们可能会基于您的同意、为履行/订立您与我们的合同所必需、履行法定义务所必需等合法性基础，使用您的个人信息。')
                .fontSize(14)
                .fontColor('#444444')
                .lineHeight(22)

              Text('1.1 我们为您提供了基本功能服务和全量功能服务，您可以前往任意应用页面进行选择，不同设备或版本其路径可能存在差异，具体以您当前使用的设备为准。在基本功能服务下不收集个人信息，仅提供全量基本功能，不提供及隐私及获取设备权限等其他附加功能，这可能会影响您的使用体验。')
                .fontSize(14)
                .fontColor('#444444')
                .lineHeight(22)
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)

            Divider().color('#F2F2F2').strokeWidth(1)

            // 第2节
            Column({ space: 8 }) {
              Text('2. 管理您的个人信息')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#222222')

              Text('如您对您的数据主体权利有进一步要求或存在任何疑问、意见或建议，可通过本声明中“如何联系我们”章节中所述方式与我们取得联系，并行使您的相关权利。')
                .fontSize(14)
                .fontColor('#444444')
                .lineHeight(22)
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)

            Divider().color('#F2F2F2').strokeWidth(1)

            // 第3节
            Column({ space: 8 }) {
              Text('3. 信息存储地点及期限')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#222222')

              Text('3.1 我们承诺，除法律法规另有规定外，我们对您的信息的保存期限应当为实现处理目的所必要的最短时间。')
                .fontSize(14)
                .fontColor('#444444')
                .lineHeight(22)

              Text('3.2 上述信息将会传输并保存至本地应用，不保存到任何地区的服务器。')
                .fontSize(14)
                .fontColor('#444444')
                .lineHeight(22)
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)

            Divider().color('#F2F2F2').strokeWidth(1)

            // 第4节
            Column({ space: 8 }) {
              Text('4. 如何联系我们')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#222222')

              Text('您可通过以下方式联系我们，并行使您的相关权利，我们会尽快回复。')
                .fontSize(14)
                .fontColor('#444444')
                .lineHeight(22)

              Row({ space: 6 }) {
                Text('邮箱：')
                  .fontSize(14)
                  .fontColor('#444444')
                Text('1529742177@qq.com')
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(AppTheme.PRIMARY_COLOR)
                Text('（点击复制）')
                  .fontSize(12)
                  .fontColor('#888888')
              }
              .padding({ top: 4, bottom: 4 })
              .onClick(() => {
                this.copyToClipboard('1529742177@qq.com', '邮箱已复制到剪贴板');
              })

              Text('如果您对我们的回复不满意, 特别是当个人信息处理行为损害了您的合法权益时您还可以通过向有管辖权的人民法院提起诉讼、向行业自律协会或政府相关管理机构投诉等外部途径进行解决。 您也可以向我们了解可能适用的相关投诉途径的信息。')
                .fontSize(14)
                .fontColor('#444444')
                .lineHeight(22)
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)

            Divider().color('#F2F2F2').strokeWidth(1)

            // 生效日期
            Row() {
              Blank()
              Text('生效日期：2026.9.7')
                .fontSize(13)
                .fontColor('#888888')
            }
            .width('100%')
          }
          .width('100%')
          .padding(20)
          .backgroundColor(Color.White)
          .borderRadius(16)
          .shadow({ radius: 8, color: 'rgba(0,0,0,0.03)', offsetY: 4 })

          // 官方线上协议链接与复制
          Row({ space: 8 }) {
            Text('🌐').fontSize(16)
            Text('官方华为云隐私政策在线链接')
              .fontSize(12)
              .fontColor('#666666')
              .layoutWeight(1)
            Text('复制链接')
              .fontSize(12)
              .fontColor(AppTheme.PRIMARY_COLOR)
              .fontWeight(FontWeight.Medium)
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 12, bottom: 12 })
          .backgroundColor('#F5F7FA')
          .borderRadius(10)
          .onClick(() => {
            this.copyToClipboard(
              'https://agreement-drcn.hispace.dbankcloud.cn/index.html?lang=zh&agreementId=2034249778887405504',
              '隐私政策链接已复制到剪贴板'
            );
          })

          // 确认已知按钮
          Button('我已阅读并理解隐私政策')
            .width('100%')
            .height(48)
            .fontSize(15)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
            .backgroundColor(AppTheme.PRIMARY_COLOR)
            .borderRadius(24)
            .shadow({ radius: 8, color: 'rgba(46, 139, 87, 0.3)', offsetY: 4 })
            .margin({ top: 4, bottom: 32 })
            .onClick(() => {
              try {
                router.back();
              } catch (e) {}
            })
        }
        .padding({ left: 16, right: 16, top: 16, bottom: 20 })
      }
      .layoutWeight(1)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F7F8FA')
  }
}
