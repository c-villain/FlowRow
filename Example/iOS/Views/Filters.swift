import SwiftUI
import FlowRow

struct Manufacturer: Hashable, Identifiable {
    let id: Int
    let name: String
}

struct FiltersView: View {
    @State private var allManufacturers: [Manufacturer] = [
        Manufacturer.init(id: 1, name: "AEG"),
        Manufacturer.init(id: 2, name: "ALTECO"),
        Manufacturer.init(id: 3, name: "ARMA"),
        Manufacturer.init(id: 4, name: "AYGER"),
        Manufacturer.init(id: 5, name: "AktiTool"),
        Manufacturer.init(id: 6, name: "Anycons"),
        Manufacturer.init(id: 7, name: "BORT"),
        Manufacturer.init(id: 8, name: "BRADO"),
        Manufacturer.init(id: 9, name: "BRAIT"),
        Manufacturer.init(id: 10, name: "BULL"),
        Manufacturer.init(id: 11, name: "BOSCH"),
        Manufacturer.init(id: 12, name: "Crown"),
        Manufacturer.init(id: 13, name: "Bqewfqwef"),
        Manufacturer.init(id: 14, name: "BRAITsqfwef"),
        Manufacturer.init(id: 15, name: "BRAIT234r234r"),
        Manufacturer.init(id: 16, name: "BRADO3"),
        Manufacturer.init(id: 17, name: "Toyota"),
        Manufacturer.init(id: 18, name: "Mercedes"),
        Manufacturer.init(id: 19, name: "BMW"),
        Manufacturer.init(id: 20, name: "Millauwokie"),
        Manufacturer.init(id: 21, name: "Radug"),
        Manufacturer.init(id: 22, name: "Enforce"),
        Manufacturer.init(id: 23, name: "1touch"),
        Manufacturer.init(id: 24, name: "swift")
        
    ]
    
    @State private var selected: [Manufacturer] = []
    
    @State private var text: String = ""

    let initMaxLines: Int = 2
    @State private var maxLines: Int = 2
    @State private var linesCount: Int = 0
    
    var body: some View {
        VStack(spacing: 0) {
            
            TextField("Enter text", text: $text)
            
            List {
                Group {
                    if selected.isEmpty == false {
                        VStack(alignment: .leading) {
                            
                            FlowRow(
                                horizontalSpacing: 16.0,
                                verticalSpacing: 8.0,
                                maxLines: maxLines,
                                lineCount: $linesCount
                            ) {
                                ForEach(selected, id: \.id) { filter in
                                    HStack(spacing: 6) {
                                        Text(filter.name)
                                            .lineLimit(1)
                                            .frame(maxWidth: .infinity)
                                        Button {
                                            if let index = selected.firstIndex(of: filter) {
                                                selected.remove(at: index)
                                            }
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
                                    )
                                }
                            }
                            .onChange(of: linesCount) { linesCount in
                                print("linesCount: \(linesCount)")
                            }
                            .padding(8.0)
                            .background(Color.yellow)
                            .clipped()
                            .lineLimit(1)

                            if linesCount > initMaxLines {
                                Button{
                                    withAnimation(.none) {
                                        maxLines = (maxLines == Int.max) ? initMaxLines : Int.max
                                    }
                                } label: {
                                    Text((maxLines == Int.max) ? "Смотреть еще (up)" : "Смотреть еще (down)")
                                }
                                .padding(.horizontal, 16.0)
                                .buttonStyle(.plain)
                            }
                        }
                    } else {
                        Spacer().frame(height: 0)
                    }
                }
                .buttonStyle(.plain)
                .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                .frame(minHeight: 0)
                
                ForEach(allManufacturers, id: \.self) { item in
                    Button(action: {
                        withAnimation(.none) {
                            if let index = selected.firstIndex(of: item) {
                                selected.remove(at: index)
                            } else {
                                selected.append(item)
                            }
                        }
                    }) {
                        HStack {
                            Image(systemName: selected.contains(item) ? "checkmark.square.fill" : "square")
                                .foregroundColor(selected.contains(item) ? .red : .gray)
                            Text(item.name)
                            Spacer()
                        }
                        .padding(.vertical, 20)
                        .padding(.horizontal)
                    }
                    .buttonStyle(.plain)
                }
                .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            }
            .environment(\.defaultMinListRowHeight, 0)
            .listStyle(.plain)

            
            Button(action: {
                // Handle apply action
            }) {
                Text("Применить")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding()
            }
        }
    }
}

struct FiltersView_Previews: PreviewProvider {
    static var previews: some View {
        FiltersView()
    }
}
