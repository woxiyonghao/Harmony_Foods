import router from '@ohos.router'
import promptAction from '@ohos.promptAction'
import { AppTheme } from '../../common/constants/AppTheme'
import { FoodDBHelper } from '../../common/utils/FoodDBHelper'

export interface Category {
  name: string;
  icon?: Resource;
}

export interface FoodTag {
  label: string;
  color: string;
  bgColor: string;
}

export interface FoodItem {
  id: string;
  categoryId: number; // 0=全部, 1=蔬菜, 2=水果, 3=肉禽, 4=饮品, 5=中式
  name: string;
  energy: number; // kcal per 100g
  tags: FoodTag[];
  protein?: number;
  fat?: number;
  carbs?: number;
}

@CustomDialog
export struct AddFoodDialog {
  controller: CustomDialogController
  @State foodName: string = ''
  @State energy: string = ''
  confirm: (name: string, energy: number) => void = () => {}

  build() {
    Column({ space: 16 }) {
      Text('自定义添加食物').fontSize(20).fontWeight(FontWeight.Bold).fontColor('#333333')
      
      TextInput({ placeholder: '请输入食物名称 (如: 燕麦片)' })
        .onChange((value: string) => { this.foodName = value; })
        .height(48)
        
      TextInput({ placeholder: '热量 (千卡/100g)' })
        .type(InputType.Number)
        .onChange((value: string) => { this.energy = value; })
        .height(48)
        
      Row({ space: 16 }) {
        Button('取消')
          .onClick(() => { this.controller.close(); })
          .backgroundColor('#EAEAEA')
          .fontColor('#333333')
          .layoutWeight(1)
          
        Button('确定')
          .onClick(() => {
            if (this.foodName.trim() === '') {
              promptAction.showToast({ message: '请输入食物名称' });
              return;
            }
            if (this.energy.trim() === '') {
              promptAction.showToast({ message: '请输入热量' });
              return;
            }
            this.confirm(this.foodName, parseInt(this.energy) || 0);
            this.controller.close();
          })
          .backgroundColor(AppTheme.PRIMARY_COLOR)
          .fontColor(Color.White)
          .layoutWeight(1)
      }.width('100%').margin({ top: 12 })
    }
    .padding(24)
    .backgroundColor(Color.White)
    .borderRadius(16)
  }
}

@Component
export struct FoodLibraryView {
  @State selectedCategoryIndex: number = 0;
  @State searchQuery: string = '';
  @State compareList: FoodItem[] = [];

  private categories: Category[] = [
    { name: '全部' },
    { name: '蔬菜类', icon: $r('app.media.ic_veg') },
    { name: '水果类', icon: $r('app.media.ic_fruit') },
    { name: '肉禽类', icon: $r('app.media.ic_meat') },
    { name: '饮品类', icon: $r('app.media.ic_drink') },
    { name: '中式菜肴' }
  ];

  @State mockFoods: FoodItem[] = [
    {
      id: '1', categoryId: 2,
      name: '苹果 (带皮)', energy: 53,
      protein: 0.2, fat: 0.2, carbs: 13.8,
      tags: [
        { label: '低嘌呤', color: AppTheme.PRIMARY_COLOR, bgColor: '#E8F5E9' },
        { label: '低钠', color: AppTheme.PRIMARY_COLOR, bgColor: '#E8F5E9' }
      ]
    },
    {
      id: '2', categoryId: 3,
      name: '猪肉 (瘦)', energy: 143,
      protein: 20.3, fat: 6.2, carbs: 1.5,
      tags: [
        { label: '中嘌呤 (150mg)', color: '#FF9800', bgColor: '#FFF3E0' },
        { label: '高蛋白', color: '#2196F3', bgColor: '#E3F2FD' }
      ]
    },
    {
      id: '3', categoryId: 3,
      name: '猪肝', energy: 130,
      protein: 19.3, fat: 3.5, carbs: 5.0,
      tags: [
        { label: '高嘌呤 (275mg)', color: '#F44336', bgColor: '#FFEBEE' },
        { label: '高胆固醇', color: '#F44336', bgColor: '#FFEBEE' }
      ]
    },
    {
      id: '4', categoryId: 1,
      name: '菠菜 (水煮)', energy: 28,
      protein: 2.9, fat: 0.4, carbs: 3.6,
      tags: [
        { label: '低热量', color: AppTheme.PRIMARY_COLOR, bgColor: '#E8F5E9' },
        { label: '草酸溶出', color: '#FF9800', bgColor: '#FFF3E0' }
      ]
    },
    {
      id: '5', categoryId: 4,
      name: '全脂牛奶', energy: 62,
      protein: 3.3, fat: 3.6, carbs: 4.8,
      tags: [
        { label: '高钙', color: '#2196F3', bgColor: '#E3F2FD' },
        { label: '极低嘌呤', color: AppTheme.PRIMARY_COLOR, bgColor: '#E8F5E9' }
      ]
    }
  ];

  async aboutToAppear() {
    let context = getContext(this);
    await FoodDBHelper.init(context);
    let customFoods = await FoodDBHelper.getCustomFoods();
    if (customFoods.length > 0) {
      // 保持原有内置食物在后面，新添加的在前面
      this.mockFoods = [...customFoods, ...this.mockFoods];
    }
  }

