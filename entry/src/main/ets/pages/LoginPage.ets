import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { AppTheme } from '../common/constants/AppTheme';
import { UserAccount } from '../common/models/FoodItem';
import { FoodDBHelper } from '../common/utils/FoodDBHelper';

@Entry
@Component
struct LoginPage {
  @State isRegisterMode: boolean = false;
  @State accountInput: string = '10000';
  @State passwordInput: string = '123456';
  @State nicknameInput: string = '健康探索者';
  @State selectedAvatar: string = '🍎';
  @State agreedPolicy: boolean = true;

  private avatars: string[] = ['🍎', '😊', '🏃', '🥗', '🥑', '🚴', '🧘', '💪'];

  async aboutToAppear() {
    let context = getContext(this);
    await FoodDBHelper.init(context);
  }

  async handleLogin() {
    if (!this.agreedPolicy) {
      try {
        promptAction.showToast({ message: '请先阅读并同意隐私政策与用户协议' });
      } catch (e) {}
      return;
    }

    if (this.accountInput.trim() === '') {
      try {
        promptAction.showToast({ message: '请输入登录账号或用户ID' });
      } catch (e) {}
      return;
    }

    let user = await FoodDBHelper.loginUser(this.accountInput.trim(), this.passwordInput.trim());
    if (user) {
      try {
        promptAction.showToast({ message: `欢迎回来，${user.nickname} (ID: ${user.userId})` });
      } catch (e) {}
      try {
        router.replaceUrl({ url: 'pages/Index' });
      } catch (e) {}
    } else {
      try {
        promptAction.showToast({ message: '账号或密码不正确，请重试' });
      } catch (e) {}
    }
  }

  async handleRegister() {
    if (!this.agreedPolicy) {
      try {
        promptAction.showToast({ message: '请先阅读并同意隐私政策与用户协议' });
      } catch (e) {}
      return;
    }

    if (this.accountInput.trim() === '' || this.passwordInput.trim() === '') {
      try {
        promptAction.showToast({ message: '账号与密码不能为空' });
      } catch (e) {}
      return;
    }

    let user = await FoodDBHelper.registerUser(
      this.accountInput.trim(),
      this.passwordInput.trim(),
      this.nicknameInput.trim(),
      this.selectedAvatar
    );

    if (user) {
      try {
        promptAction.showToast({ message: `注册成功！分配到专属健康 ID: ${user.userId}` });
      } catch (e) {}
      try {
        router.replaceUrl({ url: 'pages/Index' });
      } catch (e) {}
    } else {
      try {
        promptAction.showToast({ message: '账号已存在，请直接登录或更换账号名' });
      } catch (e) {}
    }
  }

  async handleQuickLogin() {
    this.accountInput = '10000';
    this.passwordInput = '123456';
    let user = await FoodDBHelper.loginUser('10000', '123456');
    if (user) {
      try {
        promptAction.showToast({ message: '已使用默认用户 (ID: 10000) 快速登录' });
      } catch (e) {}
      try {
        router.replaceUrl({ url: 'pages/Index' });
      } catch (e) {}
    }
  }

