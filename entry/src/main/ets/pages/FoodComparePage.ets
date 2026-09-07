import router from '@ohos.router'
import { AppTheme } from '../common/constants/AppTheme'
import { FoodItem, FoodTag } from '../view/food/FoodLibraryView'

@Entry
@Component
struct FoodComparePage {
  @State foodA: FoodItem | null = null;
  @State foodB: FoodItem | null = null;

  aboutToAppear() {
    let params = router.getParams() as Record<string, Object>;
    if (params && params['foodA'] && params['foodB']) {
      this.foodA = params['foodA'] as FoodItem;
      this.foodB = params['foodB'] as FoodItem;
    }
  }

  build() {
    Column() {
      // 1. 自定义顶部导航栏
      Row() {
        Row() {
          Image($r('app.media.ic_arrow_left'))
            .width(24)
            .height(24)
            .fillColor('#333333')
        }
        .width(40)
        .height(40)
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          router.back();
        })

        Text('营养对比')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .margin({ right: 40 }) // 抵消左侧按钮占据的空间，保持标题居中
      }
      .width('100%')
      .height(56)
      .backgroundColor(Color.White)
      .padding({ left: 8, right: 8 })
      .shadow({ radius: 4, color: 'rgba(0,0,0,0.02)', offsetY: 2 })

      if (this.foodA && this.foodB) {
        Scroll() {
          Column() {
            // 2. 顶部对比对象卡片
            Row() {
              this.FoodHeader(this.foodA, AppTheme.PRIMARY_COLOR)
              
              Text('VS')
                .fontSize(20)
                .fontWeight(900)
                .fontColor('#E0E0E0')
                .fontStyle(FontStyle.Italic)
                .margin({ left: 12, right: 12 })
              
              this.FoodHeader(this.foodB, '#FF9800')
            }
            .width('100%')
            .padding(20)
            .backgroundColor(Color.White)
            .borderRadius(16)
            .margin({ top: 16, bottom: 16 })
            .shadow({ radius: 8, color: 'rgba(0,0,0,0.03)', offsetY: 4 })

            // 3. 营养素条形图对比区域
            Column() {
              Text('每 100g 营养成分对比')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
                .width('100%')
                .textAlign(TextAlign.Center)
                .margin({ bottom: 20 })

              this.CompareRow('热量 (千卡)', this.foodA.energy, this.foodB.energy, 400)
              this.CompareRow('蛋白质 (g)', this.foodA.protein || 0, this.foodB.protein || 0, 30)
              this.CompareRow('脂肪 (g)', this.foodA.fat || 0, this.foodB.fat || 0, 30)
              this.CompareRow('碳水 (g)', this.foodA.carbs || 0, this.foodB.carbs || 0, 50)
            }
            .width('100%')
            .padding(20)
            .backgroundColor(Color.White)
            .borderRadius(16)
            .margin({ bottom: 16 })
            .shadow({ radius: 8, color: 'rgba(0,0,0,0.03)', offsetY: 4 })
            
            // 4. 标签对比区域
            Column() {
              Text('标签特性对比')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
                .width('100%')
                .textAlign(TextAlign.Center)
                .margin({ bottom: 16 })
                
              Row() {
                Column() {
                  this.TagsFlow(this.foodA.tags)
                }.layoutWeight(1).alignItems(HorizontalAlign.Start)
                
                Divider().vertical(true).height('80%').color('#F0F0F0').margin({ left: 12, right: 12 })
                
                Column() {
                  this.TagsFlow(this.foodB.tags)
                }.layoutWeight(1).alignItems(HorizontalAlign.Start)
              }
              .width('100%')
              .alignItems(VerticalAlign.Top)
            }
            .width('100%')
            .padding(20)
            .backgroundColor(Color.White)
            .borderRadius(16)
            .margin({ bottom: 30 })
            .shadow({ radius: 8, color: 'rgba(0,0,0,0.03)', offsetY: 4 })

          }
          .padding({ left: 16, right: 16 })
        }
        .width('100%')
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F7F8FA')
  }

  @Builder FoodHeader(food: FoodItem, themeColor: string) {
    Column({ space: 8 }) {
      Row() {
        Image($r('app.media.ic_food'))
          .width(20)
          .height(20)
          .fillColor(themeColor)
      }
      .width(48)
      .height(48)
      .backgroundColor(themeColor + '1A') // 10% opacity
      .borderRadius(24)
      .justifyContent(FlexAlign.Center)
      
      Text(food.name)
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .textAlign(TextAlign.Center)
    }
    .layoutWeight(1)
  }

  @Builder CompareRow(label: string, valA: number, valB: number, maxVal: number) {
    Column() {
      // 数值与标签层
      Row() {
        Text(valA.toString())
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppTheme.PRIMARY_COLOR)
          .layoutWeight(1)
          .textAlign(TextAlign.Start)
          
        Text(label)
          .fontSize(12)
          .fontColor('#999999')
          .width(80)
          .textAlign(TextAlign.Center)
          
        Text(valB.toString())
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FF9800')
          .layoutWeight(1)
          .textAlign(TextAlign.End)
      }
      .width('100%')
      .margin({ bottom: 6 })
      
      // 条形图层
      Row() {
        // 左侧 A 的条（靠右对齐）
        Row() {
          Row()
            .height(8)
            .borderRadius({ topLeft: 4, bottomLeft: 4 })
            .backgroundColor(AppTheme.PRIMARY_COLOR)
            .width(`${Math.min((valA / maxVal) * 100, 100)}%`)
        }
        .layoutWeight(1)
        .height(8)
        .backgroundColor('#F0F0F0')
        .borderRadius({ topLeft: 4, bottomLeft: 4 })
        .justifyContent(FlexAlign.End)
        
        // 中间间隙
        Row().width(4).height(8).backgroundColor(Color.White)
        
        // 右侧 B 的条（靠左对齐）
        Row() {
          Row()
            .height(8)
            .borderRadius({ topRight: 4, bottomRight: 4 })
            .backgroundColor('#FF9800')
            .width(`${Math.min((valB / maxVal) * 100, 100)}%`)
        }
        .layoutWeight(1)
        .height(8)
        .backgroundColor('#F0F0F0')
        .borderRadius({ topRight: 4, bottomRight: 4 })
        .justifyContent(FlexAlign.Start)
      }
      .width('100%')
    }
    .width('100%')
    .margin({ bottom: 20 })
  }

  @Builder TagsFlow(tags: FoodTag[]) {
    Flex({ wrap: FlexWrap.Wrap }) {
      if (tags && tags.length > 0) {
        ForEach(tags, (tag: FoodTag) => {
          Text(tag.label)
            .fontSize(11)
            .fontColor(tag.color)
            .backgroundColor(tag.bgColor)
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .borderRadius(6)
            .margin({ right: 6, bottom: 6 })
        })
      } else {
        Text('暂无标签')
          .fontSize(12)
          .fontColor('#AAAAAA')
      }
    }
  }
}
