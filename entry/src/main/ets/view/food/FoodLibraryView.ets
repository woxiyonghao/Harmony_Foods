import { AppTheme } from '../../common/constants/AppTheme'

interface Category {
  name: string;
  icon?: Resource;
}

interface FoodTag {
  label: string;
  color: string;
  bgColor: string;
}

interface FoodItem {
  name: string;
  energy: number; // kcal per 100g
  tags: FoodTag[];
  imageUrl?: string;
}

@Component
export struct FoodLibraryView {
  @State selectedCategoryIndex: number = 0;
  @State searchQuery: string = '';

  private categories: Category[] = [
    { name: '全部' },
    { name: '蔬菜类', icon: $r('app.media.ic_veg') },
    { name: '水果类', icon: $r('app.media.ic_fruit') },
    { name: '肉禽类', icon: $r('app.media.ic_meat') },
    { name: '饮品类', icon: $r('app.media.ic_drink') },
    { name: '中式菜肴' }
  ];

  private mockFoods: FoodItem[] = [
    {
      name: '苹果 (带皮)', energy: 53,
      tags: [
        { label: '低嘌呤', color: AppTheme.PRIMARY_COLOR, bgColor: '#E8F5E9' },
        { label: '低钠', color: AppTheme.PRIMARY_COLOR, bgColor: '#E8F5E9' }
      ]
    },
    {
      name: '猪肉 (瘦)', energy: 143,
      tags: [
        { label: '中嘌呤 (150mg)', color: '#FF9800', bgColor: '#FFF3E0' },
        { label: '高蛋白', color: '#2196F3', bgColor: '#E3F2FD' }
      ]
    },
    {
      name: '猪肝', energy: 130,
      tags: [
        { label: '高嘌呤 (275mg)', color: '#F44336', bgColor: '#FFEBEE' },
        { label: '高胆固醇', color: '#F44336', bgColor: '#FFEBEE' }
      ]
    },
    {
      name: '菠菜 (水煮)', energy: 28,
      tags: [
        { label: '低热量', color: AppTheme.PRIMARY_COLOR, bgColor: '#E8F5E9' },
        { label: '草酸溶出', color: '#FF9800', bgColor: '#FFF3E0' }
      ]
    },
    {
      name: '全脂牛奶', energy: 62,
      tags: [
        { label: '高钙', color: '#2196F3', bgColor: '#E3F2FD' },
        { label: '极低嘌呤', color: AppTheme.PRIMARY_COLOR, bgColor: '#E8F5E9' }
      ]
    }
  ];

  build() {
    Column() {
      // 1. 顶部搜索栏
      Row() {
        Search({ value: this.searchQuery, placeholder: '搜索食物 (中文/拼音/别名)' })
          .searchButton('搜索')
          .width('100%')
          .height(40)
          .backgroundColor(Color.White)
          .placeholderColor(Color.Grey)
          .placeholderFont({ size: 14 })
          .textFont({ size: 14 })
          .onSubmit((value: string) => {
            this.searchQuery = value;
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .backgroundColor('#F7F8FA')

      // 2. 类别横向滚动导航
      Scroll() {
        Row({ space: 12 }) {
          ForEach(this.categories, (item: Category, index: number) => {
            this.CategoryChip(item, index)
          })
        }
        .padding({ left: 16, right: 16, bottom: 12 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
      .backgroundColor('#F7F8FA')

      // 3. 食物列表与自定义入口
      List({ space: 12 }) {
        ForEach(this.mockFoods, (food: FoodItem) => {
          ListItem() {
            this.FoodCard(food)
          }
        })
        
        // 底部自定义食物卡片入口
        ListItem() {
          Row() {
            Text('+ 自定义添加食物')
              .fontSize(16)
              .fontColor(AppTheme.PRIMARY_COLOR)
              .fontWeight(FontWeight.Medium)
          }
          .width('100%')
          .height(50)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(Color.White)
          .borderRadius(12)
          .border({ width: 1, color: AppTheme.PRIMARY_COLOR, style: BorderStyle.Dashed })
          .margin({ bottom: 20 })
        }
      }
      .padding({ left: 16, right: 16, top: 8, bottom: 20 })
      .width('100%')
      .layoutWeight(1)
      .backgroundColor('#F7F8FA')
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Start)
  }

  // 组件：类别筛选药丸 (Pill)
  @Builder
  CategoryChip(item: Category, index: number) {
    Row({ space: 6 }) {
      if (item.icon) {
        Image(item.icon)
          .width(16).height(16)
          .fillColor(this.selectedCategoryIndex === index ? Color.White : '#666666')
      }
      Text(item.name)
        .fontSize(14)
        .fontColor(this.selectedCategoryIndex === index ? Color.White : '#333333')
        .fontWeight(this.selectedCategoryIndex === index ? FontWeight.Bold : FontWeight.Normal)
    }
    .padding({ left: 16, right: 16, top: 8, bottom: 8 })
    .backgroundColor(this.selectedCategoryIndex === index ? AppTheme.PRIMARY_COLOR : Color.White)
    .borderRadius(20)
    .shadow(this.selectedCategoryIndex === index ? { radius: 8, color: 'rgba(46,139,87,0.3)', offsetY: 4 } : { radius: 0 })
    .onClick(() => {
      this.selectedCategoryIndex = index;
    })
  }

  // 组件：食物详细信息卡片
  @Builder
  FoodCard(food: FoodItem) {
    Row() {
      // 左侧：头像/图片占位
      Stack() {
        Text(food.name.substring(0, 1)).fontSize(20).fontWeight(FontWeight.Bold).fontColor('#999')
      }
      .width(60).height(60)
      .backgroundColor('#F0F0F0')
      .borderRadius(12)
      .margin({ right: 16 })

      // 中间：名称与指标标签
      Column({ space: 6 }) {
        Text(food.name).fontSize(16).fontWeight(FontWeight.Bold).fontColor('#333333')
        Text(`${food.energy} 千卡 / 100g`).fontSize(13).fontColor('#666666')
        
        // 动态标签流式布局
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(food.tags, (tag: FoodTag) => {
            Text(tag.label)
              .fontSize(10)
              .fontColor(tag.color)
              .backgroundColor(tag.bgColor)
              .padding({ left: 6, right: 6, top: 3, bottom: 3 })
              .borderRadius(6)
              .margin({ right: 6, bottom: 6 })
          })
        }
        .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      // 右侧：对比按钮
      Column() {
        Button('对比')
          .type(ButtonType.Capsule)
          .fontSize(12)
          .backgroundColor('#F0F0F0')
          .fontColor('#333333')
          .width(60).height(28)
      }.justifyContent(FlexAlign.Center).height(60)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .shadow({ radius: 8, color: 'rgba(0,0,0,0.03)', offsetY: 4 })
  }
}
