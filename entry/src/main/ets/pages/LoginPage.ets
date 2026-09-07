import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { AppTheme } from '../common/constants/AppTheme';
import { FoodDBHelper } from '../common/utils/FoodDBHelper';

@Entry
@Component
struct LoginPage {
  @State nameInput: string = '';
  @State passwordInput: string = '';
  @State agreedPolicy: boolean = false;
  @State isPasswordVisible: boolean = false;

  async aboutToAppear() {
    let context = getContext(this);
    await FoodDBHelper.init(context);
  }

  async handleLogin() {
    let cleanName = this.nameInput.trim();
    let cleanPass = this.passwordInput.trim();

    if (cleanName === '') {
      try {
        promptAction.showToast({ message: '请输入名字' });
      } catch (e) {}
      return;
    }

    if (cleanPass === '') {
      try {
        promptAction.showToast({ message: '请输入密码' });
      } catch (e) {}
      return;
    }

    if (!this.agreedPolicy) {
      try {
        promptAction.showToast({ message: '请先阅读并同意隐私政策与声明' });
      } catch (e) {}
      return;
    }

    let result = await FoodDBHelper.loginByName(cleanName, cleanPass);
    if (result.success && result.user) {
      try {
        if (result.isNew) {
          promptAction.showToast({ message: `欢迎您，${result.user.nickname}！已分配专属 ID: ${result.user.userId}` });
        } else {
          promptAction.showToast({ message: `欢迎回来，${result.user.nickname} (ID: ${result.user.userId})` });
        }
      } catch (e) {}
      try {
        router.replaceUrl({ url: 'pages/Index' });
      } catch (e) {}
    } else {
      try {
        promptAction.showToast({ message: result.message || '登录失败，请检查密码' });
      } catch (e) {}
    }
  }

  build() {
    Column() {
      Scroll() {
        Column({ space: 24 }) {
          // 顶部 Logo 与应用标题
          Column({ space: 8 }) {
            Image($r('app.media.app_icon'))
              .width(84)
              .height(84)

            Text('膳管家')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')

            Text('科学膳食 · 离线健康管理')
              .fontSize(13)
              .fontColor(AppTheme.PRIMARY_COLOR)
              .fontWeight(FontWeight.Medium)
          }
          .width('100%')
          .padding({ top: 48, bottom: 12 })
          .alignItems(HorizontalAlign.Center)

          // 登录表单卡片
          Column({ space: 18 }) {
            // 名字输入项 (只允许输入名字，不允许输入 ID)
            Column({ space: 6 }) {
              Text('名字')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#444444')
                .width('100%')

              TextInput({ text: this.nameInput, placeholder: '请输入名字' })
                .height(48)
                .fontSize(15)
                .backgroundColor('#F7F8FA')
                .borderRadius(12)
                .padding({ left: 14, right: 14 })
                .onChange((val: string) => {
                  this.nameInput = val;
                })
            }
            .width('100%')

            // 登录密码输入项
            Column({ space: 6 }) {
              Text('登录密码')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#444444')
                .width('100%')

              Row() {
                TextInput({
                  text: this.passwordInput,
                  placeholder: '请输入密码'
                })
                  .type(this.isPasswordVisible ? InputType.Normal : InputType.Password)
                  .height(48)
                  .fontSize(15)
                  .layoutWeight(1)
                  .backgroundColor('#F7F8FA')
                  .borderRadius(12)
                  .padding({ left: 14, right: 14 })
                  .onChange((val: string) => {
                    this.passwordInput = val;
                  })

                Text(this.isPasswordVisible ? '🙈' : '👁️')
                  .fontSize(18)
                  .padding({ left: 10, right: 12, top: 12, bottom: 12 })
                  .onClick(() => {
                    this.isPasswordVisible = !this.isPasswordVisible;
                  })
              }
              .width('100%')
              .backgroundColor('#F7F8FA')
              .borderRadius(12)
            }
            .width('100%')

            // 隐私政策勾选行
            Row({ space: 6 }) {
              Toggle({ type: ToggleType.Checkbox, isOn: this.agreedPolicy })
                .selectedColor(AppTheme.PRIMARY_COLOR)
                .onChange((isOn: boolean) => {
                  this.agreedPolicy = isOn;
                })

              Text('我已阅读并同意')
                .fontSize(12)
                .fontColor('#666666')

              Text('《隐私政策与声明》')
                .fontSize(12)
                .fontWeight(FontWeight.Medium)
                .fontColor(AppTheme.PRIMARY_COLOR)
                .onClick(() => {
                  try {
                    router.pushUrl({
                      url: 'pages/PrivacyPolicyPage'
                    });
                  } catch (e) {}
                })
            }
            .width('100%')
            .margin({ top: 4, bottom: 4 })
            .alignItems(VerticalAlign.Center)

            // 登录按钮
            Button('登 录')
              .width('100%')
              .height(48)
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
              .backgroundColor(AppTheme.PRIMARY_COLOR)
              .borderRadius(24)
              .shadow({ radius: 8, color: 'rgba(46, 139, 87, 0.3)', offsetY: 4 })
              .onClick(() => {
                this.handleLogin();
              })

            // 游客免登录体验
            Button('暂不登录，以游客身份体验')
              .width('100%')
              .height(44)
              .fontSize(14)
              .fontColor('#666666')
              .backgroundColor('#F0F2F5')
              .borderRadius(22)
              .onClick(() => {
                try {
                  promptAction.showToast({ message: '已进入离线体验模式' });
                  router.replaceUrl({ url: 'pages/Index' });
                } catch (e) {}
              })
          }
          .width('100%')
          .padding(24)
          .backgroundColor(Color.White)
          .borderRadius(16)
          .shadow({ radius: 8, color: 'rgba(0,0,0,0.03)', offsetY: 4 })

          // 底部说明
          Text('端侧安全运行 · 100% 离线数据存储')
            .fontSize(11)
            .fontColor('#AAAAAA')
            .margin({ top: 12, bottom: 32 })
        }
        .padding({ left: 20, right: 20 })
      }
      .layoutWeight(1)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F7F8FA')
  }
}
