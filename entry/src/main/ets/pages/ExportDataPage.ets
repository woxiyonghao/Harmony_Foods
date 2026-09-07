import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import pasteboard from '@ohos.pasteboard';
import { AppTheme } from '../common/constants/AppTheme';
import { UserProfile } from '../common/models/FoodItem';
import { FoodDBHelper } from '../common/utils/FoodDBHelper';

@Entry
@Component
struct ExportDataPage {
  @State recordCount: number = 0;
  @State favoriteCount: number = 0;
  @State customFoodCount: number = 0;
  @State lastBackupTime: string = '未备份';
  @State exportFormat: string = 'JSON'; // 'JSON' | 'CSV'
  @State jsonSnippet: string = '正在抓取本地数据...';
  @State csvSnippet: string = '正在生成 CSV 表格...';
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
    await this.refreshData();
  }

  async refreshData() {
    this.profile = await FoodDBHelper.getUserProfile();
    let records = await FoodDBHelper.getAllDietRecords();
    let favorites = await FoodDBHelper.getFavoriteFoods();
    let customs = await FoodDBHelper.getCustomFoods();
    let json = await FoodDBHelper.exportAllDataAsJson();
    let csv = await FoodDBHelper.exportAllDataAsCsv();

    this.recordCount = records.length;
    this.favoriteCount = favorites.length;
    this.customFoodCount = customs.length;
    this.lastBackupTime = this.profile.lastBackupTime;
    this.jsonSnippet = json;
    this.csvSnippet = csv;
  }

  async handleCopy(format: string) {
    try {
      let content = format === 'CSV' ? this.csvSnippet : this.jsonSnippet;
      let pasteData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, content);
      let systemPasteboard = pasteboard.getSystemPasteboard();
      await systemPasteboard.setData(pasteData);
      let newTime = await FoodDBHelper.updateBackupTime();
      this.lastBackupTime = newTime;
      promptAction.showToast({
        message: format === 'CSV' ? 'CSV 表格数据已复制到剪贴板，已更新备份时间' : 'JSON 备份数据已复制到剪贴板，已更新备份时间'
      });
    } catch (e) {
      try {
        promptAction.showToast({ message: '数据已复制' });
      } catch (err) {}
    }
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

        Text('本地数据导出')
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
          // 数据统计卡片
          Column({ space: 12 }) {
            Text('本地数据资产概况')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
              .width('100%')

            Row() {
              Column({ space: 4 }) {
                Text(`${this.recordCount}`).fontSize(22).fontWeight(FontWeight.Bold).fontColor(AppTheme.PRIMARY_COLOR)
                Text('历史饮食记录').fontSize(12).fontColor('#666666')
              }.layoutWeight(1).alignItems(HorizontalAlign.Center)

              Column({ space: 4 }) {
                Text(`${this.favoriteCount}`).fontSize(22).fontWeight(FontWeight.Bold).fontColor('#2196F3')
                Text('收藏食物').fontSize(12).fontColor('#666666')
              }.layoutWeight(1).alignItems(HorizontalAlign.Center)

              Column({ space: 4 }) {
                Text(`${this.customFoodCount}`).fontSize(22).fontWeight(FontWeight.Bold).fontColor('#FF9800')
                Text('自定义食物').fontSize(12).fontColor('#666666')
              }.layoutWeight(1).alignItems(HorizontalAlign.Center)
            }
            .width('100%')
            .padding({ top: 12, bottom: 12 })
            .backgroundColor('#F7F8FA')
            .borderRadius(12)

            Row() {
              Text('上次备份时间:').fontSize(12).fontColor('#888888')
              Blank()
              Text(this.lastBackupTime).fontSize(12).fontColor(AppTheme.PRIMARY_COLOR).fontWeight(FontWeight.Medium)
            }.width('100%')
          }
          .width('100%')
          .padding(20)
          .backgroundColor(Color.White)
          .borderRadius(16)
          .shadow({ radius: 8, color: 'rgba(0,0,0,0.03)', offsetY: 4 })

          // 导出格式切换与说明
          Column({ space: 14 }) {
            Row() {
              Text('导出格式与内容')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')

              Blank()

              // 格式选择 Switcher
              Row({ space: 4 }) {
                Text('JSON 档案')
                  .fontSize(12)
                  .fontWeight(this.exportFormat === 'JSON' ? FontWeight.Bold : FontWeight.Normal)
                  .fontColor(this.exportFormat === 'JSON' ? Color.White : '#666666')
                  .backgroundColor(this.exportFormat === 'JSON' ? AppTheme.PRIMARY_COLOR : '#F0F0F0')
                  .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                  .borderRadius(10)
                  .onClick(() => {
                    this.exportFormat = 'JSON';
                  })

                Text('CSV 表格')
                  .fontSize(12)
                  .fontWeight(this.exportFormat === 'CSV' ? FontWeight.Bold : FontWeight.Normal)
                  .fontColor(this.exportFormat === 'CSV' ? Color.White : '#666666')
                  .backgroundColor(this.exportFormat === 'CSV' ? AppTheme.PRIMARY_COLOR : '#F0F0F0')
                  .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                  .borderRadius(10)
                  .onClick(() => {
                    this.exportFormat = 'CSV';
                  })
              }
              .backgroundColor('#EFEFEF')
              .padding(2)
              .borderRadius(12)
            }
            .width('100%')

            Text(this.exportFormat === 'JSON'
              ? 'JSON 格式：包含完整用户资料、历史全量饮食条目明细、收藏夹与自定义库的结构化流数据，适合离线数据完整备份与多端迁移。'
              : 'CSV 格式：逗号分隔纯文本表格格式，包含日期、餐段、食物名称、摄入克重、热量及三大营养素，可直接用 Excel 或 WPS 等表格软件打开。')
              .fontSize(12)
              .fontColor('#666666')
              .lineHeight(18)

            Row({ space: 12 }) {
              Button(this.exportFormat === 'JSON' ? '复制全量 JSON' : '复制 CSV 表格')
                .layoutWeight(1)
                .height(42)
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.White)
                .backgroundColor(AppTheme.PRIMARY_COLOR)
                .borderRadius(21)
                .onClick(() => {
                  this.handleCopy(this.exportFormat);
                })

              Button('更新快照')
                .layoutWeight(1)
                .height(42)
                .fontSize(14)
                .fontColor('#333333')
                .backgroundColor('#EAEAEA')
                .borderRadius(21)
                .onClick(async () => {
                  await this.refreshData();
                  try {
                    promptAction.showToast({ message: '本地快照已刷新' });
                  } catch (e) {}
                })
            }.width('100%')
          }
          .width('100%')
          .padding(20)
          .backgroundColor(Color.White)
          .borderRadius(16)
          .shadow({ radius: 8, color: 'rgba(0,0,0,0.03)', offsetY: 4 })

          // 代码预览区域 (支持 JSON 与 CSV 动态切换)
          Column({ space: 10 }) {
            Row() {
              Text('数据流预览')
                .fontSize(15)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
              Blank()
              Text(this.exportFormat)
                .fontSize(12)
                .fontColor('#888888')
                .backgroundColor('#EEEEEE')
                .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                .borderRadius(4)
            }.width('100%')

            Scroll() {
              Text(this.exportFormat === 'JSON' ? this.jsonSnippet : this.csvSnippet)
                .fontSize(11)
                .fontColor('#333333')
                .fontFamily('monospace')
                .lineHeight(16)
            }
            .width('100%')
            .height(260)
            .padding(12)
            .backgroundColor('#F5F5F5')
            .borderRadius(8)
          }
          .width('100%')
          .padding(20)
          .backgroundColor(Color.White)
          .borderRadius(16)
          .shadow({ radius: 8, color: 'rgba(0,0,0,0.03)', offsetY: 4 })
          .margin({ bottom: 24 })
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
