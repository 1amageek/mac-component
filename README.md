# SplitView

SplitView is a small SwiftUI package for macOS split layouts backed by `NSSplitView`.

It provides:

- `NativeVSplitView`: a SwiftUI vertical split view backed by AppKit.
- `CollapsibleSplitView`: a main content area with a collapsible bottom panel.

## Requirements

- macOS 15.0+
- Swift 6.2+

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/1amageek/SplitView.git", branch: "main")
]
```

```swift
.target(
    name: "YourApp",
    dependencies: [
        .product(name: "SplitView", package: "SplitView")
    ]
)
```

## NativeVSplitView

```swift
import SplitView
import SwiftUI

NativeVSplitView {
    EditorView()
    InspectorView()
}
```

`NativeVSplitView` preserves the bottom pane size while the top pane resizes freely.

## CollapsibleSplitView

```swift
CollapsibleSplitView(isExpanded: $isExpanded) {
    CanvasView()
} content: {
    LogPanelView()
} header: {
    Label("Logs", systemImage: "terminal")
}
```

The header remains visible when the bottom panel is collapsed.
