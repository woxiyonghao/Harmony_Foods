import { HomeView } from '../view/home/HomeView'
import { FoodLibraryView } from '../view/food/FoodLibraryView'
import { RecordView } from '../view/record/RecordView'
import { AnalysisView } from '../view/analysis/AnalysisView'
import { ProfileView } from '../view/profile/ProfileView'

@Entry
@Component
struct Index {
  @State currentIndex: number = 0;

  build() {
    Tabs({ barPosition: BarPosition.End }) {
      TabContent() {
        HomeView()
      }
      .tabBar('首页')

      TabContent() {
        FoodLibraryView()
      }
      .tabBar('食物库')

      TabContent() {
        RecordView()
      }
      .tabBar('记录')

      TabContent() {
        AnalysisView()
      }
      .tabBar('分析')

      TabContent() {
        ProfileView()
      }
      .tabBar('我的')
    }
    .onChange((index: number) => {
      this.currentIndex = index;
    })
    .width('100%')
    .height('100%')
  }
}
