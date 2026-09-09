import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { AppTheme } from '../common/constants/AppTheme';
import { UserProfile } from '../common/models/FoodItem';
import { FoodDBHelper } from '../common/utils/FoodDBHelper';

@Entry
@Component
struct ScoreWeightPage {
  @State selectedMode: string = '已调高风险指标';
  @State profile: UserProfile = {
    id: '10000',
    nickname: '健康探索者',
    avatar: '🍎',
    height: 175,
    weight: 70,
    targetGoal: '减重 5kg',
    targetEnergy: 2100,
    diseaseTags: '高尿酸 / 轻度脂肪肝',
    scoreWeight: '已调高风险指标',
    lastBackupTime: '昨天'
  };

  private modes: string[] = [
    '均衡健康模式',
    '已调高风险指标',
    '宏量营养优先'
  ];

  async aboutToAppear() {
    let context = getContext(this);
    await FoodDBHelper.init(context);
    this.profile = await FoodDBHelper.getUserProfile();
    this.selectedMode = this.profile.scoreWeight;
  }

  async handleSave() {
    this.profile.scoreWeight = this.selectedMode;
    await FoodDBHelper.saveUserProfile(this.profile);

    try {
      promptAction.showToast({ message: '评分维度权重已更新' });
    } catch (e) {}

    try {
      router.back();
    } catch (e) {}
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

        Text('评分维度权重自定义')
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
          // 模式选择卡片 1: 均衡健康模式
          Column({ space: 10 }) {
            Row() {
              Text('均衡健康模式')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.selectedMode === '均衡健康模式' ? AppTheme.PRIMARY_COLOR : '#333333')
              Blank()
              if (this.selectedMode === '均衡健康模式') {
                Text('● 当前生效').fontSize(12).fontColor(AppTheme.PRIMARY_COLOR).fontWeight(FontWeight.Bold)
              }
            }.width('100%')

            Text('适合大众普通人群，平衡兼顾宏量营养供能比、慢病指标与膳食纤维摄入。').fontSize(12).fontColor('#777777')

            Row({ space: 12 }) {
              Text('宏量供能: 40%').fontSize(11).fontColor('#555555')
              Text('风险指标: 30%').fontSize(11).fontColor('#555555')
              Text('食物结构: 30%').fontSize(11).fontColor('#555555')
            }.width('100%')
          }
          .width('100%')
          .padding(18)
          .backgroundColor(Color.White)
          .borderRadius(16)
          .border({
            width: 2,
            color: this.selectedMode === '均衡健康模式' ? AppTheme.PRIMARY_COLOR : 'transparent'
          })
          .shadow({ radius: 8, color: 'rgba(0,0,0,0.03)', offsetY: 4 })
          .onClick(() => {
            this.selectedMode = '均衡健康模式';
          })

          // 模式选择卡片 2: 已调高风险指标 (推荐痛风/高血压)
          Column({ space: 10 }) {
            Row() {
              Text('已调高风险指标 (推荐)')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.selectedMode === '已调高风险指标' ? AppTheme.PRIMARY_COLOR : '#333333')
              Blank()
              if (this.selectedMode === '已调高风险指标') {
                Text('● 当前生效').fontSize(12).fontColor(AppTheme.PRIMARY_COLOR).fontWeight(FontWeight.Bold)
              }
            }.width('100%')

            Text('痛风、高尿酸、高血压或高血脂人群专属！大幅提高嘌呤、钠与胆固醇超标时的扣分严厉度。').fontSize(12).fontColor('#777777')

            Row({ space: 12 }) {
              Text('宏量供能: 25%').fontSize(11).fontColor('#555555')
              Text('风险指标: 55%').fontSize(11).fontColor(AppTheme.PRIMARY_COLOR).fontWeight(FontWeight.Bold)
              Text('食物结构: 20%').fontSize(11).fontColor('#555555')
            }.width('100%')
          }
          .width('100%')
          .padding(18)
          .backgroundColor(Color.White)
          .borderRadius(16)
          .border({
            width: 2,
            color: this.selectedMode === '已调高风险指标' ? AppTheme.PRIMARY_COLOR : 'transparent'
          })
          .shadow({ radius: 8, color: 'rgba(0,0,0,0.03)', offsetY: 4 })
          .onClick(() => {
            this.selectedMode = '已调高风险指标';
          })

          // 模式选择卡片 3: 宏量营养优先 (健身与控卡)
          Column({ space: 10 }) {
            Row() {
              Text('宏量营养优先 (健身/减脂)')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.selectedMode === '宏量营养优先' ? AppTheme.PRIMARY_COLOR : '#333333')
              Blank()
              if (this.selectedMode === '宏量营养优先') {
                Text('● 当前生效').fontSize(12).fontColor(AppTheme.PRIMARY_COLOR).fontWeight(FontWeight.Bold)
              }
            }.width('100%')

            Text('适合日常减脂控热量、增肌提高蛋白质比例的人群，重点考核三大供能比与总摄入上限。').fontSize(12).fontColor('#777777')

            Row({ space: 12 }) {
              Text('宏量供能: 60%').fontSize(11).fontColor(AppTheme.PRIMARY_COLOR).fontWeight(FontWeight.Bold)
              Text('风险指标: 20%').fontSize(11).fontColor('#555555')
              Text('食物结构: 20%').fontSize(11).fontColor('#555555')
            }.width('100%')
          }
          .width('100%')
          .padding(18)
          .backgroundColor(Color.White)
          .borderRadius(16)
          .border({
            width: 2,
            color: this.selectedMode === '宏量营养优先' ? AppTheme.PRIMARY_COLOR : 'transparent'
          })
          .shadow({ radius: 8, color: 'rgba(0,0,0,0.03)', offsetY: 4 })
          .onClick(() => {
            this.selectedMode = '宏量营养优先';
          })

          // 说明卡片
          Column({ space: 10 }) {
            Text('权重算法生效说明')
              .fontSize(15)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
              .width('100%')

            Text('切换权重倾向后，首页的今日健康综合评分环与分析模块中的周期平均分将即时依照新权重重新加权计算，帮助您更有针对性地审视每日饮食。')
              .fontSize(12)
              .fontColor('#888888')
              .lineHeight(18)
          }
          .width('100%')
          .padding(18)
          .backgroundColor(Color.White)
          .borderRadius(16)
          .shadow({ radius: 8, color: 'rgba(0,0,0,0.03)', offsetY: 4 })

          // 保存按钮
          Button('应用权重设置')
            .width('100%')
            .height(48)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
            .backgroundColor(AppTheme.PRIMARY_COLOR)
            .borderRadius(24)
            .shadow({ radius: 8, color: 'rgba(46, 139, 87, 0.3)', offsetY: 4 })
            .margin({ top: 12, bottom: 32 })
            .onClick(() => {
              this.handleSave();
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
