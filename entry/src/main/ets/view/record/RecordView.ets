import promptAction from '@ohos.promptAction'
import { AppTheme } from '../../common/constants/AppTheme'
import { DateNavigator } from '../../common/components/DateNavigator'
import { DateHelper } from '../../common/utils/DateHelper'
import { FoodDBHelper } from '../../common/utils/FoodDBHelper'
import { FoodItem, DietRecordItem, FavoriteFoodItem } from '../../common/models/FoodItem'
import { NutritionCalculator } from '../../common/utils/NutritionCalculator'

export interface MealSlot {
  title: string;
  icon: Resource;
  foods: DietRecordItem[];
  suggestedEnergy?: string;
}

// 1. 搜索添加食物弹窗
@CustomDialog
export struct SearchAddFoodDialog {
  controller: CustomDialogController
  @State selectedMeal: string = '早餐'
  @State searchQuery: string = ''
  @State selectedFood: FoodItem | null = null
  @State weightInput: string = '100'
  @State allFoods: FoodItem[] = []
  
  onConfirm: (meal: string, name: string, amount: string, energy: number, protein?: number, fat?: number, carbs?: number) => void = () => {}

  private meals: string[] = ['早餐', '午餐', '晚餐', '加餐']
  private quickWeights: number[] = [50, 100, 150, 200, 250]

  async aboutToAppear() {
    this.allFoods = await FoodDBHelper.getAllFoods();
    if (this.allFoods.length > 0 && !this.selectedFood) {
      this.selectedFood = this.allFoods[0];
    }
  }

  getFilteredFoods(): FoodItem[] {
    if (this.searchQuery.trim() === '') {
      return this.allFoods;
    }
    return this.allFoods.filter((f: FoodItem) => f.name.includes(this.searchQuery.trim()));
  }

  calculateEnergy(): number {
    if (!this.selectedFood) return 0;
    let w = parseInt(this.weightInput) || 0;
    return Math.round((this.selectedFood.energy * w) / 100);
  }