  build() {
    Column() {
      Scroll() {
        Column({ space: 20 }) {
          // 顶部 Logo 与应用名称
          Column({ space: 8 }) {
            Stack() {
              Circle({ width: 84, height: 84 }).fill('#E8F5E9')
              Text('🥗').fontSize(48)
            }

            Text('食养智评')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')

            Text('Harmony Foods · 离线优先营养管理')
              .fontSize(13)
              .fontColor(AppTheme.PRIMARY_COLOR)
              .fontWeight(FontWeight.Medium)
          }
          .width('100%')
          .padding({ top: 40, bottom: 10 })
          .alignItems(HorizontalAlign.Center)

          // 模式切换卡片 (登录 / 注册)
          Row() {
            Button('账号登录')
              .layoutWeight(1)
              .height(40)
              .fontSize(14)
              .fontWeight(this.isRegisterMode ? FontWeight.Normal : FontWeight.Bold)
              .fontColor(this.isRegisterMode ? '#666666' : AppTheme.PRIMARY_COLOR)
              .backgroundColor(this.isRegisterMode ? 'transparent' : Color.White)
              .borderRadius(20)
              .onClick(() => {
                this.isRegisterMode = false;
                this.accountInput = '10000';
                this.passwordInput = '123456';
              })

            Button('快速注册')
              .layoutWeight(1)
              .height(40)
              .fontSize(14)
              .fontWeight(this.isRegisterMode ? FontWeight.Bold : FontWeight.Normal)
              .fontColor(this.isRegisterMode ? AppTheme.PRIMARY_COLOR : '#666666')
              .backgroundColor(this.isRegisterMode ? Color.White : 'transparent')
              .borderRadius(20)
              .onClick(() => {
                this.isRegisterMode = true;
                this.accountInput = '';
                this.passwordInput = '';
              })
          }
          .width('100%')
          .padding(4)
          .backgroundColor('#EBEBEB')
          .borderRadius(24)

          // 表单卡片
          Column({ space: 14 }) {
            // 账号输入行
            Column({ space: 6 }) {
              Text(this.isRegisterMode ? '注册账号 / 手机号' : '用户账号 / ID')
                .fontSize(13)
                .fontColor('#666666')
                .width('100%')

              TextInput({ text: this.accountInput, placeholder: this.isRegisterMode ? '请输入用于注册的账号' : '例如 10000' })
                .height(48)
                .fontSize(15)
                .backgroundColor('#F7F8FA')
                .borderRadius(12)
                .padding({ left: 14, right: 14 })
                .onChange((val: string) => {
                  this.accountInput = val;
                })
            }
            .width('100%')

            // 密码输入行
            Column({ space: 6 }) {
              Text('登录密码')
                .fontSize(13)
                .fontColor('#666666')
                .width('100%')

              TextInput({ text: this.passwordInput, placeholder: '请输入密码 (默认 123456)' })
                .type(InputType.Password)
                .height(48)
                .fontSize(15)
                .backgroundColor('#F7F8FA')
                .borderRadius(12)
                .padding({ left: 14, right: 14 })
                .onChange((val: string) => {
                  this.passwordInput = val;
                })
            }
            .width('100%')

            // 注册模式特有字段：昵称与头像选择
            if (this.isRegisterMode) {
              Column({ space: 6 }) {
                Text('个性昵称')
                  .fontSize(13)
                  .fontColor('#666666')
                  .width('100%')

                TextInput({ text: this.nicknameInput, placeholder: '例如 健康新星' })
                  .height(48)
                  .fontSize(15)
                  .backgroundColor('#F7F8FA')
                  .borderRadius(12)
                  .padding({ left: 14, right: 14 })
                  .onChange((val: string) => {
                    this.nicknameInput = val;
                  })
              }
              .width('100%')

              Column({ space: 8 }) {
                Text('选择专属初始形象')
                  .fontSize(13)
                  .fontColor('#666666')
                  .width('100%')

                Row({ space: 6 }) {
                  ForEach(this.avatars, (av: string) => {
                    Text(av)
                      .fontSize(24)
                      .padding(6)
                      .borderRadius(12)
                      .backgroundColor(this.selectedAvatar === av ? '#E8F5E9' : '#F5F5F5')
                      .border({
                        width: 1.5,
                        color: this.selectedAvatar === av ? AppTheme.PRIMARY_COLOR : 'transparent'
                      })
                      .onClick(() => {
                        this.selectedAvatar = av;
                      })
                  })
                }.width('100%').justifyContent(FlexAlign.SpaceBetween)

                Text('💡 提示：新用户注册将自动获得从 10000 起自增分配的专属健康 ID。')
                  .fontSize(11)
                  .fontColor('#999999')
                  .margin({ top: 4 })
              }
              .width('100%')
            }

            // 隐私政策勾选条
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
            .margin({ top: 8, bottom: 4 })
            .alignItems(VerticalAlign.Center)

            // 主提交按钮
            Button(this.isRegisterMode ? '立即注册并登录' : '登 录')
              .width('100%')
              .height(48)
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
              .backgroundColor(AppTheme.PRIMARY_COLOR)
              .borderRadius(24)
              .shadow({ radius: 8, color: 'rgba(46, 139, 87, 0.3)', offsetY: 4 })
              .onClick(() => {
                if (this.isRegisterMode) {
                  this.handleRegister();
                } else {
                  this.handleLogin();
                }
              })

            // 快捷免密体验入口
            if (!this.isRegisterMode) {
              Button('一键体验登录 (ID: 10000)')
                .width('100%')
                .height(44)
                .fontSize(14)
                .fontColor(AppTheme.PRIMARY_COLOR)
                .backgroundColor('#E8F5E9')
                .borderRadius(22)
                .margin({ top: 8 })
                .onClick(() => {
                  this.handleQuickLogin();
                })
            }
          }
          .width('100%')
          .padding(20)
          .backgroundColor(Color.White)
          .borderRadius(16)
          .shadow({ radius: 8, color: 'rgba(0,0,0,0.03)', offsetY: 4 })

          // 底部提示
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
