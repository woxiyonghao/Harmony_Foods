import promptAction from '@ohos.promptAction'
import { AppTheme } from '../../common/constants/AppTheme'
import { FoodDBHelper } from '../../common/utils/FoodDBHelper'
import { UserProfile } from '../../common/models/FoodItem'

// 1. 编辑个人信息弹窗
@CustomDialog
export struct EditProfileDialog {
  controller: CustomDialogController
  @State nickname: string = ''
  @State selectedAvatar: string = '😊'
  onConfirm: (nickname: string, avatar: string) => void = () => {}

  private avatars: string[] = ['😊', '🏃', '🥗', '🧘', '🥑', '🚴', '🍎', '🍵']

  build() {
    Column({ space: 16 }) {
      Text('编辑个人资料').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#333333')

      Text('选择头像:').fontSize(13).fontColor('#666666').width('100%')
      Row({ space: 8 }) {
        ForEach(this.avatars, (av: string) => {
          Text(av)
            .fontSize(26)
            .padding(6)
            .backgroundColor(this.selectedAvatar === av ? '#E8F5E9' : '#F5F5F5')
            .borderRadius(14)
            .border({
              width: 2,
              color: this.selectedAvatar === av ? AppTheme.PRIMARY_COLOR : 'transparent'
            })
            .onClick(() => {
              this.selectedAvatar = av;
            })
        })
      }.width('100%').justifyContent(FlexAlign.SpaceAround)

      Text('用户昵称:').fontSize(13).fontColor('#666666').width('100%')
      TextInput({ text: this.nickname, placeholder: '请输入昵称' })
        .height(44)
        .backgroundColor('#F7F8FA')
        .onChange((val: string) => {
          this.nickname = val;
        })

      Row({ space: 12 }) {
        Button('取消')
          .backgroundColor('#EAEAEA')
          .fontColor('#333333')
          .layoutWeight(1)
          .onClick(() => {
            this.controller.close();
          })

        Button('保存')
          .backgroundColor(AppTheme.PRIMARY_COLOR)
          .fontColor(Color.White)
          .layoutWeight(1)
          .onClick(() => {
            if (this.nickname.trim() === '') {
              promptAction.showToast({ message: '昵称不能为空' });
              return;
            }
            this.onConfirm(this.nickname.trim(), this.selectedAvatar);
            this.controller.close();
          })
      }.width('100%').margin({ top: 8 })
    }
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .width('92%')
  }
}

// 2. 基础身体数据与 BMI 计算弹窗
@CustomDialog
export struct BodyDataDialog {
  controller: CustomDialogController
  @State heightInput: string = '175'
  @State weightInput: string = '70'
  onConfirm: (height: number, weight: number) => void = () => {}

  getBmi(): number {
    let h = parseFloat(this.heightInput) || 0;
    let w = parseFloat(this.weightInput) || 0;
    if (h <= 0 || w <= 0) return 0;
    let hm = h / 100;
    return Math.round((w / (hm * hm)) * 10) / 10;
  }

  getBmiText(): string {
    let bmi = this.getBmi();
    if (bmi <= 0) return '—';
    if (bmi < 18.5) return '偏瘦';
    if (bmi <= 23.9) return '正常健康';
    if (bmi <= 27.9) return '超重';
    return '肥胖';
  }

  getBmiColor(): string {
    let bmi = this.getBmi();
    if (bmi <= 0) return '#666666';
    if (bmi >= 18.5 && bmi <= 23.9) return AppTheme.PRIMARY_COLOR;
    if (bmi < 18.5 || (bmi > 23.9 && bmi <= 27.9)) return '#FF9800';
    return '#F44336';
  }