  dialogController: CustomDialogController = new CustomDialogController({
    builder: AddFoodDialog({
      confirm: (name: string, energy: number) => {
        let newFood: FoodItem = {
          id: Date.now().toString(),
          categoryId: this.selectedCategoryIndex === 0 ? 1 : this.selectedCategoryIndex,
          name: name,
          energy: energy,
          protein: 0, fat: 0, carbs: 0,
          tags: [{ label: '自定义', color: AppTheme.PRIMARY_COLOR, bgColor: '#E8F5E9' }]
        };
        this.mockFoods.unshift(newFood);
        FoodDBHelper.insertFood(newFood);
      }
    }),
    alignment: DialogAlignment.Center,
    autoCancel: true
  })

  getFilteredFoods(): FoodItem[] {
    return this.mockFoods.filter(food => {
      let matchCategory = (this.selectedCategoryIndex === 0) || (food.categoryId === this.selectedCategoryIndex);
      let matchSearch = (this.searchQuery === '') || food.name.includes(this.searchQuery);
      return matchCategory && matchSearch;
    });
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      this.MainContent()

      if (this.compareList.length > 0) {
        Row() {
          Column() {
            Text(`已选 ${this.compareList.length} / 2 个食物`).fontSize(14).fontColor('#333333')
          }.layoutWeight(1).alignItems(HorizontalAlign.Start)

          Button('开始对比')
            .type(ButtonType.Capsule)
            .backgroundColor(this.compareList.length === 2 ? AppTheme.PRIMARY_COLOR : '#EAEAEA')
            .fontColor(this.compareList.length === 2 ? Color.White : '#999999')
            .fontSize(14)
            .height(36)
            .onClick(() => {
              if (this.compareList.length === 2) {
                router.pushUrl({
                  url: 'pages/FoodComparePage',
                  params: {
                    foodA: this.compareList[0],
                    foodB: this.compareList[1]
                  }
                });
              } else {
                promptAction.showToast({ message: '请选择两种食物进行对比' })
              }
            })
        }
        .width('90%')
        .padding(16)
        .backgroundColor(Color.White)
        .borderRadius(24)
        .shadow({ radius: 10, color: 'rgba(0,0,0,0.1)', offsetY: 4 })
        .margin({ bottom: 20 })
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder MainContent() {
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
          .onChange((value: string) => {
            this.searchQuery = value;
          })
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
        ForEach(this.getFilteredFoods(), (food: FoodItem) => {
          ListItem() {
            this.FoodCard(food)
          }
          .swipeAction({ end: this.DeleteButton(food) })
        }, (food: FoodItem) => food.id)
        
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
          .onClick(() => {
            this.dialogController.open();
          })
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

  deleteFood(food: FoodItem) {
    let index = this.mockFoods.findIndex(f => f.id === food.id);
    if (index >= 0) {
      this.mockFoods.splice(index, 1);
    }
    let cmpIndex = this.compareList.findIndex(f => f.id === food.id);
    if (cmpIndex >= 0) {
      this.compareList.splice(cmpIndex, 1);
    }
    FoodDBHelper.deleteFood(food.id);
  }

  @Builder
  DeleteButton(food: FoodItem) {
    Button('删除')
      .type(ButtonType.Normal)
      .width(72)
      .height('100%')
      .backgroundColor('#FF4D4F')
      .fontColor(Color.White)
      .borderRadius({ topRight: 16, bottomRight: 16 })
      .onClick(() => {
        promptAction.showDialog({
          title: `您确认删除 ${food.name}?`,
          buttons: [
            { text: '取消', color: '#333333' },
            { text: '确认删除', color: '#FF0000' }
          ]
        }).then((data) => {
          if (data.index === 1) {
            this.deleteFood(food);
          }
        })
      })
  }

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

  @Builder
  FoodCard(food: FoodItem) {
    Row() {
      // 文本与指标标签区域 (居左，占满剩余空间)
      Column({ space: 6 }) {
        Text(food.name).fontSize(16).fontWeight(FontWeight.Bold).fontColor('#333333')
        Text(`${food.energy} 千卡 / 100g`).fontSize(13).fontColor('#666666')
        
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
        Button(this.compareList.some(item => item.id === food.id) ? '已选' : '对比')
          .type(ButtonType.Capsule)
          .fontSize(12)
          .backgroundColor(this.compareList.some(item => item.id === food.id) ? AppTheme.PRIMARY_COLOR : '#F0F0F0')
          .fontColor(this.compareList.some(item => item.id === food.id) ? Color.White : '#333333')
          .width(60).height(28)
          .onClick(() => {
            let index = this.compareList.findIndex(item => item.id === food.id);
            if (index >= 0) {
              this.compareList.splice(index, 1);
            } else {
              if (this.compareList.length >= 2) {
                promptAction.showToast({ message: '最多只能对比两种食物' });
                return;
              }
              this.compareList.push(food);
            }
          })
      }.justifyContent(FlexAlign.Center).height(60)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .shadow({ radius: 8, color: 'rgba(0,0,0,0.03)', offsetY: 4 })
  }
}
