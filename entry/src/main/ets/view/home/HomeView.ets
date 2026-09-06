@Component
export struct HomeView {
  build() {
    Column({ space: 15 }) {
      Text('今日概览').fontSize(24).fontWeight(FontWeight.Bold).margin({ top: 20 })
      
      // 核心展示：今日评分环形图、能量摄入进度条
      Text('[占位] 评分环形图 & 能量进度条').fontSize(16).fontColor(Color.Gray)
      
      // 数据面板：三大营养素供能比饼图、风险指标速览
      Text('[占位] 三大营养素饼图').fontSize(16).fontColor(Color.Gray)
      Text('[占位] 风险指标 (嘌呤/钠/胆固醇)').fontSize(16).fontColor(Color.Gray)
      
      // 互动模块：今日个性化健康建议卡片
      Text('[占位] 个性化健康建议卡片').fontSize(16).fontColor(Color.Gray)
    }
    .width('100%')
    .height('100%')
    .padding(20)
  }
}
