import SwiftUI
import FlowRow

struct ChipsView: View {
    let initMaxLines: Int = 3
    @State private var maxLines: Int = 3
    @State private var lineCount: Int = 0
    @State private var isOn: Bool = false
    
    @ViewBuilder
    private func factory(_ name: String) -> some View {
        HStack(spacing: 6) {
            Text(name)
                .lineLimit(1)
                .frame(maxWidth: .infinity)
            Button {
            } label: {
                Image(systemName: "xmark")
                    .font(.caption)
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 12)
        .background(
            Capsule()
                .strokeBorder(
                    Color.black,
                    style: StrokeStyle(
                        lineWidth: 2
                    )
                )
                .background(Capsule().fill(.white))
        )
    }
    
    var body: some View {
        let animation: Animation = .linear
        
        VStack {
            Text("Облако тэгов")
                .padding(.top, 16.0)
            FlowRow(
                horizontalSpacing: 8.0,
                verticalSpacing: 8.0,
                maxLines: maxLines,
                lineCount: $lineCount
            ) {
                factory("Dr.-Ing. h.c. F. Porsche AG")
                factory("BMW")
                factory("Mercedes")
                factory("Audi")
                factory("KIA")
                factory("Toyota")
                factory("Honda")
                factory("Ford")
                factory("Renault")
                factory("Nissan")
                factory("Bayerische Motoren Werke Aktiengesellschaft (AG)")
            }
            .animation(animation)
            .lineLimit(1)
            .frame(maxWidth: .infinity)
            .clipped()
            .contentShape(Rectangle())
            .padding(16.0)
            
            Text("Всего линий занято: \(lineCount)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Button{
                withAnimation(animation) {
                    maxLines = (maxLines == Int.max) ? initMaxLines : Int.max
                }
            } label: {
                Text((maxLines == Int.max) ? "Показать только \(initMaxLines) строки" : "Показать все")
            }
            .padding(.bottom, 16.0)
        }
        .background(Color.yellow.opacity(0.2))
        .cornerRadius(16.0)
        .padding(16.0)
    }
}

struct ChipsView_Previews: PreviewProvider {
    static var previews: some View {
        ChipsView()
    }
}