  build() {
    Column({ space: 14 }) {
      Text('基础身体数据').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#333333')

      Row() {
        Text('身高 (cm):').fontSize(14).fontColor('#666666').width(90)
        TextInput({ text: this.heightInput })
          .type(InputType.Number)
          .layoutWeight(1)
          .height(40)
          .backgroundColor('#F7F8FA')
          .onChange((val: string) => {
            this.heightInput = val;
          })
      }.width('100%')

      Row() {
        Text('体重 (kg):').fontSize(14).fontColor('#666666').width(90)
        TextInput({ text: this.weightInput })
          .type(InputType.Number)
          .layoutWeight(1)
          .height(40)
          .backgroundColor('#F7F8FA')
          .onChange((val: string) => {
            this.weightInput = val;
          })
      }.width('100%')

      Row() {
        Text('身体质量指数 (BMI):').fontSize(13).fontColor('#666666')
        Blank()
        Text(`${this.getBmi()}  ${this.getBmiText()}`)
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.getBmiColor())
          .backgroundColor('#F0FDF4')
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .borderRadius(8)
      }
      .width('100%')
      .padding(12)
      .backgroundColor('#FAFAFA')
      .borderRadius(10)

      Row({ space: 12 }) {
        Button('取消')
          .backgroundColor('#EAEAEA')
          .fontColor('#333333')
          .layoutWeight(1)
          .onClick(() => {
            this.controller.close();
          })

        Button('保存')
          .backgroundColor(AppTheme.PRIMARY_COLOR)
          .fontColor(Color.White)
          .layoutWeight(1)
          .onClick(() => {
            let h = parseFloat(this.heightInput) || 0;
            let w = parseFloat(this.weightInput) || 0;
            if (h < 50 || h > 250 || w < 20 || w > 300) {
              promptAction.showToast({ message: '请输入合理的身高体重数值' });
              return;
            }
            this.onConfirm(h, w);
            this.controller.close();
          })
      }.width('100%').margin({ top: 8 })
    }
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .width('92%')
  }
}

// 3. 健康目标设定弹窗
@CustomDialog
export struct HealthGoalDialog {
  controller: CustomDialogController
  @State selectedGoal: string = '保持健康'
  @State targetCalories: string = '2100'
  onConfirm: (goal: string, targetEnergy: number) => void = () => {}

  private goals: string[] = [
    '保持健康 (维持体重)',
    '轻度减重 3kg',
    '减重 5kg',
    '高蛋白低脂塑形',
    '降尿酸防痛风',
    '低盐控血压'
  ]

  build() {
    Column({ space: 14 }) {
      Text('设定健康目标').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#333333')

      List({ space: 8 }) {
        ForEach(this.goals, (g: string) => {
          ListItem() {
            Row() {
              Text(g)
                .fontSize(14)
                .fontColor(this.selectedGoal === g ? AppTheme.PRIMARY_COLOR : '#333333')
                .fontWeight(this.selectedGoal === g ? FontWeight.Bold : FontWeight.Normal)
                .layoutWeight(1)

              if (this.selectedGoal === g) {
                Text('✓').fontSize(16).fontWeight(FontWeight.Bold).fontColor(AppTheme.PRIMARY_COLOR)
              }
            }
            .width('100%')
            .padding({ left: 14, right: 14, top: 10, bottom: 10 })
            .backgroundColor(this.selectedGoal === g ? '#E8F5E9' : '#F9F9F9')
            .borderRadius(10)
            .onClick(() => {
              this.selectedGoal = g;
              if (g.includes('减重')) {
                this.targetCalories = '1800';
              } else if (g.includes('塑形')) {
                this.targetCalories = '2000';
              } else {
                this.targetCalories = '2100';
              }
            })
          }
        })
      }.width('100%').height(180)

      Row() {
        Text('每日建议目标热量:').fontSize(13).fontColor('#666666')
        Blank()
        TextInput({ text: this.targetCalories })
          .type(InputType.Number)
          .width(80)
          .height(34)
          .textAlign(TextAlign.Center)
          .backgroundColor('#F7F8FA')
          .onChange((val: string) => {
            this.targetCalories = val;
          })
        Text('千卡').fontSize(13).fontColor('#666666').margin({ left: 4 })
      }.width('100%')

      Row({ space: 12 }) {
        Button('取消')
          .backgroundColor('#EAEAEA')
          .fontColor('#333333')
          .layoutWeight(1)
          .onClick(() => {
            this.controller.close();
          })

        Button('保存')
          .backgroundColor(AppTheme.PRIMARY_COLOR)
          .fontColor(Color.White)
          .layoutWeight(1)
          .onClick(() => {
            let cal = parseInt(this.targetCalories) || 2100;
            this.onConfirm(this.selectedGoal, cal);
            this.controller.close();
          })
      }.width('100%').margin({ top: 8 })
    }
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .width('92%')
  }
}

// 4. 特殊疾病标签多选弹窗
@CustomDialog
export struct DiseaseTagsDialog {
  controller: CustomDialogController
  @State selectedTags: string[] = []
  onConfirm: (tagsStr: string) => void = () => {}

  private options: string[] = [
    '高尿酸 / 痛风',
    '高血压 (低盐关注)',
    '高血脂 / 胆固醇',
    '轻度脂肪肝',
    '控糖减脂',
    '无特殊疾病'
  ]

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

