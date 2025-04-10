# FlowRow
SwiftUI layout component that arranges views in horizontal rows and wraps them into new lines when needed

A ``FlowRow`` automatically wraps its content to a new row when it exceeds the available width, similar to text wrapping or [`FlowRow`](https://developer.android.com/develop/ui/compose/layouts/flow) in Jetpack Compose or [`flex-wrap`](https://developer.mozilla.org/en-US/docs/Web/CSS/flex-wrap) in CSS. The number of lines can be limited via the ``maxLines`` parameter.

```swift
FlowRow {
    ForEach(tags, id: \.self) {
        Text($0)
    }
}
```

### Layout behavior

The component adapts its layout dynamically based on the container's width and the size of child views.
It also supports alignment customization both **within rows** and **across rows** using the appropriate parameters.

### Customizing spacing

You can control the spacing between elements and rows:

```swift
FlowRow(
    horizontalSpacing: 12,
    verticalSpacing: 8
) {
    ...
}
```

### Line count tracking

To observe or constrain the number of visible lines, use the `maxLines:` and `lineCount:` parameters:

```swift
@State private var lineCount: Int = 0

FlowRow(maxLines: 2, lineCount: $lineCount) {
    ...
}
```


