import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { AppTheme } from '../common/constants/AppTheme';
import { UserProfile } from '../common/models/FoodItem';
import { FoodDBHelper } from '../common/utils/FoodDBHelper';

@Entry
@Component
struct EditProfilePage {
  @State nickname: string = '健康探索者';
  @State selectedAvatar: string = '😊';
  @State profile: UserProfile = {
    id: 'default_user',
    nickname: '健康探索者',
    avatar: '😊',
    height: 175,
    weight: 70,
    targetGoal: '减重 5kg',
    targetEnergy: 2100,
    diseaseTags: '高尿酸 / 轻度脂肪肝',
    scoreWeight: '已调高风险指标',
    lastBackupTime: '昨天'
  };

  private avatarOptions: string[] = [
    '😊', '🏃', '🥗', '🧘',
    '🥑', '🚴', '🍎', '💪',
    '🏊', '🥦', '🍊', '🎯',
    '🌿', '🍇', '🍲', '🧘‍♀️'
  ];

  async aboutToAppear() {
    let context = getContext(this);
    await FoodDBHelper.init(context);
    this.profile = await FoodDBHelper.getUserProfile();
    this.nickname = this.profile.nickname;
    this.selectedAvatar = this.profile.avatar;
  }

  async handleSave() {
    let cleanNick = this.nickname.trim();
    if (cleanNick === '') {
      try {
        promptAction.showToast({ message: '昵称不能为空' });
      } catch (e) {}
      return;
    }

    this.profile.nickname = cleanNick;
    this.profile.avatar = this.selectedAvatar;
    await FoodDBHelper.saveUserProfile(this.profile);

    try {
      promptAction.showToast({ message: '个人资料保存成功' });
    } catch (e) {}

    try {
      router.back();
    } catch (e) {}
  }

  build() {
    Column() {
      // 1. 顶部自定义导航栏
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

        Text('编辑个人资料')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Text('保存')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor(AppTheme.PRIMARY_COLOR)
          .padding({ left: 12, right: 14, top: 8, bottom: 8 })
          .onClick(() => {
            this.handleSave();
          })
      }
      .width('100%')
      .height(56)
      .backgroundColor(Color.White)
      .padding({ left: 4, right: 4 })
      .shadow({ radius: 4, color: 'rgba(0,0,0,0.02)', offsetY: 2 })

      // 2. 页面主体内容滚动区
      Scroll() {
        Column({ space: 16 }) {
          // 当前头像预览 Hero 卡片
          Column({ space: 10 }) {
            Stack({ alignContent: Alignment.BottomEnd }) {
              Circle({ width: 92, height: 92 })
                .fill('#F3FAF5')
                .border({
                  width: 3,
                  color: AppTheme.PRIMARY_COLOR
                })

              Text(this.selectedAvatar)
                .fontSize(52)
                .margin({ bottom: 8 })

              // 装饰小徽章
              Row() {
                Text('✓')
                  .fontSize(10)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Color.White)
              }
              .width(22)
              .height(22)
              .backgroundColor(AppTheme.PRIMARY_COLOR)
              .borderRadius(11)
              .justifyContent(FlexAlign.Center)
              .border({ width: 2, color: Color.White })
              .margin({ right: 2, bottom: 2 })
            }
            .width(96)
            .height(96)

            Text('当前展示形象')
              .fontSize(12)
              .fontColor('#888888')
          }
          .width('100%')
          .padding({ top: 20, bottom: 16 })
          .alignItems(HorizontalAlign.Center)

          // 头像选择器卡片
          Column({ space: 14 }) {
            Row() {
              Text('选择个性头像')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
              Blank()
              Text('点击选择')
                .fontSize(12)
                .fontColor('#999999')
            }
            .width('100%')

            Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
              ForEach(this.avatarOptions, (av: string) => {
                Row() {
                  Text(av)
                    .fontSize(28)
                }
                .width('22%')
                .height(60)
                .justifyContent(FlexAlign.Center)
                .margin({ bottom: 10 })
                .borderRadius(14)
                .backgroundColor(this.selectedAvatar === av ? '#E8F5E9' : '#F8F9FA')
                .border({
                  width: 2,
                  color: this.selectedAvatar === av ? AppTheme.PRIMARY_COLOR : 'transparent'
                })
                .onClick(() => {
                  this.selectedAvatar = av;
                })
              })
            }
            .width('100%')
          }
          .width('100%')
          .padding(18)
          .backgroundColor(Color.White)
          .borderRadius(16)
          .shadow({ radius: 8, color: 'rgba(0,0,0,0.03)', offsetY: 4 })

          // 昵称输入卡片
          Column({ space: 12 }) {
            Row() {
              Text('用户昵称')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
              Blank()
              Text(`${this.nickname.length}/12`)
                .fontSize(12)
                .fontColor('#999999')
            }
            .width('100%')

            TextInput({ text: this.nickname, placeholder: '请输入您的昵称 (最多12字)' })
              .height(48)
              .fontSize(15)
              .maxLength(12)
              .backgroundColor('#F7F8FA')
              .borderRadius(12)
              .padding({ left: 14, right: 14 })
              .onChange((val: string) => {
                this.nickname = val;
              })

            Text('建议使用简短且具有辨识度的专属健康代号')
              .fontSize(12)
              .fontColor('#999999')
          }
          .width('100%')
          .padding(18)
          .backgroundColor(Color.White)
          .borderRadius(16)
          .shadow({ radius: 8, color: 'rgba(0,0,0,0.03)', offsetY: 4 })

          // 账号与档案信息卡片
          Column({ space: 14 }) {
            Text('账号基本信息')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
              .width('100%')

            Row() {
              Text('用户 ID')
                .fontSize(14)
                .fontColor('#666666')
              Blank()
              Text(this.profile.id)
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
              Text('系统分配')
                .fontSize(11)
                .fontColor('#888888')
                .backgroundColor('#F0F0F0')
                .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                .borderRadius(6)
                .margin({ left: 8 })
            }
            .width('100%')

            Divider().color('#F2F2F2').strokeWidth(1)

            Row() {
              Text('身体数据')
                .fontSize(14)
                .fontColor('#666666')
              Blank()
              Text(`${this.profile.height} cm / ${this.profile.weight} kg`)
                .fontSize(14)
                .fontColor('#555555')
            }
            .width('100%')

            Divider().color('#F2F2F2').strokeWidth(1)

            Row() {
              Text('健康目标')
                .fontSize(14)
                .fontColor('#666666')
              Blank()
              Text(this.profile.targetGoal)
                .fontSize(14)
                .fontColor(AppTheme.PRIMARY_COLOR)
                .fontWeight(FontWeight.Medium)
            }
            .width('100%')

            Text('提示：身体数据、目标热量与慢病标签可在「我的」主页健康档案中微调')
              .fontSize(11)
              .fontColor('#AAAAAA')
              .margin({ top: 4 })
          }
          .width('100%')
          .padding(18)
          .backgroundColor(Color.White)
          .borderRadius(16)
          .shadow({ radius: 8, color: 'rgba(0,0,0,0.03)', offsetY: 4 })

          // 底部保存大按钮
          Button('保存资料')
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
