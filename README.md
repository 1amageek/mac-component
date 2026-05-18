# mac-component

mac-component is a small SwiftUI package for reusable macOS interface components.

It provides:

- `VSplitPane`: a SwiftUI vertical split pane backed by AppKit.
- `HSplitPane`: a SwiftUI horizontal split pane backed by AppKit.
- `CollapsibleView`: a main content area with a collapsible bottom panel.

## Requirements

- macOS 15.0+
- Swift 6.2+

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/1amageek/mac-component.git", branch: "main")
]
```

```swift
.target(
    name: "YourApp",
    dependencies: [
        .product(name: "MacComponent", package: "mac-component")
    ]
)
```

## VSplitPane

```swift
import MacComponent
import SwiftUI

VSplitPane {
    EditorView()
    InspectorView()
}
.topPaneHeight(minimum: 240)
.bottomPaneHeight(minimum: 120)
```

`VSplitPane` preserves the bottom pane size while the top pane resizes freely.

## HSplitPane

```swift
import MacComponent
import SwiftUI

HSplitPane {
    PrimaryView()
    InspectorView()
}
.leadingPaneWidth(minimum: 320)
.trailingPaneWidth(minimum: 220)
```

`HSplitPane` preserves the trailing pane size while the leading pane resizes freely.

## CollapsibleView

```swift
CollapsibleView(isExpanded: $isExpanded) {
    CanvasView()
} content: {
    LogPanelView()
} header: {
    Label("Logs", systemImage: "terminal")
}
.topPaneHeight(minimum: 240)
.bottomPaneHeight(minimum: 120)
.collapsibleHeaderHeight(36)
```

The header remains visible when the bottom panel is collapsed.
