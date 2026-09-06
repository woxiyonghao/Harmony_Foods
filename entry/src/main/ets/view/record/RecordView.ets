import { AppTheme } from '../../common/constants/AppTheme'
import { DateNavigator } from '../../common/components/DateNavigator'

interface FoodEntry {
  name: string;
  amount: string;
  energy: number;
}

interface MealSlot {
  title: string;
  icon: Resource;
  foods: FoodEntry[];
  suggestedEnergy?: string;
}

@Component
export struct RecordView {
  @State meals: MealSlot[] = [
    {
      title: '早餐',
      icon: $r('app.media.ic_breakfast'),
      suggestedEnergy: '推荐 400-600',
      foods: [
        { name: '全麦面包', amount: '100g', energy: 247 },
        { name: '纯牛奶', amount: '250ml', energy: 165 }
      ]
    },
    {
      title: '午餐',
      icon: $r('app.media.ic_lunch'),
      suggestedEnergy: '推荐 600-800',
      foods: [
        { name: '米饭', amount: '150g', energy: 174 },
        { name: '西红柿炒鸡蛋', amount: '200g', energy: 240 }
      ]
    },
    {
      title: '晚餐',
      icon: $r('app.media.ic_dinner'),
      suggestedEnergy: '推荐 400-600',
      foods: [] // 留空展示空状态
    },
    {
      title: '加餐',
      icon: $r('app.media.ic_snack'),
      foods: []
    }
  ];

  getMealEnergy(foods: FoodEntry[]): number {
    let total = 0;
    for (let f of foods) {
      total += f.energy;
    }
    return total;
  }

  build() {
    Column() {
      // 1. 顶部日期导航与今日汇总 (引入通用的 DateNavigator)
      DateNavigator({
        dateText: '9月6日 今天',
        subText: '总摄入 826 / 2100 千卡',
        onPrevClick: () => {
          console.log('点击了前一天');
        },
        onNextClick: () => {
          console.log('点击了后一天');
        }
      })

      Scroll() {
        Column({ space: 16 }) {
          // 2. 快捷记录工具栏
          this.QuickActions()

          // 3. 四个时段的饮食记录卡片
          ForEach(this.meals, (meal: MealSlot) => {
            this.MealCard(meal)
          })
          
          Blank().height(20) // 底部留白
        }
        .padding({ left: 16, right: 16, top: 12, bottom: 20 })
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
  QuickActions() {
    Row({ space: 10 }) {
      this.QuickActionButton($r('app.media.ic_search'), '搜索添加', '#2196F3')
      this.QuickActionButton($r('app.media.ic_recent'), '最近吃过', '#FF9800')
      this.QuickActionButton($r('app.media.ic_favorite'), '我的收藏', '#E91E63')
      this.QuickActionButton($r('app.media.ic_flash'), '快捷录入', AppTheme.PRIMARY_COLOR)
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder
  QuickActionButton(icon: Resource, text: string, iconColor: string) {
    Column({ space: 8 }) {
      Image(icon).width(24).height(24).fillColor(iconColor)
      Text(text).fontSize(12).fontColor('#555555').fontWeight(FontWeight.Medium)
    }
    .layoutWeight(1)
    .padding({ top: 14, bottom: 14 })
    .backgroundColor(Color.White)
    .borderRadius(12)
    .shadow({ radius: 8, color: 'rgba(0,0,0,0.03)', offsetY: 4 })
  }

  @Builder
  MealCard(meal: MealSlot) {
    Column() {
      // 头部：图标、标题、推荐热量与添加按钮
      Row() {
        Row({ space: 8 }) {
          Image(meal.icon).width(22).height(22).fillColor('#333333')
          Text(meal.title).fontSize(16).fontWeight(FontWeight.Bold).fontColor('#333333')
          if (meal.suggestedEnergy) {
            Text(meal.suggestedEnergy).fontSize(11).fontColor('#999999')
          }
        }
        
        Blank()
        
        // 当餐总热量
        Text(`${this.getMealEnergy(meal.foods)} 千卡`)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(meal.foods.length > 0 ? AppTheme.PRIMARY_COLOR : '#999999')
          .margin({ right: 12 })
        
        // 添加按钮
        Button('+')
          .type(ButtonType.Circle)
          .width(26).height(26)
          .backgroundColor(AppTheme.PRIMARY_COLOR)
          .fontSize(18)
          .fontColor(Color.White)
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      
      // 食物列表详情
      if (meal.foods.length > 0) {
        Column() {
          ForEach(meal.foods, (food: FoodEntry, index: number) => {
            Row() {
              Column() {
                Text(food.name).fontSize(14).fontColor('#333333').fontWeight(FontWeight.Medium)
                Text(food.amount).fontSize(12).fontColor('#999999').margin({ top: 4 })
              }.alignItems(HorizontalAlign.Start)
              
              Blank()
              
              Text(`${food.energy} 千卡`).fontSize(14).fontColor('#555555')
            }
            .width('100%')
            .padding({ top: 12, bottom: index === meal.foods.length - 1 ? 0 : 12 })
            
            // 分割线
            if (index !== meal.foods.length - 1) {
              Divider().color('#F0F0F0').strokeWidth(1)
            }
          })
        }
        .width('100%')
        .margin({ top: 12 })
      } else {
        // 空状态
        Row() {
          Text(`点击右上角添加${meal.title}`).fontSize(12).fontColor('#CCCCCC')
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .padding({ top: 20, bottom: 8 })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .shadow({ radius: 8, color: 'rgba(0,0,0,0.03)', offsetY: 4 })
  }
}
