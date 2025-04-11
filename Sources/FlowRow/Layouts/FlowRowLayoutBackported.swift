import SwiftUI

/// Кастомный лейаут для FlowRow в реализации для iOS < 16
/// - Автоматически рассчитывает ширину каждого чипса и переносит на новую строку, если не хватает места.
/// - Ориентируется на ширину контейнера, в котором находится FlowRowLayoutBackported.
/// - Ограничивает отображаемое количество строк параметром `maxLines` (но реально располагает все).
/// - Записывает общее количество строк во внешнее @Binding lineCount (включая те, которые не видны из-за лимита).
///
struct FlowRowLayoutBackported<Content: View>: View {
    let horizontalSpacing: CGFloat
    let verticalSpacing: CGFloat
    let horizontalAlignment: HorizontalAlignment
    let verticalAlignment: VerticalAlignment
    let maxLines: Int
    @Binding var lineCount: Int
    
    private let content: () -> Content
    
    init(
        horizontalSpacing: CGFloat = 8,
        verticalSpacing: CGFloat = 8,
        horizontalAlignment: HorizontalAlignment = .leading,
        verticalAlignment: VerticalAlignment = .center,
        maxLines: Int = .max,
        lineCount: Binding<Int> = .constant(1),
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing
        self.horizontalAlignment = horizontalAlignment
        self.verticalAlignment = verticalAlignment
        self.maxLines = maxLines
        self._lineCount = lineCount
        self.content = content
    }
    
    var body: some View {
        _VariadicView.Tree(
            FlowWrapper(
                horizontalSpacing: horizontalSpacing,
                verticalSpacing: verticalSpacing,
                horizontalAlignment: horizontalAlignment,
                verticalAlignment: verticalAlignment,
                maxLines: maxLines,
                lineCount: $lineCount
            )
        ) {
            content()
        }
    }
    
    // MARK: - Приватный обработчик
    
    private struct FlowWrapper: _VariadicView_UnaryViewRoot {
        
        @Environment(\.animation) private var animation: Animation?
        
        let horizontalSpacing: CGFloat
        let verticalSpacing: CGFloat
        let horizontalAlignment: HorizontalAlignment
        let verticalAlignment: VerticalAlignment
        let maxLines: Int
        @Binding var lineCount: Int
        
        /// Запоминаем размеры каждого элемента (после замера).
        @State private var sizes: [_VariadicView_Children.Element.ID: CGSize] = [:]
        
        /// Запоминаем рассчитанные позиции (x,y) каждого элемента.
        @State private var positions: [_VariadicView_Children.Element.ID: CGPoint] = [:]
        
        /// Итоговая высота контейнера (по факту).
        @State private var totalHeight: CGFloat = 0
        
        func body(children: _VariadicView.Children) -> some View {
            GeometryReader { geo in
                ZStack(alignment: .topLeading) {
                    // 1) "Невидимый" проход: замеряем каждый элемент.
                    ForEach(children) { child in
                        child
                            .fixedSize() // чтобы контент занял ровно свой размер
                            .opacity(0)  // невидимо
                            .background(
                                GeometryReader { proxy in
                                    Color.clear
                                        .onAppear {
                                            updateSize(
                                                for: child,
                                                children: children,
                                                size: proxy.size,
                                                containerWidth: geo.size.width,
                                                maxLines: maxLines
                                            )
                                        }
                                }
                            )
                    }
                    
                    // 2) Реальная отрисовка: раскладываем по рассчитанным `positions`.
                    ForEach(children) { child in
                        if let pos = positions[child.id],
                           let sz = sizes[child.id]
                        {
                            child
                                .frame(width: sz.width, height: sz.height)
                                .position(pos) // координаты (x,y) центра
                        }
                    }
                }
                .valueChanged(of: maxLines) {
                    recalcLayout(
                        children: children,
                        containerWidth: geo.size.width,
                        maxLines: $0
                    )
                }
            }
            .frame(height: totalHeight)
            .clipped()
        }
        
        // MARK: - Вспомогательные методы
        
        private func updateSize(
            for item: _VariadicView_Children.Element,
            children: _VariadicView.Children,
            size: CGSize,
            containerWidth: CGFloat,
            maxLines: Int
        ) {
            // Если элемент шире контейнера, принудительно «обрезаем» ширину
            sizes[item.id] = size.width > containerWidth
            ? .init(width: containerWidth, height: size.height)
            : size
            recalcLayout(children: children, containerWidth: containerWidth, maxLines: maxLines)
        }
        
