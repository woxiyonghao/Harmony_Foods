import { HomeView } from '../view/home/HomeView'
import { FoodLibraryView } from '../view/food/FoodLibraryView'
import { RecordView } from '../view/record/RecordView'
import { AnalysisView } from '../view/analysis/AnalysisView'
import { ProfileView } from '../view/profile/ProfileView'
import { AppTheme } from '../common/constants/AppTheme'

@Entry
@Component
struct Index {
  @State currentIndex: number = 0;

  @Builder TabBuilder(title: string, targetIndex: number, icon: Resource) {
    Column() {
      Image(icon)
        .width(24)
        .height(24)
        .fillColor(this.currentIndex === targetIndex ? AppTheme.PRIMARY_COLOR : AppTheme.TEXT_COLOR_NORMAL)
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
          onNavigateToRecord: () => {
            this.currentIndex = 2;
          }
        })
      }
      .tabBar(this.TabBuilder('首页', 0, $r('app.media.ic_home')))

      TabContent() {
        FoodLibraryView({ activeTab: this.currentIndex })
      }
      .tabBar(this.TabBuilder('食物库', 1, $r('app.media.ic_food')))

      TabContent() {
        RecordView({ activeTab: this.currentIndex })
      }
      .tabBar(this.TabBuilder('记录', 2, $r('app.media.ic_record')))

      TabContent() {
        AnalysisView({
          activeTab: this.currentIndex,
          onNavigateToRecord: () => {
            this.currentIndex = 2;
          }
        })
      }
      .tabBar(this.TabBuilder('分析', 3, $r('app.media.ic_analysis')))

      TabContent() {
        ProfileView({ activeTab: this.currentIndex })
      }
      .tabBar(this.TabBuilder('我的', 4, $r('app.media.ic_profile')))
    }
    .onChange((index: number) => {
      this.currentIndex = index;
    })
    .width('100%')
    .height('100%')
  }
}
