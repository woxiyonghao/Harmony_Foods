import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { AppTheme } from '../common/constants/AppTheme';
import { UserProfile } from '../common/models/FoodItem';
import { FoodDBHelper } from '../common/utils/FoodDBHelper';

@Entry
@Component
struct BodyDataPage {
  @State heightInput: string = '175';
  @State weightInput: string = '70';
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

  async aboutToAppear() {
    let context = getContext(this);
    await FoodDBHelper.init(context);
    this.profile = await FoodDBHelper.getUserProfile();
    this.heightInput = this.profile.height.toString();
    this.weightInput = this.profile.weight.toString();
  }

  getBmi(): number {
    let h = parseFloat(this.heightInput) || 0;
    let w = parseFloat(this.weightInput) || 0;
    if (h <= 0) return 0;
    let hm = h / 100;
    return Math.round((w / (hm * hm)) * 10) / 10;
  }

  getBmiStatus(): string {
    let bmi = this.getBmi();
    if (bmi === 0) return '未评定';
    if (bmi < 18.5) return '体重偏瘦';
    if (bmi < 24.0) return '体质正常';
    if (bmi < 28.0) return '体重偏重';
    return '中度肥胖';
  }

  getBmiColor(): string {
    let bmi = this.getBmi();
    if (bmi >= 18.5 && bmi < 24.0) return AppTheme.PRIMARY_COLOR;
    if (bmi >= 24.0 && bmi < 28.0) return '#FF9800';
    return '#F44336';
  }

  getStandardWeightRange(): string {
    let h = parseFloat(this.heightInput) || 0;
    if (h <= 0) return '55 ~ 70 kg';
    let hm = h / 100;
    let minW = Math.round(18.5 * hm * hm * 10) / 10;
    let maxW = Math.round(23.9 * hm * hm * 10) / 10;
    return `${minW} ~ ${maxW} kg`;
  }

  async handleSave() {
    let h = parseFloat(this.heightInput) || 0;
    let w = parseFloat(this.weightInput) || 0;
    if (h < 50 || h > 260) {
      try {
        promptAction.showToast({ message: '请输入合理的身高 (50-260cm)' });
      } catch (e) {}
      return;
    }
    if (w < 20 || w > 300) {
      try {
        promptAction.showToast({ message: '请输入合理的体重 (20-300kg)' });
      } catch (e) {}
      return;
    }

    this.profile.height = h;
    this.profile.weight = w;
    await FoodDBHelper.saveUserProfile(this.profile);

    try {
      promptAction.showToast({ message: '身体数据已保存' });
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

        Text('基础身体数据')
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
          // BMI 实时评估 Hero 卡片
          Column({ space: 12 }) {
            Text('体质指数评估 (BMI)')
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .fontColor('#555555')

            Row({ space: 8 }) {
              Text(this.getBmi().toString())
                .fontSize(44)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.getBmiColor())

              Text('kg/m²')
                .fontSize(14)
                .fontColor('#888888')
                .margin({ top: 20 })

              Blank()

              Text(this.getBmiStatus())
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.getBmiColor())
                .backgroundColor('#F5F5F5')
                .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                .borderRadius(14)
            }
            .width('100%')
            .alignItems(VerticalAlign.Center)

            // BMI 标尺指示条
            Row() {
              Row().layoutWeight(18.5).height(6).backgroundColor('#64B5F6').borderRadius({ topLeft: 3, bottomLeft: 3 })
              Row().layoutWeight(5.5).height(6).backgroundColor(AppTheme.PRIMARY_COLOR)
              Row().layoutWeight(4.0).height(6).backgroundColor('#FFB74D')
              Row().layoutWeight(6.0).height(6).backgroundColor('#E57373').borderRadius({ topRight: 3, bottomRight: 3 })
            }
            .width('100%')
            .margin({ top: 4, bottom: 4 })

            Row() {
              Text('偏瘦 <18.5').fontSize(11).fontColor('#888888')
              Blank()
              Text('正常 18.5~23.9').fontSize(11).fontColor(AppTheme.PRIMARY_COLOR)
              Blank()
              Text('超重 24~27.9').fontSize(11).fontColor('#888888')
              Blank()
              Text('肥胖 ≥28').fontSize(11).fontColor('#888888')
            }
            .width('100%')
          }
          .width('100%')
          .padding(20)
          .backgroundColor(Color.White)
          .borderRadius(16)
          .shadow({ radius: 8, color: 'rgba(0,0,0,0.03)', offsetY: 4 })

          // 身高与体重输入卡片
          Column({ space: 16 }) {
            Text('身体测量数值')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
              .width('100%')

            // 身高行
            Column({ space: 6 }) {
              Row() {
                Text('身高 (cm)')
                  .fontSize(14)
                  .fontColor('#555555')
                Blank()
                Text('单位：厘米')
                  .fontSize(12)
                  .fontColor('#AAAAAA')
              }.width('100%')

              TextInput({ text: this.heightInput, placeholder: '例如 175' })
                .type(InputType.Number)
                .height(48)
                .fontSize(16)
                .backgroundColor('#F7F8FA')
                .borderRadius(12)
                .padding({ left: 14, right: 14 })
                .onChange((val: string) => {
                  this.heightInput = val;
                })
            }
            .width('100%')

            Divider().color('#F2F2F2').strokeWidth(1)

            // 体重行
            Column({ space: 6 }) {
              Row() {
                Text('体重 (kg)')
                  .fontSize(14)
                  .fontColor('#555555')
                Blank()
                Text('单位：公斤')
                  .fontSize(12)
                  .fontColor('#AAAAAA')
              }.width('100%')

              TextInput({ text: this.weightInput, placeholder: '例如 70' })
                .type(InputType.Number)
                .height(48)
                .fontSize(16)
                .backgroundColor('#F7F8FA')
                .borderRadius(12)
                .padding({ left: 14, right: 14 })
                .onChange((val: string) => {
                  this.weightInput = val;
                })
            }
            .width('100%')
          }
          .width('100%')
          .padding(20)
          .backgroundColor(Color.White)
          .borderRadius(16)
          .shadow({ radius: 8, color: 'rgba(0,0,0,0.03)', offsetY: 4 })

          // 标准体重与健康指引卡片
          Column({ space: 12 }) {
            Text('标准体重参考与营养建议')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
              .width('100%')

            Row() {
              Text('根据您的身高，标准体重区间建议为：')
                .fontSize(13)
                .fontColor('#666666')
                .layoutWeight(1)

              Text(this.getStandardWeightRange())
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
                .fontColor(AppTheme.PRIMARY_COLOR)
            }
            .width('100%')
            .padding(12)
            .backgroundColor('#E8F5E9')
            .borderRadius(10)

            Text('💡 提示：定期维护更新您的身体数据，能帮助膳管家为您提供更精确的每日推荐能量（基础代谢）与宏量营养素黄金供能比例。')
              .fontSize(12)
              .fontColor('#888888')
              .lineHeight(18)
          }
          .width('100%')
          .padding(20)
          .backgroundColor(Color.White)
          .borderRadius(16)
          .shadow({ radius: 8, color: 'rgba(0,0,0,0.03)', offsetY: 4 })

          // 保存按钮
          Button('保存身体数据')
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