  build() {
    Column({ space: 14 }) {
      Text('特殊疾病与关注标签').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#333333')
      Text('系统将根据所选疾病在首页与分析中智能调整预警阈值与膳食建议').fontSize(12).fontColor('#888888')

      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.options, (opt: string) => {
          Text(opt)
            .fontSize(13)
            .fontColor(this.selectedTags.indexOf(opt) !== -1 ? AppTheme.PRIMARY_COLOR : '#555555')
            .backgroundColor(this.selectedTags.indexOf(opt) !== -1 ? '#E8F5E9' : '#F5F5F5')
            .padding({ left: 14, right: 14, top: 8, bottom: 8 })
            .borderRadius(16)
            .margin({ right: 8, bottom: 10 })
            .border({
              width: 1,
              color: this.selectedTags.indexOf(opt) !== -1 ? AppTheme.PRIMARY_COLOR : '#EAEAEA'
            })
            .onClick(() => {
              this.toggleTag(opt);
            })
        })
      }.width('100%').margin({ top: 4, bottom: 8 })

      Row({ space: 12 }) {
        Button('取消')
          .backgroundColor('#EAEAEA')
          .fontColor('#333333')
          .layoutWeight(1)
          .onClick(() => {
            this.controller.close();
          })

        Button('保存')
          .backgroundColor(AppTheme.PRIMARY_COLOR)
          .fontColor(Color.White)
          .layoutWeight(1)
          .onClick(() => {
            let res = this.selectedTags.length > 0 ? this.selectedTags.join(' / ') : '无特殊疾病';
            this.onConfirm(res);
            this.controller.close();
          })
      }.width('100%')
    }
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .width('92%')
  }
}

// 5. 评分维度权重设置弹窗
@CustomDialog
export struct ScoreWeightDialog {
  controller: CustomDialogController
  @State selectedMode: string = '已调高风险指标'
  onConfirm: (mode: string) => void = () => {}

  private modes: string[] = [
    '均衡通用模式',
    '已调高风险指标',
    '减脂供能比优先'
  ]

  private descriptions: string[] = [
    '宏量比例 40% · 慢病风险 40% · 能量达标 20%',
    '重点加大痛风嘌呤、高血压钠盐与胆固醇超标扣分权重，推荐特定人群使用',
    '聚焦热量缺口与优质蛋白质摄入比例，严格限制多余油脂摄入'
  ]

  build() {
    Column({ space: 14 }) {
      Text('健康评分维度权重').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#333333')

      List({ space: 10 }) {
        ForEach(this.modes, (m: string, idx: number) => {
          ListItem() {
            Column({ space: 4 }) {
              Row() {
                Text(m)
                  .fontSize(15)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.selectedMode === m ? AppTheme.PRIMARY_COLOR : '#333333')
                Blank()
                if (this.selectedMode === m) {
                  Text('✓').fontSize(16).fontWeight(FontWeight.Bold).fontColor(AppTheme.PRIMARY_COLOR)
                }
              }.width('100%')

              Text(this.descriptions[idx])
                .fontSize(11)
                .fontColor('#718096')
                .lineHeight(16)
            }
            .width('100%')
            .padding(14)
            .backgroundColor(this.selectedMode === m ? '#E8F5E9' : '#FAFAFA')
            .borderRadius(12)
            .border({
              width: 1,
              color: this.selectedMode === m ? AppTheme.PRIMARY_COLOR : '#EEEEEE'
            })
            .onClick(() => {
              this.selectedMode = m;
            })
          }
        })
      }.width('100%')

      Row({ space: 12 }) {
        Button('取消')
          .backgroundColor('#EAEAEA')
          .fontColor('#333333')
          .layoutWeight(1)
          .onClick(() => {
            this.controller.close();
          })

        Button('确定应用')
          .backgroundColor(AppTheme.PRIMARY_COLOR)
          .fontColor(Color.White)
          .layoutWeight(1)
          .onClick(() => {
            this.onConfirm(this.selectedMode);
            this.controller.close();
          })
      }.width('100%').margin({ top: 6 })
    }
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .width('92%')
  }
}

// 6. 数据导出成功展示弹窗
@CustomDialog
export struct ExportDataDialog {
  controller: CustomDialogController
  @State jsonSnippet: string = ''
  @State recordCount: number = 0
  @State backupTime: string = ''

