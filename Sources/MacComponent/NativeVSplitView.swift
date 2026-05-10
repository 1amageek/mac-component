import AppKit
import SwiftUI

public struct NativeVSplitView<Content: View>: View {
    private let configuration: NativeVSplitViewConfiguration
    private let content: Content

    public init(
        configuration: NativeVSplitViewConfiguration = NativeVSplitViewConfiguration(),
        @ViewBuilder content: () -> Content
    ) {
        self.configuration = configuration
        self.content = content()
    }

    public var body: some View {
        Group(subviews: content) { subviews in
            NativeVSplitViewRepresentable(
                configuration: configuration,
                subviews: subviews.map { AnyView($0) }
            )
        }
    }
}

public struct NativeVSplitViewConfiguration: Sendable {
    public var minimumTopPaneHeight: CGFloat
    public var minimumBottomPaneHeight: CGFloat
    public var dividerDragStripHeight: CGFloat

    public init(
        minimumTopPaneHeight: CGFloat = 200,
        minimumBottomPaneHeight: CGFloat = 80,
        dividerDragStripHeight: CGFloat = 8
    ) {
        self.minimumTopPaneHeight = minimumTopPaneHeight
        self.minimumBottomPaneHeight = minimumBottomPaneHeight
        self.dividerDragStripHeight = dividerDragStripHeight
    }
}

private struct NativeVSplitViewRepresentable: NSViewRepresentable {
    let configuration: NativeVSplitViewConfiguration
    let subviews: [AnyView]

    func makeNSView(context: Context) -> NSSplitView {
        let splitView = NSSplitView()
        splitView.isVertical = false
        splitView.dividerStyle = .thin
        splitView.delegate = context.coordinator
        context.coordinator.configuration = configuration
        rebuildSubviews(splitView)
        return splitView
    }

    func updateNSView(_ splitView: NSSplitView, context: Context) {
        context.coordinator.configuration = configuration

        let existing = splitView.arrangedSubviews
        if existing.count == subviews.count {
            for (index, view) in subviews.enumerated() {
                if let host = existing[index] as? NSHostingView<AnyView> {
                    host.rootView = view
                }
            }
        } else {
            rebuildSubviews(splitView)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(configuration: configuration)
    }

    private func rebuildSubviews(_ splitView: NSSplitView) {
        let oldHeights = splitView.arrangedSubviews.map(\.frame.height)
        let totalOldHeight = oldHeights.reduce(0, +)

        for view in splitView.arrangedSubviews.reversed() {
            view.removeFromSuperview()
        }

        for (index, view) in subviews.enumerated() {
            let host = NSHostingView(rootView: view)
            host.translatesAutoresizingMaskIntoConstraints = false
            splitView.addArrangedSubview(host)

            if index == 0 {
                splitView.setHoldingPriority(.defaultLow, forSubviewAt: index)
            } else {
                splitView.setHoldingPriority(.defaultHigh, forSubviewAt: index)
            }
        }

        if totalOldHeight > 0, oldHeights.count == subviews.count {
            for (index, height) in oldHeights.enumerated() where index < splitView.arrangedSubviews.count {
                let view = splitView.arrangedSubviews[index]
                var frame = view.frame
                frame.size.height = height
                view.frame = frame
            }
            splitView.adjustSubviews()
        }
    }

    final class Coordinator: NSObject, NSSplitViewDelegate {
        var configuration: NativeVSplitViewConfiguration

        init(configuration: NativeVSplitViewConfiguration) {
            self.configuration = configuration
        }

        func splitView(
            _ splitView: NSSplitView,
            constrainMinCoordinate proposedMinimumPosition: CGFloat,
            ofSubviewAt dividerIndex: Int
        ) -> CGFloat {
            max(proposedMinimumPosition, configuration.minimumTopPaneHeight)
        }

        func splitView(
            _ splitView: NSSplitView,
            constrainMaxCoordinate proposedMaximumPosition: CGFloat,
            ofSubviewAt dividerIndex: Int
        ) -> CGFloat {
            min(proposedMaximumPosition, splitView.bounds.height - configuration.minimumBottomPaneHeight)
        }

        func splitView(_ splitView: NSSplitView, canCollapseSubview subview: NSView) -> Bool {
            false
        }

        func splitView(
            _ splitView: NSSplitView,
            additionalEffectiveRectOfDividerAt dividerIndex: Int
        ) -> NSRect {
            guard splitView.arrangedSubviews.count > dividerIndex + 1 else {
                return .zero
            }

            let bottomPane = splitView.arrangedSubviews[dividerIndex + 1]
            let paneFrame = bottomPane.frame
            return NSRect(
                x: paneFrame.origin.x,
                y: paneFrame.origin.y,
                width: paneFrame.width,
                height: configuration.dividerDragStripHeight
            )
        }
    }
}
