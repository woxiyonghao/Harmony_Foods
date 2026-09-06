@Component
export struct ProfileView {
  build() {
    Column({ space: 15 }) {
      Text('我的').fontSize(24).fontWeight(FontWeight.Bold).margin({ top: 20 })
      
      // 健康档案
      Text('[占位] 健康档案 (身体数据/健康目标/特殊标签)').fontSize(16).fontColor(Color.Gray)
      
      // 核心设置
      Text('[占位] 评分维度权重自定义').fontSize(16).fontColor(Color.Gray)
      
      // 数据管理
      Text('[占位] 数据备份与恢复 (JSON/CSV)').fontSize(16).fontColor(Color.Gray)
      Text('[占位] 生物识别解锁设置').fontSize(16).fontColor(Color.Gray)
    }
    .width('100%')
    .height('100%')
    .padding(20)
  }
}
