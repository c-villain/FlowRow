import SwiftUI

/// Layout component that arranges views in horizontal rows and wraps them into new lines when needed.
///
/// A ``FlowRow`` automatically wraps its content to a new row when it exceeds the available width,
/// similar to text wrapping or `flex-wrap` in CSS or `FlowRow` in Jetpack Compose. The number of lines can be limited via the ``maxLines`` parameter.
///
/// ```swift
/// FlowRow {
///     ForEach(tags, id: \.self) {
///         Text($0)
///     }
/// }
/// ```
///
/// ### Layout behavior
///
/// The layout automatically adapts to the container’s width, distributing child views across rows and wrapping as needed.
///
/// You can configure alignment:
/// - Use `horizontalAlignment:` to control how each row is aligned relative to the whole layout (e.g. `.leading`, `.center`, `.trailing`)
/// - Use `verticalAlignment:` to align views **within** a row (e.g. `.top`, `.center`, `.bottom`)
///
/// ```swift
/// FlowRow(
///     horizontalAlignment: .center,
///     verticalAlignment: .top
/// ) {
///     ...
/// }
/// ```
///
/// ### Customizing spacing
///
/// Use `horizontalSpacing:` and `verticalSpacing:` to define the spacing between items and between rows:
///
/// ```swift
/// FlowRow(
///     horizontalSpacing: 12,
///     verticalSpacing: 8
/// ) {
///     ...
/// }
/// ```
///
/// ### Limiting and observing lines
///
/// You can restrict the number of rendered lines using `maxLines:` and observe the actual line count with `lineCount:`:
///
/// ```swift
/// @State private var lineCount: Int = 0
///
/// FlowRow(maxLines: 2, lineCount: $lineCount) {
///     ...
/// }
/// ```
///
/// If the provided content is empty, ``FlowRow`` renders as `EmptyView` and does not occupy any space.


public struct FlowRow<Content: View>: View {
    
    private let horizontalSpacing: CGFloat
    private let verticalSpacing: CGFloat
    private let horizontalAlignment: HorizontalAlignment
    private let verticalAlignment: VerticalAlignment
    private let maxLines: Int
    @Binding private var lineCount: Int
    @ViewBuilder private let content: Content
    
    public init(
        horizontalSpacing: CGFloat = 8.0,
        verticalSpacing: CGFloat = 8.0,
        horizontalAlignment: HorizontalAlignment = .leading,
        verticalAlignment: VerticalAlignment = .center,
        maxLines: Int = .max,
        lineCount: Binding<Int> = .constant(1),
        @ViewBuilder content: () -> Content
    ) {
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing
        self.horizontalAlignment = horizontalAlignment
        self.verticalAlignment = verticalAlignment
        self.maxLines = maxLines
        self._lineCount = lineCount
        self.content = content()
    }
    
    public var body: some View {
        if #available(iOS 16, *) {
            FlowRowLayout(
                horizontalSpacing: horizontalSpacing,
                verticalSpacing: verticalSpacing,
                horizontalAlignment: horizontalAlignment,
                verticalAlignment: verticalAlignment,
                maxLines: maxLines,
                lineCount: $lineCount
            ) {
                content
            }
        } else {
            FlowRowLayoutBackported(
                horizontalSpacing: horizontalSpacing,
                verticalSpacing: verticalSpacing,
                horizontalAlignment: horizontalAlignment,
                verticalAlignment: verticalAlignment,
                maxLines: maxLines,
                lineCount: $lineCount
            ) {
                content
            }
        }
    }
}

internal struct FlowRowPreview: View {
    let initMaxLines: Int = 3
    @State private var maxLines: Int = 3
    @State private var lineCount: Int = 0
    @State private var isOn: Bool = false
    
    @ViewBuilder
    private func factory(_ name: String) -> some View {
        Toggle(isOn: $isOn) {
            Text(name)
        }
    }
    
    var body: some View {
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
            .lineLimit(1)
            .frame(maxWidth: .infinity)
            .clipped()
            .contentShape(Rectangle())
            .padding(16.0)
            
            Text("Всего линий занято: \(lineCount)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Button{
                withAnimation(.linear(duration: 0.2)) {
                    maxLines = (maxLines == Int.max) ? initMaxLines : Int.max
                }
            } label: {
                Text((maxLines == Int.max) ? "Показать только \(initMaxLines) строки" : "Показать все")
            }
            .padding(.bottom, 16.0)
        }
        .background(Color.yellow.opacity(0.2))
        .cornerRadius(8.0)
        .padding(16.0)
    }
}

struct FlowRow_Previews: PreviewProvider {
    static var previews: some View {
        FlowRowPreview()
    }
}
