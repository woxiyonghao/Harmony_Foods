import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { AppTheme } from '../../common/constants/AppTheme';
import { FoodDBHelper } from '../../common/utils/FoodDBHelper';
import { UserProfile } from '../../common/models/FoodItem';

@Component
export struct ProfileView {
  @Prop @Watch('onActiveTabChange') activeTab: number = 0;
  @Prop @Watch('onRefresh') refreshTrigger: number = 0;
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
    await this.loadProfile();
  }

  onActiveTabChange() {
    if (this.activeTab === 4) {
      this.loadProfile();
    }
  }

  onRefresh() {
    this.loadProfile();
  }

  async loadProfile() {
    this.profile = await FoodDBHelper.getUserProfile();
  }

  openEditProfilePage() {
    try {
      router.pushUrl({ url: 'pages/EditProfilePage' });
    } catch (err) {}
  }

  openBodyDataPage() {
    try {
      router.pushUrl({ url: 'pages/BodyDataPage' });
    } catch (err) {}
  }

  openHealthGoalPage() {
    try {
      router.pushUrl({ url: 'pages/HealthGoalPage' });
    } catch (err) {}
  }

  openDiseaseTagsPage() {
    try {
      router.pushUrl({ url: 'pages/DiseaseTagsPage' });
    } catch (err) {}
  }

  openScoreWeightPage() {
    try {
      router.pushUrl({ url: 'pages/ScoreWeightPage' });
    } catch (err) {}
  }

  openExportDataPage() {
    try {
      router.pushUrl({ url: 'pages/ExportDataPage' });
    } catch (err) {}
  }

  openDataManagePage() {
    try {
      router.pushUrl({ url: 'pages/DataManagePage' });
    } catch (err) {}
  }

  openAboutPage() {
    try {
      router.pushUrl({ url: 'pages/AboutPage' });
    } catch (err) {}
  }

  handleLogout() {
    AlertDialog.show({
      title: '退出登录确认',
      message: '确定要退出当前账号吗？退出登录不会删除您的本地历史饮食数据与健康档案。',
      primaryButton: {
        value: '取消',
        action: () => {}
      },
      secondaryButton: {
        value: '确认退出',
        fontColor: '#FF9800',
        action: () => {
          try {
            promptAction.showToast({ message: '已退出登录' });
            router.replaceUrl({ url: 'pages/LoginPage' });
          } catch (e) {}
        }
      }
    });
  }

  handleDeleteAccount() {
    AlertDialog.show({
      title: '⚠️ 注销用户确认',
      message: '注销将永久删除您的所有本地饮食记录、收藏数据以及健康档案，且无法找回！确定继续吗？',
      primaryButton: {
        value: '取消',
        action: () => {}
      },
      secondaryButton: {
        value: '确定注销',
        fontColor: '#F44336',
        action: async () => {
          await FoodDBHelper.deleteAccount();
          try {
            promptAction.showToast({ message: '用户已注销，本地数据已清空' });
            router.replaceUrl({ url: 'pages/LoginPage' });
          } catch (e) {}
        }
      }
    });
  }

  build() {
    Column() {
      Scroll() {
        Column({ space: 16 }) {
          this.HeaderSection()
          this.HealthProfileCard()
          this.SettingsCard()
          this.DataManagementCard()
          this.SystemAndAccountCard()
          Blank().height(30)
        }
        .padding({ left: 16, right: 16, top: 20, bottom: 20 })
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F7F8FA')
  }

  @Builder
  HeaderSection() {
    Row({ space: 16 }) {
      Stack() {
        Circle({ width: 64, height: 64 }).fill('#EAEAEA')
        Text(this.profile.avatar).fontSize(36)
      }

      Column({ space: 4 }) {
        Text(this.profile.nickname).fontSize(20).fontWeight(FontWeight.Bold).fontColor('#333333')
        Text(`ID: ${this.profile.id}`)
          .fontSize(12).fontColor('#999999')

        Row({ space: 4 }) {
          Circle({ width: 8, height: 8 }).fill(AppTheme.PRIMARY_COLOR)
          Text('健康状态: 良好').fontSize(12).fontColor(AppTheme.PRIMARY_COLOR)
        }
        .padding({ left: 8, right: 8, top: 4, bottom: 4 })
        .backgroundColor('#E8F5E9')
        .borderRadius(12)
        .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Button('编辑')
        .type(ButtonType.Normal)
        .fontSize(14)
        .fontColor('#666666')
        .backgroundColor('transparent')
        .onClick(() => {
          this.openEditProfilePage();
        })
    }
    .width('100%')
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .shadow({ radius: 8, color: 'rgba(0,0,0,0.03)', offsetY: 4 })
    .onClick(() => {
      this.openEditProfilePage();
    })
  }

  @Builder
  HealthProfileCard() {
    Column() {
      Row() {
        Text('健康档案').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#333333')
      }.width('100%').padding({ left: 16, top: 16, bottom: 8 })

      this.MenuRow($r('app.media.ic_body'), '基础身体数据', `${this.profile.height}cm / ${this.profile.weight}kg`, () => {
        this.openBodyDataPage();
      })
      Divider().color('#F0F0F0').strokeWidth(1).margin({ left: 50, right: 16 })
      this.MenuRow($r('app.media.ic_target'), '健康目标', this.profile.targetGoal, () => {
        this.openHealthGoalPage();
      })
      Divider().color('#F0F0F0').strokeWidth(1).margin({ left: 50, right: 16 })
      this.MenuRow($r('app.media.ic_tag'), '特殊疾病标签', this.profile.diseaseTags || '无特殊疾病', () => {
        this.openDiseaseTagsPage();
      })
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(16)
    .shadow({ radius: 8, color: 'rgba(0,0,0,0.03)', offsetY: 4 })
  }

  @Builder
  SettingsCard() {
    Column() {
      Row() {
        Text('核心设置').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#333333')
      }.width('100%').padding({ left: 16, top: 16, bottom: 8 })

      this.MenuRow($r('app.media.ic_slider'), '评分维度权重自定义', this.profile.scoreWeight, () => {
        this.openScoreWeightPage();
      })
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(16)
    .shadow({ radius: 8, color: 'rgba(0,0,0,0.03)', offsetY: 4 })
  }

  @Builder
  DataManagementCard() {
    Column() {
      Row() {
        Text('数据安全与管理').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#333333')
      }.width('100%').padding({ left: 16, top: 16, bottom: 8 })

      this.MenuRow($r('app.media.ic_backup'), '本地数据导出 (JSON/CSV)', `上次备份: ${this.profile.lastBackupTime}`, () => {
        this.openExportDataPage();
      })
      Divider().color('#F0F0F0').strokeWidth(1).margin({ left: 50, right: 16 })
      this.MenuRow($r('app.media.ic_restore'), '恢复与重置数据', '', () => {
        this.openDataManagePage();
      })
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(16)
    .shadow({ radius: 8, color: 'rgba(0,0,0,0.03)', offsetY: 4 })
  }

  @Builder
  SystemAndAccountCard() {
    Column() {
      Row() {
        Text('系统与账号').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#333333')
      }.width('100%').padding({ left: 16, top: 16, bottom: 8 })

      this.MenuRow($r('app.media.ic_target'), '关于食养智评', 'v1.2.0 >', () => {
        this.openAboutPage();
      })
      Divider().color('#F0F0F0').strokeWidth(1).margin({ left: 50, right: 16 })
      this.MenuRow($r('app.media.ic_record'), '退出登录', '保留数据 >', () => {
        this.handleLogout();
      })
      Divider().color('#F0F0F0').strokeWidth(1).margin({ left: 50, right: 16 })
      this.MenuRow($r('app.media.ic_trash'), '注销用户', '清除全部数据 >', () => {
        this.handleDeleteAccount();
      })
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(16)
    .shadow({ radius: 8, color: 'rgba(0,0,0,0.03)', offsetY: 4 })
  }

  @Builder
  MenuRow(icon: Resource, title: string, value: string, onClickAction: () => void) {
    Row() {
      Image(icon).width(20).height(20).fillColor('#666666').margin({ right: 12 })
      Text(title).fontSize(15).fontColor('#333333')
      Blank()
      Text(value).fontSize(13).fontColor('#999999').margin({ right: 8 })
      Text('>').fontSize(16).fontColor('#CCCCCC')
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 16, bottom: 16 })
    .alignItems(VerticalAlign.Center)
    .onClick(onClickAction)
  }
}
