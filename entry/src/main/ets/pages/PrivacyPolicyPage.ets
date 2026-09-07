import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { AppTheme } from '../common/constants/AppTheme';

@Entry
@Component
struct PrivacyPolicyPage {
  build() {
    Column() {
      // 1. 顶部导航栏
      Row() {
        Row() {
          Image($r('app.media.ic_arrow_left'))
            .width(24)
            .height(24)
            .fillColor('#333333')
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          try {
            router.back();
          } catch (e) {}
        })

        Text('隐私政策与声明')
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
          // 核心承诺微章
          Row({ space: 10 }) {
            Text('🛡️').fontSize(24)
            Column({ space: 2 }) {
              Text('端侧本地优先，绝不上报云端')
                .fontSize(15)
                .fontWeight(FontWeight.Bold)
                .fontColor(AppTheme.PRIMARY_COLOR)
              Text('食养智评坚持尊重与捍卫您的数据自主权，所有健康饮食记录均严格存储在您的设备本地。')
                .fontSize(12)
                .fontColor('#555555')
                .lineHeight(18)
            }.layoutWeight(1).alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#E8F5E9')
          .borderRadius(14)

          // 条款内容卡片
          Column({ space: 18 }) {
            // 第一条
            Column({ space: 6 }) {
              Text('一、概述与原则')
                .fontSize(15)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
              Text('感谢您信任并使用“食养智评”（以下简称“本应用”）。我们深知个人隐私与健康数据对您的重要性，因此本应用在系统设计上严格遵循“最小必要”、“离线优先”和“透明可知”的最高隐私保护标准。')
                .fontSize(13)
                .fontColor('#666666')
                .lineHeight(20)
            }.width('100%').alignItems(HorizontalAlign.Start)

            Divider().color('#F2F2F2').strokeWidth(1)

            // 第二条
            Column({ space: 6 }) {
              Text('二、我们如何存储与处理数据')
                .fontSize(15)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
              Text('1. 存储位置：您录入的所有每日饮食餐段明细、自建食材、收藏食物、身体基础数据（身高/体重）以及慢病关注标签，均直接持久化于您终端设备的本地 SQLite 数据库文件中。\n2. 零云端上传：本应用无需联网即可完整运行全部核心功能，我们没有部署任何远程服务器用以收集、转存或分析您的个人健康信息。\n3. 账号体系：您的本地用户 ID 由设备端自增分配，账号与密码凭证均加密存储于端侧。')
                .fontSize(13)
                .fontColor('#666666')
                .lineHeight(20)
            }.width('100%').alignItems(HorizontalAlign.Start)

            Divider().color('#F2F2F2').strokeWidth(1)

            // 第三条
            Column({ space: 6 }) {
              Text('三、您的完整数据控制权')
                .fontSize(15)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
              Text('1. 自由导出：您可随时在「数据安全与管理 - 本地数据导出」中，将您的全部历史数据打包为标准 JSON 格式进行归档或转移。\n2. 随时清空：您可一键清空所有历史饮食摄入记录，且该操作不可撤销。\n3. 彻底注销：若您选择「注销用户」，系统将从本地数据库中彻底抹除您的账号、档案及全部饮食条目，实现物理级别的痕迹清除。')
                .fontSize(13)
                .fontColor('#666666')
                .lineHeight(20)
            }.width('100%').alignItems(HorizontalAlign.Start)

            Divider().color('#F2F2F2').strokeWidth(1)

            // 第四条
            Column({ space: 6 }) {
              Text('四、权限声明与第三方接入')
                .fontSize(15)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
              Text('1. 权限最小化：本应用仅在您执行数据复制或本地备份时调用系统剪贴板等必要能力，不索取任何多余权限。\n2. 无第三方追踪：本应用未嵌入任何第三方商业广告 SDK 或用户行为追踪分析插件。')
                .fontSize(13)
                .fontColor('#666666')
                .lineHeight(20)
            }.width('100%').alignItems(HorizontalAlign.Start)

            Divider().color('#F2F2F2').strokeWidth(1)

            // 第五条
            Column({ space: 6 }) {
              Text('五、医疗免责声明')
                .fontSize(15)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
              Text('本应用提供的营养学评估、健康综合评分、三色慢病警戒线及调理建议，仅供日常饮食生活习惯参考，不可替代执业医师、临床营养师的正式诊断或治疗建议。痛风、严重高血压及肾病患者在制定饮食计划时请务必遵循专业医嘱。')
                .fontSize(13)
                .fontColor('#888888')
                .lineHeight(20)
            }.width('100%').alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .padding(20)
          .backgroundColor(Color.White)
          .borderRadius(16)
          .shadow({ radius: 8, color: 'rgba(0,0,0,0.03)', offsetY: 4 })

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