  build() {
    Column({ space: 14 }) {
      // 头部标题与餐段切换
      Row() {
        Text('添加食物').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#333333')
        Blank()
        Row({ space: 6 }) {
          ForEach(this.meals, (m: string) => {
            Text(m)
              .fontSize(12)
              .fontColor(this.selectedMeal === m ? Color.White : '#666666')
              .backgroundColor(this.selectedMeal === m ? AppTheme.PRIMARY_COLOR : '#F0F0F0')
              .padding({ left: 10, right: 10, top: 5, bottom: 5 })
              .borderRadius(12)
              .onClick(() => {
                this.selectedMeal = m;
              })
          })
        }
      }.width('100%')

      // 搜索框
      Search({ value: this.searchQuery, placeholder: '搜索食物 (如苹果、牛奶、米饭)' })
        .searchButton('搜索')
        .width('100%')
        .height(38)
        .backgroundColor('#F7F8FA')
        .onChange((val: string) => {
          this.searchQuery = val;
        })

      // 候选食物列表
      List({ space: 8 }) {
        ForEach(this.getFilteredFoods(), (food: FoodItem) => {
          ListItem() {
            Row() {
              Column({ space: 2 }) {
                Text(food.name).fontSize(14).fontWeight(FontWeight.Medium).fontColor('#333333')
                Text(`${food.energy} 千卡 / 100g`).fontSize(11).fontColor('#888888')
              }.alignItems(HorizontalAlign.Start).layoutWeight(1)

              if (this.selectedFood && this.selectedFood.id === food.id) {
                Text('已选')
                  .fontSize(12)
                  .fontColor(AppTheme.PRIMARY_COLOR)
                  .fontWeight(FontWeight.Bold)
              }
            }
            .width('100%')
            .padding({ left: 12, right: 12, top: 10, bottom: 10 })
            .backgroundColor(this.selectedFood && this.selectedFood.id === food.id ? '#E8F5E9' : '#FFFFFF')
            .borderRadius(8)
            .border({
              width: 1,
              color: this.selectedFood && this.selectedFood.id === food.id ? AppTheme.PRIMARY_COLOR : '#EEEEEE'
            })
            .onClick(() => {
              this.selectedFood = food;
            })
          }
        })
      }
      .width('100%')
      .height(130)

      // 份量设置区域
      if (this.selectedFood) {
        Column({ space: 8 }) {
          Row() {
            Text('摄入份量 (克/毫升):').fontSize(13).fontColor('#666666')
            Blank()
            TextInput({ text: this.weightInput })
              .type(InputType.Number)
              .width(80)
              .height(32)
              .fontSize(14)
              .textAlign(TextAlign.Center)
              .onChange((val: string) => {
                this.weightInput = val;
              })
            Text('g/ml').fontSize(13).fontColor('#666666').margin({ left: 4 })
          }.width('100%')

          // 快速选择克重
          Row({ space: 8 }) {
            ForEach(this.quickWeights, (w: number) => {
              Text(`${w}g`)
                .fontSize(11)
                .fontColor(this.weightInput === `${w}` ? AppTheme.PRIMARY_COLOR : '#666666')
                .backgroundColor(this.weightInput === `${w}` ? '#E8F5E9' : '#F5F5F5')
                .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                .borderRadius(8)
                .onClick(() => {
                  this.weightInput = `${w}`;
                })
            })
          }

          // 估算热量汇总
          Row() {
            Text('预计摄入热量: ').fontSize(13).fontColor('#666666')
            Text(`${this.calculateEnergy()} 千卡`)
              .fontSize(15)
              .fontWeight(FontWeight.Bold)
              .fontColor(AppTheme.PRIMARY_COLOR)
          }.width('100%').margin({ top: 4 })
        }
        .width('100%')
        .padding(10)
        .backgroundColor('#F9FBF9')
        .borderRadius(10)
      }

      // 底部按钮
      Row({ space: 12 }) {
        Button('取消')
          .onClick(() => {
            this.controller.close();
          })
          .backgroundColor('#EAEAEA')
          .fontColor('#333333')
          .layoutWeight(1)

        Button('确定添加')
          .onClick(() => {
            if (!this.selectedFood) {
              promptAction.showToast({ message: '请选择食物' });
              return;
            }
            let w = parseInt(this.weightInput);
            if (!w || w <= 0) {
              promptAction.showToast({ message: '请输入有效份量' });
              return;
            }
            let energy = this.calculateEnergy();
            let prot = Math.round(((this.selectedFood.protein || 0) * w / 100) * 10) / 10;
            let ft = Math.round(((this.selectedFood.fat || 0) * w / 100) * 10) / 10;
            let cb = Math.round(((this.selectedFood.carbs || 0) * w / 100) * 10) / 10;
            this.onConfirm(this.selectedMeal, this.selectedFood.name, `${w}g`, energy, prot, ft, cb);
            this.controller.close();
          })
          .backgroundColor(AppTheme.PRIMARY_COLOR)
          .fontColor(Color.White)
          .layoutWeight(1)
      }.width('100%').margin({ top: 6 })
    }
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .width('92%')
  }
}

// 2. 最近吃过弹窗
@CustomDialog
export struct RecentFoodsDialog {
  controller: CustomDialogController
  @State selectedMeal: string = '早餐'
  @State recentList: DietRecordItem[] = []
  onAdd: (meal: string, name: string, amount: string, energy: number) => void = () => {}

  private meals: string[] = ['早餐', '午餐', '晚餐', '加餐']

  async aboutToAppear() {
    this.recentList = await FoodDBHelper.getRecentDietFoods(12);
  }