  build() {
    Column({ space: 14 }) {
      Row({ space: 8 }) {
        Image($r('app.media.ic_backup')).width(22).height(22).fillColor(AppTheme.PRIMARY_COLOR)
        Text('本地数据导出成功').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#333333')
      }.width('100%')

      Column({ space: 6 }) {
        Text(`已为您生成包含饮食记录 (${this.recordCount}条)、收藏夹及健康档案的本地快照。`)
          .fontSize(12)
          .fontColor('#555555')
          .lineHeight(18)
        Text(`备份时间: ${this.backupTime}`)
          .fontSize(11)
          .fontColor(AppTheme.PRIMARY_COLOR)
      }
      .width('100%')
      .padding(12)
      .backgroundColor('#E8F5E9')
      .borderRadius(10)

      Scroll() {
        Text(this.jsonSnippet)
          .fontSize(10)
          .fontColor('#4A5568')
          .fontFamily('monospace')
      }
      .width('100%')
      .height(130)
      .padding(10)
      .backgroundColor('#F7F8FA')
      .borderRadius(8)

      Button('完成')
        .width('100%')
        .backgroundColor(AppTheme.PRIMARY_COLOR)
        .fontColor(Color.White)
        .onClick(() => {
          this.controller.close();
        })
    }
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .width('92%')
  }
}

// 7. 恢复与重置数据弹窗
@CustomDialog
export struct RestoreDataDialog {
  controller: CustomDialogController
  onRestoreDefaults: () => void = () => {}
  onClearRecords: () => void = () => {}

  build() {
    Column({ space: 14 }) {
      Row({ space: 8 }) {
        Image($r('app.media.ic_restore')).width(22).height(22).fillColor('#FF9800')
        Text('数据恢复与管理').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#333333')
      }.width('100%')

      Text('您可以重置系统预置食物与收藏夹，或在需要时清空所有饮食记录。')
        .fontSize(12)
        .fontColor('#666666')
        .lineHeight(18)

      Button('重置预置常用食物与收藏夹')
        .width('100%')
        .height(40)
        .backgroundColor('#FFF3E0')
        .fontColor('#FF9800')
        .onClick(() => {
          this.onRestoreDefaults();
          this.controller.close();
        })

      Button('清空所有饮食记录')
        .width('100%')
        .height(40)
        .backgroundColor('#FFF0F0')
        .fontColor('#FF4D4F')
        .onClick(() => {
          this.onClearRecords();
          this.controller.close();
        })

      Button('取消')
        .width('100%')
        .backgroundColor('#EAEAEA')
        .fontColor('#333333')
        .onClick(() => {
          this.controller.close();
        })
    }
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .width('92%')
  }
}

@Component
export struct ProfileView {
  @Prop @Watch('onActiveTabChange') activeTab: number = 0;
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

  editProfileController: CustomDialogController | null = null;
  bodyDataController: CustomDialogController | null = null;
  healthGoalController: CustomDialogController | null = null;
  diseaseTagsController: CustomDialogController | null = null;
  scoreWeightController: CustomDialogController | null = null;
  exportDataController: CustomDialogController | null = null;
  restoreDataController: CustomDialogController | null = null;

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

  async loadProfile() {
    this.profile = await FoodDBHelper.getUserProfile();
  }

  async saveAndRefresh(updated: UserProfile) {
    this.profile = updated;
    await FoodDBHelper.saveUserProfile(updated);
    try {
      promptAction.showToast({ message: '已保存更新' });
    } catch (err) {}
  }

  openEditProfileDialog() {
    this.editProfileController = new CustomDialogController({
      builder: EditProfileDialog({
        nickname: this.profile.nickname,
        selectedAvatar: this.profile.avatar,
        onConfirm: (nick: string, av: string) => {
          this.profile.nickname = nick;
          this.profile.avatar = av;
          this.saveAndRefresh(this.profile);
        }
      }),
      alignment: DialogAlignment.Center,
      autoCancel: true
    });
    this.editProfileController.open();
  }

  openBodyDataDialog() {
    this.bodyDataController = new CustomDialogController({
      builder: BodyDataDialog({
        heightInput: this.profile.height.toString(),
        weightInput: this.profile.weight.toString(),
        onConfirm: (h: number, w: number) => {
          this.profile.height = h;
          this.profile.weight = w;
          this.saveAndRefresh(this.profile);
        }
      }),
      alignment: DialogAlignment.Center,
      autoCancel: true
    });
    this.bodyDataController.open();
  }

