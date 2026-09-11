import router from '@ohos.router';
import { HomeView } from '../view/home/HomeView'
import { FoodLibraryView } from '../view/food/FoodLibraryView'
import { RecordView } from '../view/record/RecordView'
import { AnalysisView } from '../view/analysis/AnalysisView'
import { ProfileView } from '../view/profile/ProfileView'
import { AppTheme } from '../common/constants/AppTheme'
import { FoodDBHelper } from '../common/utils/FoodDBHelper'

@Entry
@Component
struct Index {
  @State currentIndex: number = 0;
  @State refreshTrigger: number = 0;

  async aboutToAppear() {
    AppStorage.setOrCreate('profileVersion', 0);
    AppStorage.setOrCreate('foodLibraryVersion', 0);
    this.checkRouterParams();
    await this.checkAuth();
  }

  async onPageShow() {
    this.refreshTrigger++;
    this.checkRouterParams();
    let nextVersion = (AppStorage.get<number>('profileVersion') || 0) + 1;
    AppStorage.set<number>('profileVersion', nextVersion);
    let nextFoodVersion = (AppStorage.get<number>('foodLibraryVersion') || 0) + 1;
    AppStorage.set<number>('foodLibraryVersion', nextFoodVersion);
    await this.checkAuth();
  }

  async checkAuth() {
    let context = getContext(this);
    await FoodDBHelper.init(context);
    let uid = await FoodDBHelper.getCurrentUserId();
    if (!uid || uid.trim() === '') {
      try {
        router.replaceUrl({ url: 'pages/LoginPage' });
      } catch (e) {}
    }
  }

  checkRouterParams() {
    try {
      let params = router.getParams() as Record<string, Object>;
      if (params && params['targetIndex'] !== undefined) {
        this.currentIndex = params['targetIndex'] as number;
      }
    } catch (e) {}
  }

  @Builder TabBuilder(title: string, targetIndex: number, normalIcon: Resource, activeIcon: Resource) {
    Column() {
      Image(this.currentIndex === targetIndex ? activeIcon : normalIcon)
        .width(24)
        .height(24)
        .margin({ bottom: 4 })
      Text(title)
        .fontColor(this.currentIndex === targetIndex ? AppTheme.PRIMARY_COLOR : AppTheme.TEXT_COLOR_NORMAL)
        .fontSize(10)
        .fontWeight(this.currentIndex === targetIndex ? 500 : 400)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  build() {
    Tabs({ barPosition: BarPosition.End, index: this.currentIndex }) {
      TabContent() {
        HomeView({
          activeTab: this.currentIndex,
          refreshTrigger: this.refreshTrigger,
          onNavigateToRecord: () => {
            this.currentIndex = 2;
          }
        })
      }
      .tabBar(this.TabBuilder('首页', 0, $r('app.media.ic_tab_home_normal'), $r('app.media.ic_tab_home_active')))

      TabContent() {
        FoodLibraryView({
          activeTab: this.currentIndex,
          refreshTrigger: this.refreshTrigger
        })
      }
      .tabBar(this.TabBuilder('食物库', 1, $r('app.media.ic_tab_food_normal'), $r('app.media.ic_tab_food_active')))

      TabContent() {
        RecordView({
          activeTab: this.currentIndex,
          refreshTrigger: this.refreshTrigger
        })
      }
      .tabBar(this.TabBuilder('记录', 2, $r('app.media.ic_tab_record_normal'), $r('app.media.ic_tab_record_active')))

      TabContent() {
        AnalysisView({
          activeTab: this.currentIndex,
          onNavigateToRecord: () => {
            this.currentIndex = 2;
          }
        })
      }
      .tabBar(this.TabBuilder('分析', 3, $r('app.media.ic_tab_analysis_normal'), $r('app.media.ic_tab_analysis_active')))

      TabContent() {
        ProfileView({
          activeTab: this.currentIndex,
          refreshTrigger: this.refreshTrigger
        })
      }
      .tabBar(this.TabBuilder('我的', 4, $r('app.media.ic_tab_profile_normal'), $r('app.media.ic_tab_profile_active')))
    }
    .onChange((index: number) => {
      this.currentIndex = index;
    })
    .width('100%')
    .height('100%')
  }
}
