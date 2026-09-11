import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { AppTheme } from '../common/constants/AppTheme';
import { UserProfile } from '../common/models/FoodItem';
import { FoodDBHelper } from '../common/utils/FoodDBHelper';

@Entry
@Component
struct DiseaseTagsPage {
  @State selectedTags: string[] = ['无特殊关注'];
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

  private options: string[] = [
    '高尿酸/痛风关注',
    '高血压/控盐关注',
    '高血脂/脂肪肝关注',
    '控糖/糖尿病关注',
    '低乳糖关注',
    '无特殊关注'
  ];

  async aboutToAppear() {
    let context = getContext(this);
    await FoodDBHelper.init(context);
    this.profile = await FoodDBHelper.getUserProfile();
    if (this.profile.diseaseTags && this.profile.diseaseTags.trim() !== '') {
      let raw = this.profile.diseaseTags;
      let parts = raw.split(/[\/、,]+/).map((t: string) => t.trim()).filter((t: string) => t.length > 0);
      let matched: string[] = [];
      for (let p of parts) {
        for (let opt of this.options) {
          if (opt.includes(p) || p.includes(opt.replace('关注', '')) || opt === p) {
            if (!matched.includes(opt)) matched.push(opt);
          }
        }
      }
      this.selectedTags = matched.length > 0 ? matched : ['无特殊关注'];
    } else {
      this.selectedTags = ['无特殊关注'];
    }
  }

  toggleTag(tag: string) {
    if (tag === '无特殊关注') {
      this.selectedTags = ['无特殊关注'];
      return;
    }

    let list = this.selectedTags.filter((t: string) => t !== '无特殊关注');
    let idx = list.indexOf(tag);
    if (idx >= 0) {
      list.splice(idx, 1);
    } else {
      list.push(tag);
    }

    if (list.length === 0) {
      list = ['无特殊关注'];
    }
    this.selectedTags = [...list];
  }

  async saveDirectly(): Promise<boolean> {
    let res = this.selectedTags.length > 0 ? this.selectedTags.join('、') : '无特殊关注';
    let updatedProfile: UserProfile = {
      id: this.profile.id,
      nickname: this.profile.nickname,
      avatar: this.profile.avatar,
      height: this.profile.height,
      weight: this.profile.weight,
      targetGoal: this.profile.targetGoal,
      targetEnergy: this.profile.targetEnergy,
      diseaseTags: res,
      scoreWeight: this.profile.scoreWeight,
      lastBackupTime: this.profile.lastBackupTime
    };
    return await FoodDBHelper.saveUserProfile(updatedProfile);
  }

  async handleSave() {
    let saved = await this.saveDirectly();
    if (!saved) {
      promptAction.showToast({ message: '保存失败，请稍后重试' });
      return;
    }

    try {
      promptAction.showToast({ message: '膳食关注标签已保存' });
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

        Text('个性化膳食关注标签')
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
          // 标签选择卡片
          Column({ space: 14 }) {
            Text('关注标签多选')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
              .width('100%')

            Text('系统将根据您的偏好在首页与分析中智能调整重点营养素摄入建议')
              .fontSize(12)
              .fontColor('#888888')
              .width('100%')

            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.options, (opt: string) => {
                Text(opt)
                  .fontSize(14)
                  .fontColor(this.selectedTags.indexOf(opt) !== -1 ? AppTheme.PRIMARY_COLOR : '#555555')
                  .backgroundColor(this.selectedTags.indexOf(opt) !== -1 ? '#E8F5E9' : '#F5F5F5')
                  .padding({ left: 16, right: 16, top: 10, bottom: 10 })
                  .borderRadius(20)
                  .margin({ right: 10, bottom: 12 })
                  .border({
                    width: 1.5,
                    color: this.selectedTags.indexOf(opt) !== -1 ? AppTheme.PRIMARY_COLOR : '#EAEAEA'
                  })
                  .onClick(() => {
                    this.toggleTag(opt);
                  })
              })
            }
            .width('100%')
            .margin({ top: 6 })
          }
          .width('100%')
          .padding(20)
          .backgroundColor(Color.White)
          .borderRadius(16)
          .shadow({ radius: 8, color: 'rgba(0,0,0,0.03)', offsetY: 4 })

          // 营养参考说明卡片
          Column({ space: 14 }) {
            Text('重点营养素参考值说明 (基于膳食指南)')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
              .width('100%')

            // 指标 1: 嘌呤
            Row() {
              Column({ space: 4 }) {
                Row({ space: 6 }) {
                  Text('嘌呤 (mg)').fontSize(14).fontWeight(FontWeight.Bold).fontColor('#333333')
                  Text('关注：控酸饮食人群').fontSize(11).fontColor(AppTheme.PRIMARY_COLOR)
                }
                Text('建议日常参考上限 ≤ 200mg，少饮浓肉汤，避免过多高嘌呤海鲜与动物内脏').fontSize(12).fontColor('#777777')
              }.layoutWeight(1).alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .padding(12)
            .backgroundColor('#F7F8FA')
            .borderRadius(10)

            // 指标 2: 钠盐
            Row() {
              Column({ space: 4 }) {
                Row({ space: 6 }) {
                  Text('钠盐 (mg)').fontSize(14).fontWeight(FontWeight.Bold).fontColor('#333333')
                  Text('关注：低盐清淡饮食').fontSize(11).fontColor(AppTheme.PRIMARY_COLOR)
                }
                Text('建议日常参考上限 ≤ 1500mg，减少高盐加工酱料，多摄入高钾新鲜蔬果').fontSize(12).fontColor('#777777')
              }.layoutWeight(1).alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .padding(12)
            .backgroundColor('#F7F8FA')
            .borderRadius(10)

            // 指标 3: 胆固醇
            Row() {
              Column({ space: 4 }) {
                Row({ space: 6 }) {
                  Text('胆固醇 (mg)').fontSize(14).fontWeight(FontWeight.Bold).fontColor('#333333')
                  Text('关注：轻脂少油饮食').fontSize(11).fontColor(AppTheme.PRIMARY_COLOR)
                }
                Text('建议日常参考上限 ≤ 200mg，适度控制动物油脂与油炸食品，补充优质膳食纤维').fontSize(12).fontColor('#777777')
              }.layoutWeight(1).alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .padding(12)
            .backgroundColor('#F7F8FA')
            .borderRadius(10)

            // 免责提示条
            Text('💡 提示：以上营养素参考阈值来源于公开营养学健康科普资料，仅供日常饮食搭配参考，不具有医疗诊断意义，慢病人群请遵医嘱。')
              .fontSize(11)
              .fontColor('#999999')
              .lineHeight(16)
              .margin({ top: 4 })
          }
          .width('100%')
          .padding(20)
          .backgroundColor(Color.White)
          .borderRadius(16)
          .shadow({ radius: 8, color: 'rgba(0,0,0,0.03)', offsetY: 4 })

          // 底部保存按钮
          Button('保存标签设置')
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