  openHealthGoalDialog() {
    this.healthGoalController = new CustomDialogController({
      builder: HealthGoalDialog({
        selectedGoal: this.profile.targetGoal,
        targetCalories: this.profile.targetEnergy.toString(),
        onConfirm: (goal: string, targetCal: number) => {
          this.profile.targetGoal = goal;
          this.profile.targetEnergy = targetCal;
          this.saveAndRefresh(this.profile);
        }
      }),
      alignment: DialogAlignment.Center,
      autoCancel: true
    });
    this.healthGoalController.open();
  }

  openDiseaseTagsDialog() {
    let tagsList = this.profile.diseaseTags ? this.profile.diseaseTags.split(' / ') : [];
    this.diseaseTagsController = new CustomDialogController({
      builder: DiseaseTagsDialog({
        selectedTags: tagsList,
        onConfirm: (tagsStr: string) => {
          this.profile.diseaseTags = tagsStr;
          this.saveAndRefresh(this.profile);
        }
      }),
      alignment: DialogAlignment.Center,
      autoCancel: true
    });
    this.diseaseTagsController.open();
  }

  openScoreWeightDialog() {
    this.scoreWeightController = new CustomDialogController({
      builder: ScoreWeightDialog({
        selectedMode: this.profile.scoreWeight,
        onConfirm: (mode: string) => {
          this.profile.scoreWeight = mode;
          this.saveAndRefresh(this.profile);
        }
      }),
      alignment: DialogAlignment.Center,
      autoCancel: true
    });
    this.scoreWeightController.open();
  }

  async handleExportData() {
    let jsonStr = await FoodDBHelper.exportAllDataAsJson();
    let records = await FoodDBHelper.getAllDietRecords();
    await this.loadProfile();

    this.exportDataController = new CustomDialogController({
      builder: ExportDataDialog({
        jsonSnippet: jsonStr,
        recordCount: records.length,
        backupTime: this.profile.lastBackupTime
      }),
      alignment: DialogAlignment.Center,
      autoCancel: true
    });
    this.exportDataController.open();
  }

  handleRestoreData() {
    this.restoreDataController = new CustomDialogController({
      builder: RestoreDataDialog({
        onRestoreDefaults: async () => {
          await FoodDBHelper.seedInitialFavoritesIfEmpty();
          await this.loadProfile();
          try {
            promptAction.showToast({ message: '已成功恢复预置数据' });
          } catch (e) {}
        },
        onClearRecords: async () => {
          await FoodDBHelper.clearAllDietRecords();
          try {
            promptAction.showToast({ message: '已清空所有饮食记录' });
          } catch (e) {}
        }
      }),
      alignment: DialogAlignment.Center,
      autoCancel: true
    });
    this.restoreDataController.open();
  }

  build() {
    Column() {
      Scroll() {
        Column({ space: 16 }) {
          this.HeaderSection()
          this.HealthProfileCard()
          this.SettingsCard()
          this.DataManagementCard()
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
        Text('ID: 88481234')
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
          this.openEditProfileDialog();
        })
    }
    .width('100%')
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .shadow({ radius: 8, color: 'rgba(0,0,0,0.03)', offsetY: 4 })
    .onClick(() => {
      this.openEditProfileDialog();
    })
  }

  @Builder
  HealthProfileCard() {
    Column() {
      Row() {
        Text('健康档案').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#333333')
      }.width('100%').padding({ left: 16, top: 16, bottom: 8 })
      
      this.MenuRow($r('app.media.ic_body'), '基础身体数据', `${this.profile.height}cm / ${this.profile.weight}kg`, () => {
        this.openBodyDataDialog();
      })
      Divider().color('#F0F0F0').strokeWidth(1).margin({ left: 50, right: 16 })
      this.MenuRow($r('app.media.ic_target'), '健康目标', this.profile.targetGoal, () => {
        this.openHealthGoalDialog();
      })
      Divider().color('#F0F0F0').strokeWidth(1).margin({ left: 50, right: 16 })
      this.MenuRow($r('app.media.ic_tag'), '特殊疾病标签', this.profile.diseaseTags || '无特殊疾病', () => {
        this.openDiseaseTagsDialog();
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
        this.openScoreWeightDialog();
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
        this.handleExportData();
      })
      Divider().color('#F0F0F0').strokeWidth(1).margin({ left: 50, right: 16 })
      this.MenuRow($r('app.media.ic_restore'), '恢复与重置数据', '', () => {
        this.handleRestoreData();
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

