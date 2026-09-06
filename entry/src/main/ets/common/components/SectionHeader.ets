@Component
export struct SectionHeader {
  @Prop title: string = '';
  
  build() {
    Row() {
      Text(this.title)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
    }
    .width('100%')
    .padding({ top: 10, bottom: 10 })
  }
}
