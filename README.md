# FlowRow

[![Latest release](https://img.shields.io/github/v/release/c-villain/FlowRow?color=brightgreen&label=version)](https://github.com/c-villain/FlowRow/releases/latest)
[![](https://img.shields.io/badge/SPM-supported-DE5C43.svg?color=brightgreen)](https://swift.org/package-manager/)
![](https://img.shields.io/github/license/c-villain/FlowRow)

[![contact: @lexkraev](https://img.shields.io/badge/contact-%40lexkraev-blue.svg?style=flat)](https://t.me/lexkraev)
[![Telegram Group](https://img.shields.io/endpoint?color=neon&style=flat-square&url=https%3A%2F%2Ftg.sumanjay.workers.dev%2Fswiftui_dev)](https://telegram.dog/swiftui_dev)

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


You can configure alignment:
- Use `horizontalAlignment:` to control how each row is aligned relative to the whole layout (e.g. `.leading`, `.center`, `.trailing`)
- Use `verticalAlignment:` to align views **within** a row (e.g. `.top`, `.center`, `.bottom`)

```swift
FlowRow(
    horizontalAlignment: .center,
    verticalAlignment: .top
) {
    ...
}
```

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

## Installation

#### Swift Package Manager

To integrate ```FlowRow``` into your project using SwiftPM add the following to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/c-villain/FlowRow", from: "0.1.0"),
],
```
or via [XcodeGen](https://github.com/yonaskolb/XcodeGen) insert into your `project.yml`:

```yaml
name: YourProjectName
options:
  deploymentTarget:
    iOS: 13.0
packages:
  FlowRow:
    url: https://github.com/c-villain/FlowRow
    from: 0.1.0
targets:
  YourTarget:
    type: application
    ...
    dependencies:
       - package: FlowRow
```

## Communication

- If you **found a bug**, open an issue or submit a fix via a pull request.
- If you **have a feature request**, open an issue or submit a implementation via a pull request or hit me up on **lexkraev@gmail.com** or **[telegram](https://t.me/lexkraev)**.
- If you **want to contribute**, submit a pull request onto the master branch.

👨🏻‍💻 Feel free to subscribe to channel **[SwiftUI dev](https://t.me/swiftui_dev)** in telegram.
