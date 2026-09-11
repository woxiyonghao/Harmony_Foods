import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { AppTheme } from '../common/constants/AppTheme';
import { FoodDBHelper } from '../common/utils/FoodDBHelper';

@Entry
@Component
struct DataManagePage {
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

        Text('恢复与重置数据')
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
          // 卡片 1: 恢复预置数据
          Column({ space: 12 }) {
            Row({ space: 8 }) {
              Image($r('app.media.ic_restore'))
                .width(22)
                .height(22)
              Text('恢复官方预置健康食物与收藏')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
            }.width('100%')

            Text('如果食物库或初始收藏被误删，可通过此项一键补齐官方推荐的经典健康食物库与低嘌呤/低钠示例配置，不会删除您已记录的饮食数据。')
              .fontSize(13)
              .fontColor('#666666')
              .lineHeight(19)

            Button('一键恢复预置食物数据')
              .width('100%')
              .height(44)
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor(AppTheme.PRIMARY_COLOR)
              .backgroundColor('#E8F5E9')
              .borderRadius(22)
              .onClick(() => {
                AlertDialog.show({
                  title: '确认恢复预置食物？',
                  message: '将重新补充系统默认食物与默认收藏推荐，不会影响已有饮食日记。',
                  primaryButton: {
                    value: '取消',
                    action: () => {}
                  },
                  secondaryButton: {
                    value: '确认恢复',
                    action: async () => {
                      await FoodDBHelper.restorePresetFoods();
                      try {
                        promptAction.showToast({ message: '已成功恢复预置数据' });
                      } catch (e) {}
                    }
                  }
                });
              })
          }
          .width('100%')
          .padding(20)
          .backgroundColor(Color.White)
          .borderRadius(16)
          .shadow({ radius: 8, color: 'rgba(0,0,0,0.03)', offsetY: 4 })

          // 卡片 2: 清空饮食记录
          Column({ space: 12 }) {
            Row({ space: 8 }) {
              Image($r('app.media.ic_trash'))
                .width(22)
                .height(22)
              Text('清空所有历史饮食记录')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
            }.width('100%')

            Text('移除所有日期的摄入记录明细。食物库、收藏夹以及您的个人健康档案将继续完整保留。')
              .fontSize(13)
              .fontColor('#666666')
              .lineHeight(19)

            Button('清空全部饮食记录')
              .width('100%')
              .height(44)
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('#FF9800')
              .backgroundColor('#FFF3E0')
              .borderRadius(22)
              .onClick(() => {
                AlertDialog.show({
                  title: '确认清空记录？',
                  message: '清空后所有历史日期的饮食记录将彻底删除且无法找回，确认继续吗？',
                  primaryButton: {
                    value: '取消',
                    action: () => {}
                  },
                  secondaryButton: {
                    value: '确认清空',
                    fontColor: '#F44336',
                    action: async () => {
                      await FoodDBHelper.clearAllDietRecords();
                      try {
                        promptAction.showToast({ message: '已清空所有饮食记录' });
                      } catch (e) {}
                    }
                  }
                });
              })
          }
          .width('100%')
          .padding(20)
          .backgroundColor(Color.White)
          .borderRadius(16)
          .shadow({ radius: 8, color: 'rgba(0,0,0,0.03)', offsetY: 4 })

          // 卡片 3: 重置全部系统数据
          Column({ space: 12 }) {
            Row({ space: 8 }) {
              Image($r('app.media.ic_lock'))
                .width(22)
                .height(22)
              Text('恢复出厂初始状态')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#F44336')
            }.width('100%')

            Text('⚠️ 警告：彻底清空所有饮食记录、收藏数据并重置个人健康档案为默认配置。建议在操作前先在“本地数据导出”中备份您的 JSON 数据。')
              .fontSize(13)
              .fontColor('#777777')
              .lineHeight(19)

            Button('彻底重置所有本地数据')
              .width('100%')
              .height(44)
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
              .backgroundColor('#F44336')
              .borderRadius(22)
              .onClick(() => {
                AlertDialog.show({
                  title: '⚠️ 最终确认：彻底重置？',
                  message: '此操作将抹除全部本地数据并恢复初始状态，请务必确认是否已做好数据导出！',
                  primaryButton: {
                    value: '取消',
                    action: () => {}
                  },
                  secondaryButton: {
                    value: '彻底抹除重置',
                    fontColor: '#F44336',
                    action: async () => {
                      await FoodDBHelper.deleteAccount();
                      try {
                        promptAction.showToast({ message: '系统数据已全部重置为初始状态' });
                      } catch (e) {}
                      try {
                        router.replaceUrl({ url: 'pages/LoginPage' });
                      } catch (e) {}
                    }
                  }
                });
              })
          }
          .width('100%')
          .padding(20)
          .backgroundColor(Color.White)
          .borderRadius(16)
          .shadow({ radius: 8, color: 'rgba(0,0,0,0.03)', offsetY: 4 })
          .margin({ bottom: 24 })
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
