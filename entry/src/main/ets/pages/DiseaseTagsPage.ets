import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { AppTheme } from '../common/constants/AppTheme';
import { UserProfile } from '../common/models/FoodItem';
import { FoodDBHelper } from '../common/utils/FoodDBHelper';

@Entry
@Component
struct DiseaseTagsPage {
  @State selectedTags: string[] = ['高尿酸 / 痛风', '轻度脂肪肝'];
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

  private options: string[] = [
    '高尿酸 / 痛风',
    '高血压',
    '高血脂',
    '轻度脂肪肝',
    '糖尿病',
    '乳糖不耐受',
    '无特殊疾病'
  ];

  async aboutToAppear() {
    let context = getContext(this);
    await FoodDBHelper.init(context);
    this.profile = await FoodDBHelper.getUserProfile();
    if (this.profile.diseaseTags) {
      this.selectedTags = this.profile.diseaseTags.split(' / ').filter((t: string) => t.trim() !== '');
    }
  }

  toggleTag(tag: string) {
    if (tag === '无特殊疾病') {
      this.selectedTags = ['无特殊疾病'];
      return;
    }

    let noSpecIdx = this.selectedTags.indexOf('无特殊疾病');
    if (noSpecIdx !== -1) {
      this.selectedTags.splice(noSpecIdx, 1);
    }

    let idx = this.selectedTags.indexOf(tag);
    if (idx !== -1) {
      this.selectedTags.splice(idx, 1);
    } else {
      this.selectedTags.push(tag);
    }
  }

  async handleSave() {
    let res = this.selectedTags.length > 0 ? this.selectedTags.join(' / ') : '无特殊疾病';
    this.profile.diseaseTags = res;
    await FoodDBHelper.saveUserProfile(this.profile);

    try {
      promptAction.showToast({ message: '疾病与关注标签已保存' });
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
