import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { AppTheme } from '../common/constants/AppTheme';
import { UserProfile } from '../common/models/FoodItem';
import { FoodDBHelper } from '../common/utils/FoodDBHelper';

@Entry
@Component
struct HealthGoalPage {
  @State selectedGoal: string = '维持健康体重';
  @State targetCalories: string = '2100';
  @State profile: UserProfile = {
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

  private goals: string[] = [
    '减重 5kg',
    '维持健康体重',
    '增肌塑形',
    '控制尿酸防痛风',
    '平稳血压控盐',
    '低脂轻体控胆固醇'
  ];

  private caloriePresets: number[] = [1600, 1800, 2000, 2100, 2400];

  async aboutToAppear() {
    let context = getContext(this);
    await FoodDBHelper.init(context);
    this.profile = await FoodDBHelper.getUserProfile();
    this.selectedGoal = this.profile.targetGoal || '维持健康体重';
    this.targetCalories = (this.profile.targetEnergy || 2100).toString();
  }

  selectGoal(goal: string) {
    this.selectedGoal = goal;
    if (goal === '减重 5kg') {
      this.targetCalories = '1800';
    } else if (goal === '维持健康体重') {
      this.targetCalories = '2100';
    } else if (goal === '增肌塑形') {
      this.targetCalories = '2400';
    } else if (goal === '控制尿酸防痛风' || goal === '平稳血压控盐') {
      this.targetCalories = '2000';
    } else if (goal === '低脂轻体控胆固醇') {
      this.targetCalories = '1900';
    }
  }

  async saveDirectly(): Promise<boolean> {
    let cal = parseInt(this.targetCalories) || 2100;
    let updatedProfile: UserProfile = {
      id: this.profile.id,
      nickname: this.profile.nickname,
      avatar: this.profile.avatar,
      height: this.profile.height,
      weight: this.profile.weight,
      targetGoal: this.selectedGoal,
      targetEnergy: cal,
      diseaseTags: this.profile.diseaseTags || '无特殊关注',
      scoreWeight: this.profile.scoreWeight || '均衡健康模式',
      lastBackupTime: this.profile.lastBackupTime || '未备份'
    };
    return await FoodDBHelper.saveUserProfile(updatedProfile);
  }

  async handleSave() {
    let cal = parseInt(this.targetCalories) || 0;
    if (cal < 800 || cal > 5000) {
      try {
        promptAction.showToast({ message: '请输入合理的目标热量 (800-5000 kcal)' });
      } catch (e) {}
      return;
    }

    let saved = await this.saveDirectly();
    if (!saved) {
      promptAction.showToast({ message: '保存失败，请稍后重试' });
      return;
    }

    try {
      promptAction.showToast({ message: '健康目标已保存' });
    } catch (e) {}

    try {
      router.back();
    } catch (e) {}
  }

  onBackPress(): boolean {
    return false;
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

        Text('健康目标与能量定制')
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
          // 当前目标卡片
          Column({ space: 14 }) {
            Text('当前健康核心目标')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
              .width('100%')

            Column({ space: 8 }) {
              ForEach(this.goals, (g: string) => {
                Row() {
                  Text(g)
                    .fontSize(14)
                    .fontWeight(this.selectedGoal === g ? FontWeight.Bold : FontWeight.Normal)
                    .fontColor(this.selectedGoal === g ? AppTheme.PRIMARY_COLOR : '#444444')
                  Blank()
                  if (this.selectedGoal === g) {
                    Text('● 已选')
                      .fontSize(12)
                      .fontColor(AppTheme.PRIMARY_COLOR)
                  }
                }
                .width('100%')
                .padding({ left: 16, right: 16, top: 12, bottom: 12 })
                .borderRadius(12)
                .backgroundColor(this.selectedGoal === g ? '#E8F5E9' : '#F7F8FA')
                .border({
                  width: 1.5,
                  color: this.selectedGoal === g ? AppTheme.PRIMARY_COLOR : 'transparent'
                })
                .onClick(() => {
                  this.selectGoal(g);
                })
              })
            }
          }
          .width('100%')
          .padding(20)
          .backgroundColor(Color.White)
          .borderRadius(16)
          .shadow({ radius: 8, color: 'rgba(0,0,0,0.03)', offsetY: 4 })

          // 每日目标热量卡片
          Column({ space: 14 }) {
            Text('每日推荐目标热量')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
              .width('100%')

            Row({ space: 12 }) {
              TextInput({ text: this.targetCalories, placeholder: '2100' })
                .type(InputType.Number)
                .height(48)
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor('#111827')
                .placeholderColor('#9CA3AF')
                .layoutWeight(1)
                .backgroundColor('#F9FAFB')
                .borderRadius(12)
                .border({ width: 1, color: '#E5E7EB' })
                .caretColor(AppTheme.PRIMARY_COLOR)
                .padding({ left: 16, right: 16 })
                .onChange((val: string) => {
                  this.targetCalories = val;
                })

              Text('千卡 (kcal)')
                .fontSize(14)
                .fontColor('#666666')
            }
            .width('100%')
            .alignItems(VerticalAlign.Center)

            // 快捷预设按钮
            Row({ space: 8 }) {
              ForEach(this.caloriePresets, (c: number) => {
                Text(`${c}`)
                  .fontSize(12)
                  .fontColor(this.targetCalories === c.toString() ? Color.White : '#555555')
                  .backgroundColor(this.targetCalories === c.toString() ? AppTheme.PRIMARY_COLOR : '#F0F0F0')
                  .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                  .borderRadius(14)
                  .onClick(() => {
                    this.targetCalories = c.toString();
                  })
              })
            }
            .width('100%')
            .margin({ top: 4 })
          }
          .width('100%')
          .padding(20)
          .backgroundColor(Color.White)
          .borderRadius(16)
          .shadow({ radius: 8, color: 'rgba(0,0,0,0.03)', offsetY: 4 })

          // 黄金营养供能比指引卡片
          Column({ space: 12 }) {
            Text('宏量营养素黄金平衡结构')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
              .width('100%')

            Row() {
              Column({ space: 4 }) {
                Text('碳水化合物').fontSize(12).fontColor('#666666')
                Text('50% ~ 65%').fontSize(14).fontWeight(FontWeight.Bold).fontColor('#FF9800')
              }.layoutWeight(1).alignItems(HorizontalAlign.Center)

              Column({ space: 4 }) {
                Text('优质蛋白质').fontSize(12).fontColor('#666666')
                Text('15% ~ 20%').fontSize(14).fontWeight(FontWeight.Bold).fontColor('#2196F3')
              }.layoutWeight(1).alignItems(HorizontalAlign.Center)

              Column({ space: 4 }) {
                Text('健康脂肪').fontSize(12).fontColor('#666666')
                Text('20% ~ 30%').fontSize(14).fontWeight(FontWeight.Bold).fontColor('#E91E63')
              }.layoutWeight(1).alignItems(HorizontalAlign.Center)
            }
            .width('100%')
            .padding({ top: 10, bottom: 10 })
            .backgroundColor('#F7F8FA')
            .borderRadius(10)

            Text('🎯 设定目标后，首页能量进度条与分析页三大宏量营养素分析将以此目标为基准，实时为您提供达标反馈。')
              .fontSize(12)
              .fontColor('#888888')
              .lineHeight(18)
          }
          .width('100%')
          .padding(20)
          .backgroundColor(Color.White)
          .borderRadius(16)
          .shadow({ radius: 8, color: 'rgba(0,0,0,0.03)', offsetY: 4 })

          // 底部保存按钮
          Button('保存目标设置')
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