        /// Пересчитываем раскладку:
        ///  - Определяем общее число строк `neededLines` (lineCount) для всего контента.
        ///  - Расставляем ВСЕ элементы по настоящим координатам (включая те, что выходят за `maxLines`).
        ///  - Но высоту контейнера ставим под `min(neededLines, maxLines)`.
        private func recalcLayout(children: _VariadicView.Children, containerWidth: CGFloat, maxLines: Int) {
            // Храним структуры «строка»: массив ID + макс. высота строки
            var lines: [[_VariadicView_Children.Element.ID]] = []
            var lineHeights: [CGFloat] = []
            var lineWidths: [CGFloat] = []
            
            // Текущая линия
            var currentLineIDs: [_VariadicView_Children.Element.ID] = []
            var currentLineWidth: CGFloat = 0
            var currentLineHeight: CGFloat = 0
            
            // 1) Разбиваем на строки (без учёта maxLines, т.к. нужно посчитать все).
            for child in children {
                let sz = sizes[child.id] ?? .zero
                
                // Проверяем, влезает ли элемент в текущую строку
                if !currentLineIDs.isEmpty,
                   currentLineWidth + sz.width + horizontalSpacing > containerWidth
                {
                    // Завершаем предыдущую строку
                    lines.append(currentLineIDs)
                    lineHeights.append(currentLineHeight)
                    lineWidths.append(currentLineWidth)
                    
                    // Начинаем новую
                    currentLineIDs = [child.id]
                    currentLineWidth = sz.width
                    currentLineHeight = sz.height
                } else {
                    // Добавляем элемент в текущую строку
                    currentLineIDs.append(child.id)
                    // Если это не первый элемент в строке, добавляем horizontalSpacing
                    if currentLineIDs.count > 1 {
                        currentLineWidth += horizontalSpacing
                    }
                    currentLineWidth += sz.width
                    currentLineHeight = max(currentLineHeight, sz.height)
                }
            }
            // Если в текущей строке что-то осталось
            if !currentLineIDs.isEmpty {
                lines.append(currentLineIDs)
                lineHeights.append(currentLineHeight)
                lineWidths.append(currentLineWidth)
            }
            
            // Всего строк (для ВСЕГО контента).
            let neededLines = lines.count
            
            // Передаём наружу (сколько строк нужно для полного отображения).
            DispatchQueue.main.async {
                self.lineCount = neededLines
            }
            
            // 2) Расставляем все элементы по настоящим координатам (вне зависимости от maxLines).
            var newPositions: [_VariadicView_Children.Element.ID: CGPoint] = [:]
            
            // Текущая "вертикальная" координата (от верха контейнера)
            var currentY: CGFloat = 0
            
            for lineIndex in 0..<neededLines {
                let line = lines[lineIndex]
                let lineHeight = lineHeights[lineIndex]
                let lineWidth = lineWidths[lineIndex]
                
                // Сдвиг, если нужно центрировать или выравнивать справа
                let xOffset: CGFloat
                switch horizontalAlignment {
                case .leading:
                    xOffset = 0
                case .center:
                    xOffset = max((containerWidth - lineWidth) / 2, 0)
                case .trailing:
                    xOffset = max(containerWidth - lineWidth, 0)
                default:
                    // На случай, если появятся другие варианты
                    xOffset = 0
                }
                
                // «Бегущая» координата X в рамках текущей строки
                var currentX = xOffset
                
                // Расставляем элементы строки
                for childID in line {
                    let sz = sizes[childID] ?? .zero
                    
                    // Вертикальный офсет внутри строки для элементa
                    let yOffset: CGFloat
                    switch verticalAlignment {
                    case .top:
                        yOffset = 0
                    case .center:
                        yOffset = (lineHeight - sz.height) / 2
                    case .bottom:
                        yOffset = lineHeight - sz.height
                    default:
                        yOffset = 0
                    }
                    
                    // Позиция центра элемента:
                    //  - X = текущий X + половина ширины
                    //  - Y = текущий Y + yOffset + половина высоты
                    let pos = CGPoint(
                        x: currentX + sz.width / 2,
                        y: currentY + yOffset + sz.height / 2
                    )
                    
                    newPositions[childID] = pos
                    currentX += sz.width + horizontalSpacing
                }
                
                currentY += lineHeight + verticalSpacing
            }
            
            // Если есть хотя бы одна строка, убираем лишний spacing после последней.
            if neededLines > 0 {
                currentY -= verticalSpacing
            }
            
            // 3) Высота контейнера должна учитывать только первые maxLines строк.
            // Если нужных строк меньше maxLines, возьмём то, что есть.
            let visibleLines = min(neededLines, maxLines)
            // Складываем высоты только нужного количества строк
            let finalHeight: CGFloat = {
                guard neededLines > 0 && visibleLines > 0 else { return 0 }
                
                let visibleHeights = Array(lineHeights.prefix(visibleLines))
                // Сумма высот + промежуточные верт. отступы
                let sumHeights = visibleHeights.reduce(0, +)
                let sumSpacings = CGFloat(visibleLines - 1) * verticalSpacing
                
                return sumHeights + sumSpacings
            }()
            
            DispatchQueue.main.async {
                positions = newPositions
                withAnimation(animation ?? .none) {
                    totalHeight = max(finalHeight, 0)
                }
            }
        }
    }
}