  build() {
    Column({ space: 14 }) {
      Row() {
        Text('最近吃过').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#333333')
        Blank()
        Row({ space: 6 }) {
          ForEach(this.meals, (m: string) => {
            Text(m)
              .fontSize(12)
              .fontColor(this.selectedMeal === m ? Color.White : '#666666')
              .backgroundColor(this.selectedMeal === m ? '#FF9800' : '#F0F0F0')
              .padding({ left: 10, right: 10, top: 5, bottom: 5 })
              .borderRadius(12)
              .onClick(() => {
                this.selectedMeal = m;
              })
          })
        }
      }.width('100%')

      if (this.recentList.length === 0) {
        Column({ space: 8 }) {
          Text('暂无历史记录').fontSize(14).fontColor('#999999')
          Text('记录过的食物会自动汇总至此处').fontSize(12).fontColor('#CCCCCC')
        }
        .width('100%')
        .padding({ top: 30, bottom: 30 })
        .alignItems(HorizontalAlign.Center)
      } else {
        List({ space: 10 }) {
          ForEach(this.recentList, (item: DietRecordItem) => {
            ListItem() {
              Row() {
                Column({ space: 3 }) {
                  Text(item.foodName).fontSize(14).fontWeight(FontWeight.Medium).fontColor('#333333')
                  Text(`${item.amount} · ${item.energy} 千卡`).fontSize(12).fontColor('#888888')
                }.alignItems(HorizontalAlign.Start).layoutWeight(1)

                Button('+ 添加')
                  .type(ButtonType.Capsule)
                  .fontSize(12)
                  .backgroundColor('#FFF3E0')
                  .fontColor('#FF9800')
                  .height(28)
                  .onClick(() => {
                    this.onAdd(this.selectedMeal, item.foodName, item.amount, item.energy);
                  })
              }
              .width('100%')
              .padding(12)
              .backgroundColor('#FAFAFA')
              .borderRadius(10)
            }
          })
        }
        .width('100%')
        .height(220)
      }

      Button('完成')
        .width('100%')
        .backgroundColor('#FF9800')
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

// 3. 我的收藏弹窗
@CustomDialog
export struct FavoriteFoodsDialog {
  controller: CustomDialogController
  @State selectedMeal: string = '早餐'
  @State favorites: FavoriteFoodItem[] = []
  onAdd: (meal: string, name: string, amount: string, energy: number) => void = () => {}

  private meals: string[] = ['早餐', '午餐', '晚餐', '加餐']

  async aboutToAppear() {
    this.favorites = await FoodDBHelper.getFavoriteFoods();
  }

  build() {
    Column({ space: 14 }) {
      Row() {
        Text('我的收藏').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#333333')
        Blank()
        Row({ space: 6 }) {
          ForEach(this.meals, (m: string) => {
            Text(m)
              .fontSize(12)
              .fontColor(this.selectedMeal === m ? Color.White : '#666666')
              .backgroundColor(this.selectedMeal === m ? '#E91E63' : '#F0F0F0')
              .padding({ left: 10, right: 10, top: 5, bottom: 5 })
              .borderRadius(12)
              .onClick(() => {
                this.selectedMeal = m;
              })
          })
        }
      }.width('100%')

      if (this.favorites.length === 0) {
        Column({ space: 8 }) {
          Text('暂无收藏食物').fontSize(14).fontColor('#999999')
          Text('常吃的美味可一键收藏在此快速记录').fontSize(12).fontColor('#CCCCCC')
        }
        .width('100%')
        .padding({ top: 30, bottom: 30 })
        .alignItems(HorizontalAlign.Center)
      } else {
        List({ space: 10 }) {
          ForEach(this.favorites, (fav: FavoriteFoodItem) => {
            ListItem() {
              Row() {
                Column({ space: 3 }) {
                  Text(fav.name).fontSize(14).fontWeight(FontWeight.Medium).fontColor('#333333')
                  Text(`${fav.defaultAmount} · ${fav.energy} 千卡`).fontSize(12).fontColor('#888888')
                }.alignItems(HorizontalAlign.Start).layoutWeight(1)

                Button('+ 添加')
                  .type(ButtonType.Capsule)
                  .fontSize(12)
                  .backgroundColor('#FCE4EC')
                  .fontColor('#E91E63')
                  .height(28)
                  .onClick(() => {
                    this.onAdd(this.selectedMeal, fav.name, fav.defaultAmount, fav.energy);
                  })
              }
              .width('100%')
              .padding(12)
              .backgroundColor('#FAFAFA')
              .borderRadius(10)
            }
          })
        }
        .width('100%')
        .height(220)
      }

      Button('完成')
        .width('100%')
        .backgroundColor('#E91E63')
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

// 4. 快捷录入弹窗
@CustomDialog
export struct QuickEntryDialog {
  controller: CustomDialogController
  @State selectedMeal: string = '早餐'
  @State foodName: string = ''
  @State amount: string = '100g'
  @State energy: string = ''
  onConfirm: (meal: string, name: string, amount: string, energy: number) => void = () => {}

  private meals: string[] = ['早餐', '午餐', '晚餐', '加餐']

  build() {
    Column({ space: 14 }) {
      Text('快捷录入').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#333333')

      // 餐段选择
      Row({ space: 8 }) {
        ForEach(this.meals, (m: string) => {
          Text(m)
            .fontSize(13)
            .fontColor(this.selectedMeal === m ? Color.White : '#666666')
            .backgroundColor(this.selectedMeal === m ? AppTheme.PRIMARY_COLOR : '#F0F0F0')
            .padding({ left: 14, right: 14, top: 6, bottom: 6 })
            .borderRadius(12)
            .onClick(() => {
              this.selectedMeal = m;
            })
        })
      }.width('100%').justifyContent(FlexAlign.SpaceBetween)

      TextInput({ placeholder: '食物名称 (如: 煎饼果子、牛肉面)' })
        .onChange((val: string) => { this.foodName = val; })
        .height(44)
        .backgroundColor('#F7F8FA')

      TextInput({ placeholder: '份量 (如: 1个、1碗、150g)' })
        .onChange((val: string) => { this.amount = val; })
        .height(44)
        .backgroundColor('#F7F8FA')

      TextInput({ placeholder: '估算热量 (千卡，如: 320)' })
        .type(InputType.Number)
        .onChange((val: string) => { this.energy = val; })
        .height(44)
        .backgroundColor('#F7F8FA')

      Row({ space: 12 }) {
        Button('取消')
          .onClick(() => { this.controller.close(); })
          .backgroundColor('#EAEAEA')
          .fontColor('#333333')
          .layoutWeight(1)

        Button('确定添加')
          .onClick(() => {
            if (this.foodName.trim() === '') {
              promptAction.showToast({ message: '请输入食物名称' });
              return;
            }
            let cal = parseInt(this.energy);
            if (!cal || cal < 0) {
              promptAction.showToast({ message: '请输入有效估算热量' });
              return;
            }
            let amt = this.amount.trim() === '' ? '1份' : this.amount.trim();
            this.onConfirm(this.selectedMeal, this.foodName.trim(), amt, cal);
            this.controller.close();
          })
          .backgroundColor(AppTheme.PRIMARY_COLOR)
          .fontColor(Color.White)
          .layoutWeight(1)
      }.width('100%').margin({ top: 8 })
    }
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .width('92%')
  }
}

@Component
export struct RecordView {
  @State selectedDate: Date = new Date();
  @State dateText: string = '9月6日 今天';
  @State totalDailyEnergy: number = 0;
  @State meals: MealSlot[] = [
    {
      title: '早餐',
      icon: $r('app.media.ic_breakfast'),
      suggestedEnergy: '推荐 400-600',
      foods: []
    },
    {
      title: '午餐',
      icon: $r('app.media.ic_lunch'),
      suggestedEnergy: '推荐 600-800',
      foods: []
    },
    {
      title: '晚餐',
      icon: $r('app.media.ic_dinner'),
      suggestedEnergy: '推荐 400-600',
      foods: []
    },
    {
      title: '加餐',
      icon: $r('app.media.ic_snack'),
      foods: []
    }
  ];

  searchAddController: CustomDialogController | null = null;
  recentController: CustomDialogController | null = null;
  favoriteController: CustomDialogController | null = null;
  quickEntryController: CustomDialogController | null = null;

  async aboutToAppear() {
    let context = getContext(this);
    await FoodDBHelper.init(context);
    await this.loadRecordsForCurrentDate();
  }

  async loadRecordsForCurrentDate() {
    this.dateText = DateHelper.formatDisplayDate(this.selectedDate);
    let dateKey = DateHelper.formatDateKey(this.selectedDate);
    let allDayRecords = await FoodDBHelper.getDietRecordsByDate(dateKey);
    
    let total = 0;
    for (let r of allDayRecords) {
      total += r.energy;
    }
    this.totalDailyEnergy = total;

    this.meals = [
      {
        title: '早餐',
        icon: $r('app.media.ic_breakfast'),
        suggestedEnergy: '推荐 400-600',
        foods: allDayRecords.filter((r: DietRecordItem) => r.mealType === '早餐')
      },
      {
        title: '午餐',
        icon: $r('app.media.ic_lunch'),
        suggestedEnergy: '推荐 600-800',
        foods: allDayRecords.filter((r: DietRecordItem) => r.mealType === '午餐')
      },
      {
        title: '晚餐',
        icon: $r('app.media.ic_dinner'),
        suggestedEnergy: '推荐 400-600',
        foods: allDayRecords.filter((r: DietRecordItem) => r.mealType === '晚餐')
      },
      {
        title: '加餐',
        icon: $r('app.media.ic_snack'),
        foods: allDayRecords.filter((r: DietRecordItem) => r.mealType === '加餐')
      }
    ];
  }

  async addRecord(mealType: string, foodName: string, amount: string, energy: number, protein?: number, fat?: number, carbs?: number) {
    let dateKey = DateHelper.formatDateKey(this.selectedDate);
    let prot = protein;
    let ft = fat;
    let cb = carbs;
    if (prot === undefined || ft === undefined || cb === undefined || (prot === 0 && ft === 0 && cb === 0)) {
      let tempRec: DietRecordItem = {
        id: '',
        date: dateKey,
        mealType: mealType,
        foodName: foodName,
        amount: amount,
        energy: energy,
        createdAt: 0
      };
      let calced = NutritionCalculator.calculateRecordNutrients(tempRec);
      prot = calced.protein;
      ft = calced.fat;
      cb = calced.carbs;
    }

    let record: DietRecordItem = {
      id: Date.now().toString(),
      date: dateKey,
      mealType: mealType,
      foodName: foodName,
      amount: amount,
      energy: energy,
      protein: prot,
      fat: ft,
      carbs: cb,
      createdAt: Date.now()
    };
    await FoodDBHelper.insertDietRecord(record);
    try {
      promptAction.showToast({ message: `已成功记录：${foodName} (${energy}千卡)` });
    } catch (err) {
      console.error('RecordView', 'showToast error', err);
    }
    await this.loadRecordsForCurrentDate();
  }

  deleteRecord(food: DietRecordItem) {
    try {
      promptAction.showDialog({
        title: '确认删除记录?',
        message: `${food.foodName} (${food.amount}) - ${food.energy}千卡`,
        buttons: [
          { text: '取消', color: '#666666' },
          { text: '删除', color: '#FF4D4F' }
        ]
      }).then(async (result) => {
        if (result.index === 1) {
          await FoodDBHelper.deleteDietRecord(food.id);
          try {
            promptAction.showToast({ message: '已删除' });
          } catch (err) {
            console.error('RecordView', 'showToast error', err);
          }
          await this.loadRecordsForCurrentDate();
        }
      });
    } catch (err) {
      console.error('RecordView', 'showDialog error', err);
    }
  }

  openSearchAddDialog(initialMeal: string = '早餐') {
    this.searchAddController = new CustomDialogController({
      builder: SearchAddFoodDialog({
        selectedMeal: initialMeal,
        onConfirm: (meal: string, name: string, amount: string, energy: number, protein?: number, fat?: number, carbs?: number) => {
          this.addRecord(meal, name, amount, energy, protein, fat, carbs);
        }
      }),
      alignment: DialogAlignment.Center,
      autoCancel: true
    });
    this.searchAddController.open();
  }

  openRecentDialog(initialMeal: string = '早餐') {
    this.recentController = new CustomDialogController({
      builder: RecentFoodsDialog({
        selectedMeal: initialMeal,
        onAdd: (meal: string, name: string, amount: string, energy: number) => {
          this.addRecord(meal, name, amount, energy);
        }
      }),
      alignment: DialogAlignment.Center,
      autoCancel: true
    });
    this.recentController.open();
  }

  openFavoriteDialog(initialMeal: string = '早餐') {
    this.favoriteController = new CustomDialogController({
      builder: FavoriteFoodsDialog({
        selectedMeal: initialMeal,
        onAdd: (meal: string, name: string, amount: string, energy: number) => {
          this.addRecord(meal, name, amount, energy);
        }
      }),
      alignment: DialogAlignment.Center,
      autoCancel: true
    });
    this.favoriteController.open();
  }

  openQuickEntryDialog(initialMeal: string = '早餐') {
    this.quickEntryController = new CustomDialogController({
      builder: QuickEntryDialog({
        selectedMeal: initialMeal,
        onConfirm: (meal: string, name: string, amount: string, energy: number) => {
          this.addRecord(meal, name, amount, energy);
        }
      }),
      alignment: DialogAlignment.Center,
      autoCancel: true
    });
    this.quickEntryController.open();
  }

  getMealEnergy(foods: DietRecordItem[]): number {
    let total = 0;
    for (let f of foods) {
      total += f.energy;
    }
    return total;
  }

  build() {
    Column() {
      // 1. 顶部日期导航与今日汇总
      DateNavigator({
        dateText: this.dateText,
        subText: `总摄入 ${this.totalDailyEnergy} / 2100 千卡`,
        onPrevClick: () => {
          this.selectedDate = DateHelper.addDays(this.selectedDate, -1);
          this.loadRecordsForCurrentDate();
        },
        onNextClick: () => {
          this.selectedDate = DateHelper.addDays(this.selectedDate, 1);
          this.loadRecordsForCurrentDate();
        },
        onDateClick: () => {
          DatePickerDialog.show({
            selected: this.selectedDate,
            onAccept: (value: DatePickerResult) => {
              if (value.year !== undefined && value.month !== undefined && value.day !== undefined) {
                this.selectedDate = new Date(value.year, value.month, value.day);
                this.loadRecordsForCurrentDate();
              }
            }
          });
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
          
          Blank().height(20)
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
      this.QuickActionButton($r('app.media.ic_search'), '搜索添加', '#2196F3', () => {
        this.openSearchAddDialog('早餐');
      })
      this.QuickActionButton($r('app.media.ic_recent'), '最近吃过', '#FF9800', () => {
        this.openRecentDialog('早餐');
      })
      this.QuickActionButton($r('app.media.ic_favorite'), '我的收藏', '#E91E63', () => {
        this.openFavoriteDialog('早餐');
      })
      this.QuickActionButton($r('app.media.ic_flash'), '快捷录入', AppTheme.PRIMARY_COLOR, () => {
        this.openQuickEntryDialog('早餐');
      })
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder
  QuickActionButton(icon: Resource, text: string, iconColor: string, onClickAction: () => void) {
    Column({ space: 8 }) {
      Image(icon).width(24).height(24).fillColor(iconColor)
      Text(text).fontSize(12).fontColor('#555555').fontWeight(FontWeight.Medium)
    }
    .layoutWeight(1)
    .padding({ top: 14, bottom: 14 })
    .backgroundColor(Color.White)
    .borderRadius(12)
    .shadow({ radius: 8, color: 'rgba(0,0,0,0.03)', offsetY: 4 })
    .onClick(onClickAction)
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
          .onClick(() => {
            this.openSearchAddDialog(meal.title);
          })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      
      // 食物列表详情
      if (meal.foods.length > 0) {
        Column() {
          ForEach(meal.foods, (food: DietRecordItem, index: number) => {
            Row() {
              Column() {
                Text(food.foodName).fontSize(14).fontColor('#333333').fontWeight(FontWeight.Medium)
                Text(food.amount).fontSize(12).fontColor('#999999').margin({ top: 4 })
              }.alignItems(HorizontalAlign.Start).layoutWeight(1)
              
              Text(`${food.energy} 千卡`).fontSize(14).fontColor('#555555').margin({ right: 10 })

              // 删除按钮
              Button({ type: ButtonType.Circle }) {
                Text('×').fontSize(16).fontColor('#FF4D4F').fontWeight(FontWeight.Bold)
              }
              .width(22).height(22)
              .backgroundColor('#FFF0F0')
              .onClick(() => {
                this.deleteRecord(food);
              })
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
        // 空状态，点击也可添加
        Row() {
          Text(`点击此处添加${meal.title}`).fontSize(12).fontColor('#CCCCCC')
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .padding({ top: 20, bottom: 8 })
        .onClick(() => {
          this.openSearchAddDialog(meal.title);
        })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .shadow({ radius: 8, color: 'rgba(0,0,0,0.03)', offsetY: 4 })
  }
}

