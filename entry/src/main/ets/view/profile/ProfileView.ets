import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { AppTheme } from '../../common/constants/AppTheme';
import { FoodDBHelper } from '../../common/utils/FoodDBHelper';
import { UserProfile, cloneUserProfile } from '../../common/models/FoodItem';

@Component
export struct ProfileView {
  @Prop @Watch('onActiveTabChange') activeTab: number = 0;
  @Prop @Watch('onRefresh') refreshTrigger: number = 0;
  @StorageLink('profileVersion') @Watch('onProfileVersionChange') profileVersion: number = 0;
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

  @State nickname: string = '健康探索者';
  @State avatar: string = '🍎';
  @State userId: string = '';
  @State userHeight: number = 175;
  @State userWeight: number = 70;
  @State targetGoal: string = '维持健康体重';
  @State diseaseTags: string = '无特殊关注';
  @State scoreWeight: string = '均衡健康模式';
  @State lastBackupTime: string = '未备份';

  private isLoadingProfile: boolean = false;

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

  onProfileVersionChange() {
    this.loadProfile();
  }

  loadProfileSync() {
    let mem = AppStorage.get<UserProfile>('userProfile');
    if (mem) {
      this.profile = cloneUserProfile(mem);
      this.nickname = mem.nickname || '健康探索者';
      this.avatar = mem.avatar || '🍎';
      this.userId = mem.id || '';
      this.userHeight = mem.height || 175;
      this.userWeight = mem.weight || 70;
      this.targetGoal = mem.targetGoal || '维持健康体重';
      this.diseaseTags = mem.diseaseTags || '无特殊关注';
      this.scoreWeight = mem.scoreWeight || '均衡健康模式';
      this.lastBackupTime = mem.lastBackupTime || '未备份';
    }
  }

  async loadProfile() {
    this.loadProfileSync();
    if (this.isLoadingProfile) return;
    this.isLoadingProfile = true;
    try {
      let p = await FoodDBHelper.getUserProfile();
      this.profile = cloneUserProfile(p);
      this.nickname = p.nickname || '健康探索者';
      this.avatar = p.avatar || '🍎';
      this.userId = p.id || '';
      this.userHeight = p.height || 175;
      this.userWeight = p.weight || 70;
      this.targetGoal = p.targetGoal || '维持健康体重';
      this.diseaseTags = p.diseaseTags || '无特殊关注';
      this.scoreWeight = p.scoreWeight || '均衡健康模式';
      this.lastBackupTime = p.lastBackupTime || '未备份';
    } finally {
      this.isLoadingProfile = false;
    }
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
        action: async () => {
          await FoodDBHelper.logout();
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
        Text(this.avatar).fontSize(36)
      }

      Column({ space: 4 }) {
        Text(this.nickname).fontSize(20).fontWeight(FontWeight.Bold).fontColor('#333333')
        Text(this.userId && this.userId !== '' ? `ID: ${this.userId}` : '')
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

      // 1. 基础身体数据 (直接绑定 @State 状态变量，杜绝 @Builder 按值传参无法刷新的缺陷)
      Row() {
        Image($r('app.media.ic_body')).width(20).height(20).margin({ right: 12 })
        Text('基础身体数据').fontSize(15).fontColor('#333333')
        Blank()
        Text(`${this.userHeight}cm / ${this.userWeight}kg`).fontSize(13).fontColor('#999999').margin({ right: 6 })
        Image($r('app.media.ic_arrow_right')).width(16).height(16)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 16 })
      .alignItems(VerticalAlign.Center)
      .onClick(() => {
        this.openBodyDataPage();
      })

      Divider().color('#F0F0F0').strokeWidth(1).margin({ left: 50, right: 16 })

      // 2. 健康目标
      Row() {
        Image($r('app.media.ic_target')).width(20).height(20).margin({ right: 12 })
        Text('健康目标').fontSize(15).fontColor('#333333')
        Blank()
        Text(this.targetGoal).fontSize(13).fontColor('#999999').margin({ right: 6 })
        Image($r('app.media.ic_arrow_right')).width(16).height(16)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 16 })
      .alignItems(VerticalAlign.Center)
      .onClick(() => {
        this.openHealthGoalPage();
      })

      Divider().color('#F0F0F0').strokeWidth(1).margin({ left: 50, right: 16 })

      // 3. 个性化膳食关注标签
      Row() {
        Image($r('app.media.ic_tag')).width(20).height(20).margin({ right: 12 })
        Text('个性化膳食关注标签').fontSize(15).fontColor('#333333')
        Blank()
        Text(this.diseaseTags || '无特殊关注').fontSize(13).fontColor('#999999').margin({ right: 6 })
        Image($r('app.media.ic_arrow_right')).width(16).height(16)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 16 })
      .alignItems(VerticalAlign.Center)
      .onClick(() => {
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

      // 4. 评分维度权重自定义
      Row() {
        Image($r('app.media.ic_slider')).width(20).height(20).margin({ right: 12 })
        Text('评分维度权重自定义').fontSize(15).fontColor('#333333')
        Blank()
        Text(this.scoreWeight).fontSize(13).fontColor('#999999').margin({ right: 6 })
        Image($r('app.media.ic_arrow_right')).width(16).height(16)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 16 })
      .alignItems(VerticalAlign.Center)
      .onClick(() => {
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

      this.MenuRow($r('app.media.ic_backup'), '本地数据导出 (JSON/CSV)', `上次备份: ${this.lastBackupTime}`, () => {
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

      this.MenuRow($r('app.media.ic_target'), '关于膳管家', 'v1.0.0', () => {
        this.openAboutPage();
      })
      Divider().color('#F0F0F0').strokeWidth(1).margin({ left: 50, right: 16 })
      this.MenuRow($r('app.media.ic_record'), '退出登录', '', () => {
        this.handleLogout();
      })
      Divider().color('#F0F0F0').strokeWidth(1).margin({ left: 50, right: 16 })
      this.MenuRow($r('app.media.ic_trash'), '注销用户', '', () => {
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
      Image(icon).width(20).height(20).margin({ right: 12 })
      Text(title).fontSize(15).fontColor('#333333')
      Blank()
      if (value && value.trim() !== '') {
        Text(value).fontSize(13).fontColor('#999999').margin({ right: 6 })
      }
      Image($r('app.media.ic_arrow_right'))
        .width(16)
        .height(16)
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 16, bottom: 16 })
    .alignItems(VerticalAlign.Center)
    .onClick(onClickAction)
  }
}
