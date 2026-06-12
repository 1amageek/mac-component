import AppKit
import SwiftUI

public struct VSplitPane<Content: View>: View {
    @Environment(\.vSplitPaneMinimumTopPaneHeight) private var minimumTopPaneHeight
    @Environment(\.vSplitPaneMinimumBottomPaneHeight) private var minimumBottomPaneHeight
    @Environment(\.vSplitPaneMaximumTopPaneHeight) private var maximumTopPaneHeight
    @Environment(\.vSplitPaneMaximumBottomPaneHeight) private var maximumBottomPaneHeight
    @Environment(\.vSplitPaneDividerDragStripHeight) private var dividerDragStripHeight

    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        Group(subviews: content) { subviews in
            VSplitPaneRepresentable(
                configuration: VSplitPaneConfiguration(
                    minimumTopPaneHeight: minimumTopPaneHeight,
                    minimumBottomPaneHeight: minimumBottomPaneHeight,
                    maximumTopPaneHeight: maximumTopPaneHeight,
                    maximumBottomPaneHeight: maximumBottomPaneHeight,
                    dividerDragStripHeight: dividerDragStripHeight
                ),
                subviews: subviews.map { AnyView($0) }
            )
        }
    }
}

public extension View {
    func topPaneHeight(minimum height: CGFloat) -> some View {
        environment(\.vSplitPaneMinimumTopPaneHeight, height)
    }

    func bottomPaneHeight(minimum height: CGFloat) -> some View {
        environment(\.vSplitPaneMinimumBottomPaneHeight, height)
    }

    func topPaneHeight(maximum height: CGFloat) -> some View {
        environment(\.vSplitPaneMaximumTopPaneHeight, height)
    }

    func bottomPaneHeight(maximum height: CGFloat) -> some View {
        environment(\.vSplitPaneMaximumBottomPaneHeight, height)
    }

    func dividerDragStrip(height: CGFloat) -> some View {
        environment(\.vSplitPaneDividerDragStripHeight, height)
    }
}

private struct VSplitPaneConfiguration: Sendable {
    var minimumTopPaneHeight: CGFloat
    var minimumBottomPaneHeight: CGFloat
    var maximumTopPaneHeight: CGFloat
    var maximumBottomPaneHeight: CGFloat
    var dividerDragStripHeight: CGFloat

    init(
        minimumTopPaneHeight: CGFloat = 200,
        minimumBottomPaneHeight: CGFloat = 80,
        maximumTopPaneHeight: CGFloat = .infinity,
        maximumBottomPaneHeight: CGFloat = .infinity,
        dividerDragStripHeight: CGFloat = 8
    ) {
        self.minimumTopPaneHeight = minimumTopPaneHeight
        self.minimumBottomPaneHeight = minimumBottomPaneHeight
        self.maximumTopPaneHeight = max(maximumTopPaneHeight, minimumTopPaneHeight)
        self.maximumBottomPaneHeight = max(maximumBottomPaneHeight, minimumBottomPaneHeight)
        self.dividerDragStripHeight = dividerDragStripHeight
    }
}

private struct VSplitPaneMinimumTopPaneHeightKey: EnvironmentKey {
    static let defaultValue: CGFloat = 200
}

private struct VSplitPaneMinimumBottomPaneHeightKey: EnvironmentKey {
    static let defaultValue: CGFloat = 80
}

private struct VSplitPaneMaximumTopPaneHeightKey: EnvironmentKey {
    static let defaultValue: CGFloat = .infinity
}

private struct VSplitPaneMaximumBottomPaneHeightKey: EnvironmentKey {
    static let defaultValue: CGFloat = .infinity
}

private struct VSplitPaneDividerDragStripHeightKey: EnvironmentKey {
    static let defaultValue: CGFloat = 8
}

private extension EnvironmentValues {
    var vSplitPaneMinimumTopPaneHeight: CGFloat {
        get { self[VSplitPaneMinimumTopPaneHeightKey.self] }
        set { self[VSplitPaneMinimumTopPaneHeightKey.self] = newValue }
    }

    var vSplitPaneMinimumBottomPaneHeight: CGFloat {
        get { self[VSplitPaneMinimumBottomPaneHeightKey.self] }
        set { self[VSplitPaneMinimumBottomPaneHeightKey.self] = newValue }
    }

    var vSplitPaneMaximumTopPaneHeight: CGFloat {
        get { self[VSplitPaneMaximumTopPaneHeightKey.self] }
        set { self[VSplitPaneMaximumTopPaneHeightKey.self] = newValue }
    }

    var vSplitPaneMaximumBottomPaneHeight: CGFloat {
        get { self[VSplitPaneMaximumBottomPaneHeightKey.self] }
        set { self[VSplitPaneMaximumBottomPaneHeightKey.self] = newValue }
    }

    var vSplitPaneDividerDragStripHeight: CGFloat {
        get { self[VSplitPaneDividerDragStripHeightKey.self] }
        set { self[VSplitPaneDividerDragStripHeightKey.self] = newValue }
    }
}

private struct VSplitPaneRepresentable: NSViewRepresentable {
    let configuration: VSplitPaneConfiguration
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
        var configuration: VSplitPaneConfiguration

        init(configuration: VSplitPaneConfiguration) {
            self.configuration = configuration
        }

        func splitView(
            _ splitView: NSSplitView,
            constrainMinCoordinate proposedMinimumPosition: CGFloat,
            ofSubviewAt dividerIndex: Int
        ) -> CGFloat {
            max(
                proposedMinimumPosition,
                configuration.minimumTopPaneHeight,
                splitView.bounds.height - configuration.maximumBottomPaneHeight
            )
        }

        func splitView(
            _ splitView: NSSplitView,
            constrainMaxCoordinate proposedMaximumPosition: CGFloat,
            ofSubviewAt dividerIndex: Int
        ) -> CGFloat {
            min(
                proposedMaximumPosition,
                configuration.maximumTopPaneHeight,
                splitView.bounds.height - configuration.minimumBottomPaneHeight
            )
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

#Preview("V Split Pane Top Zero") {
    VSplitPane {
        Color.clear
            .frame(height: 0)

        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: "terminal")
                    .font(.system(size: 28))
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Output")
                        .font(.largeTitle.weight(.semibold))
                    Text("Top pane is zero height")
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            List {
                Section("Log Lines") {
                    Label("build started", systemImage: "play")
                    Label("resolving package graph", systemImage: "shippingbox")
                    Label("build complete", systemImage: "checkmark.circle")
                }
            }
            .listStyle(.inset)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color(nsColor: .windowBackgroundColor))
    }
    .topPaneHeight(minimum: 0)
    .bottomPaneHeight(minimum: 160)
    .dividerDragStrip(height: 10)
    .frame(width: 620, height: 420)
}

#Preview("V Split Pane Bottom Zero") {
    VSplitPane {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: "square.and.pencil")
                    .foregroundStyle(.secondary)
                Text("Editor")
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal, 14)
            .frame(height: 40)

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Canvas")
                    Text("Properties")
                    Text("History")
                }
                .font(.body)
                .textSelection(.enabled)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .background(Color(nsColor: .textBackgroundColor))

        Color.clear
            .frame(height: 0)
    }
    .topPaneHeight(minimum: 160)
    .bottomPaneHeight(minimum: 0)
    .dividerDragStrip(height: 10)
    .frame(width: 620, height: 420)
}
