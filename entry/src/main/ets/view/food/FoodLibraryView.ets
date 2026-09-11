import router from '@ohos.router'
import promptAction from '@ohos.promptAction'
import { AppTheme } from '../../common/constants/AppTheme'
import { FoodDBHelper } from '../../common/utils/FoodDBHelper'

import { FoodTag, FoodItem } from '../../common/models/FoodItem'
export { FoodTag, FoodItem }

export interface Category {
  name: string;
  icon?: Resource;
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
        .fontColor('#111827')
        .placeholderColor('#9CA3AF')
        .backgroundColor('#F9FAFB')
        .borderRadius(12)
        .border({ width: 1, color: '#E5E7EB' })
        .caretColor(AppTheme.PRIMARY_COLOR)
        .padding({ left: 14, right: 14 })
        .onChange((value: string) => { this.foodName = value; })
        .height(48)
        
      TextInput({ placeholder: '热量 (千卡/100g)' })
        .type(InputType.Number)
        .fontColor('#111827')
        .placeholderColor('#9CA3AF')
        .backgroundColor('#F9FAFB')
        .borderRadius(12)
        .border({ width: 1, color: '#E5E7EB' })
        .caretColor(AppTheme.PRIMARY_COLOR)
        .padding({ left: 14, right: 14 })
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
  @Prop @Watch('onActiveTabChange') activeTab: number = 0;
  @Prop @Watch('onRefreshTriggerChange') refreshTrigger: number = 0;
  @StorageLink('foodLibraryVersion') @Watch('onFoodLibraryVersionChange') libraryVersion: number = 0;
  @State selectedCategoryIndex: number = 0;
  @State searchQuery: string = '';
  @State compareList: FoodItem[] = [];
  @State favoriteNames: string[] = [];
  @State mockFoods: FoodItem[] = [];

  private categories: Category[] = [
    { name: '全部' },
    { name: '蔬菜类', icon: $r('app.media.ic_veg') },
    { name: '水果类', icon: $r('app.media.ic_fruit') },
    { name: '肉禽类', icon: $r('app.media.ic_meat') },
    { name: '饮品类', icon: $r('app.media.ic_drink') },
    { name: '中式菜肴' }
  ];

  async aboutToAppear() {
    let context = getContext(this);
    await FoodDBHelper.init(context);
    await this.loadFoods();
    await this.refreshFavorites();
  }

  async loadFoods() {
    let foods = await FoodDBHelper.getLibraryFoods();
    this.mockFoods = [...foods];
  }

  async onFoodLibraryVersionChange() {
    await this.loadFoods();
  }

  async onRefreshTriggerChange() {
    await this.loadFoods();
    await this.refreshFavorites();
  }

  async onActiveTabChange() {
    if (this.activeTab === 1) {
      await this.loadFoods();
      await this.refreshFavorites();
    }
  }

  async refreshFavorites() {
    this.favoriteNames = await FoodDBHelper.getFavoriteNames();
  }

  dialogController: CustomDialogController = new CustomDialogController({
    builder: AddFoodDialog({
      confirm: async (name: string, energy: number) => {
        let newFood: FoodItem = {
          id: Date.now().toString(),
          categoryId: this.selectedCategoryIndex === 0 ? 1 : this.selectedCategoryIndex,
          name: name,
          energy: energy,
          protein: 0, fat: 0, carbs: 0,
          tags: [{ label: '自定义', color: AppTheme.PRIMARY_COLOR, bgColor: '#E8F5E9' }]
        };
        await FoodDBHelper.insertFood(newFood);
        await this.loadFoods();
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
          .fontColor('#111827')
          .placeholderColor('#9CA3AF')
          .border({ width: 1, color: '#E5E7EB', radius: 10 })
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

  async deleteFood(food: FoodItem) {
    let index = this.mockFoods.findIndex(f => f.id === food.id);
    if (index >= 0) {
      this.mockFoods.splice(index, 1);
    }
    let cmpIndex = this.compareList.findIndex(f => f.id === food.id);
    if (cmpIndex >= 0) {
      this.compareList.splice(cmpIndex, 1);
    }
    await FoodDBHelper.deleteFood(food.id);
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
        Row({ space: 8 }) {
          Text(food.name).fontSize(16).fontWeight(FontWeight.Bold).fontColor('#333333')
          
          // 收藏星星按钮
          Image(this.favoriteNames.indexOf(food.name) !== -1 ? $r('app.media.ic_favorite_active') : $r('app.media.ic_favorite_inactive'))
            .width(18)
            .height(18)
            .onClick(async () => {
              let newState = await FoodDBHelper.toggleFavorite(food.name, food.energy, '100g', food.categoryId);
              this.favoriteNames = await FoodDBHelper.getFavoriteNames();
              try {
                promptAction.showToast({ message: newState ? `已收藏：${food.name}` : `已取消收藏：${food.name}` });
              } catch (e) {}
            })
        }.alignItems(VerticalAlign.Center)

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
