import AppKit
import SwiftUI

public struct VSplitPane<Content: View>: View {
    @Environment(\.vSplitPaneInitialTopPaneHeight) private var initialTopPaneHeight
    @Environment(\.vSplitPaneInitialBottomPaneHeight) private var initialBottomPaneHeight
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
                    initialTopPaneHeight: initialTopPaneHeight,
                    initialBottomPaneHeight: initialBottomPaneHeight,
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
    func topPaneHeight(_ height: CGFloat) -> some View {
        environment(\.vSplitPaneInitialTopPaneHeight, height)
    }

    func topPaneHeight(_ height: CGFloat, minimum minimumHeight: CGFloat) -> some View {
        topPaneHeight(height)
            .topPaneHeight(minimum: minimumHeight)
    }

    func topPaneHeight(_ height: CGFloat, maximum maximumHeight: CGFloat) -> some View {
        topPaneHeight(height)
            .topPaneHeight(maximum: maximumHeight)
    }

    func topPaneHeight(_ height: CGFloat, minimum minimumHeight: CGFloat, maximum maximumHeight: CGFloat) -> some View {
        topPaneHeight(height)
            .topPaneHeight(minimum: minimumHeight)
            .topPaneHeight(maximum: maximumHeight)
    }

    func bottomPaneHeight(_ height: CGFloat) -> some View {
        environment(\.vSplitPaneInitialBottomPaneHeight, height)
    }

    func bottomPaneHeight(_ height: CGFloat, minimum minimumHeight: CGFloat) -> some View {
        bottomPaneHeight(height)
            .bottomPaneHeight(minimum: minimumHeight)
    }

    func bottomPaneHeight(_ height: CGFloat, maximum maximumHeight: CGFloat) -> some View {
        bottomPaneHeight(height)
            .bottomPaneHeight(maximum: maximumHeight)
    }

    func bottomPaneHeight(_ height: CGFloat, minimum minimumHeight: CGFloat, maximum maximumHeight: CGFloat) -> some View {
        bottomPaneHeight(height)
            .bottomPaneHeight(minimum: minimumHeight)
            .bottomPaneHeight(maximum: maximumHeight)
    }

    func topPaneHeight(minimum height: CGFloat) -> some View {
        environment(\.vSplitPaneMinimumTopPaneHeight, height)
    }

    func topPaneHeight(minimum minimumHeight: CGFloat, maximum maximumHeight: CGFloat) -> some View {
        topPaneHeight(minimum: minimumHeight)
            .topPaneHeight(maximum: maximumHeight)
    }

    func bottomPaneHeight(minimum height: CGFloat) -> some View {
        environment(\.vSplitPaneMinimumBottomPaneHeight, height)
    }

    func bottomPaneHeight(minimum minimumHeight: CGFloat, maximum maximumHeight: CGFloat) -> some View {
        bottomPaneHeight(minimum: minimumHeight)
            .bottomPaneHeight(maximum: maximumHeight)
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
    var initialTopPaneHeight: CGFloat?
    var initialBottomPaneHeight: CGFloat?
    var minimumTopPaneHeight: CGFloat
    var minimumBottomPaneHeight: CGFloat
    var maximumTopPaneHeight: CGFloat
    var maximumBottomPaneHeight: CGFloat
    var dividerDragStripHeight: CGFloat

    init(
        initialTopPaneHeight: CGFloat? = nil,
        initialBottomPaneHeight: CGFloat? = nil,
        minimumTopPaneHeight: CGFloat = 200,
        minimumBottomPaneHeight: CGFloat = 80,
        maximumTopPaneHeight: CGFloat = .infinity,
        maximumBottomPaneHeight: CGFloat = .infinity,
        dividerDragStripHeight: CGFloat = 8
    ) {
        self.initialTopPaneHeight = initialTopPaneHeight
        self.initialBottomPaneHeight = initialBottomPaneHeight
        self.minimumTopPaneHeight = minimumTopPaneHeight
        self.minimumBottomPaneHeight = minimumBottomPaneHeight
        self.maximumTopPaneHeight = max(maximumTopPaneHeight, minimumTopPaneHeight)
        self.maximumBottomPaneHeight = max(maximumBottomPaneHeight, minimumBottomPaneHeight)
        self.dividerDragStripHeight = dividerDragStripHeight
    }
}

private struct VSplitPaneInitialTopPaneHeightKey: EnvironmentKey {
    static let defaultValue: CGFloat? = nil
}

private struct VSplitPaneInitialBottomPaneHeightKey: EnvironmentKey {
    static let defaultValue: CGFloat? = nil
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
    var vSplitPaneInitialTopPaneHeight: CGFloat? {
        get { self[VSplitPaneInitialTopPaneHeightKey.self] }
        set { self[VSplitPaneInitialTopPaneHeightKey.self] = newValue }
    }

    var vSplitPaneInitialBottomPaneHeight: CGFloat? {
        get { self[VSplitPaneInitialBottomPaneHeightKey.self] }
        set { self[VSplitPaneInitialBottomPaneHeightKey.self] = newValue }
    }

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
        let splitView = VSplitPaneSplitView()
        splitView.isVertical = false
        splitView.dividerStyle = .thin
        splitView.delegate = context.coordinator
        splitView.layoutHandler = { [weak coordinator = context.coordinator] splitView in
            coordinator?.applyPaneHeightConstraints(to: splitView)
        }
        context.coordinator.configuration = configuration
        rebuildSubviews(splitView)
        return splitView
    }

    func updateNSView(_ splitView: NSSplitView, context: Context) {
        context.coordinator.update(configuration: configuration)

        let existing = splitView.arrangedSubviews
        if existing.count == subviews.count {
            for (index, view) in subviews.enumerated() {
                if let host = existing[index] as? NSHostingView<AnyView> {
                    host.rootView = view
                }
            }
        } else {
            context.coordinator.resetInitialPaneHeight()
            rebuildSubviews(splitView)
        }

        context.coordinator.applyPaneHeightConstraints(to: splitView)
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
        private var isApplyingPaneHeightConstraints = false
        private var hasAppliedInitialPaneHeight = false

        init(configuration: VSplitPaneConfiguration) {
            self.configuration = configuration
        }

        func update(configuration: VSplitPaneConfiguration) {
            if self.configuration.initialTopPaneHeight != configuration.initialTopPaneHeight ||
                self.configuration.initialBottomPaneHeight != configuration.initialBottomPaneHeight {
                hasAppliedInitialPaneHeight = false
            }

            self.configuration = configuration
        }

        func resetInitialPaneHeight() {
            hasAppliedInitialPaneHeight = false
        }

        @MainActor
        func applyPaneHeightConstraints(to splitView: NSSplitView) {
            guard !isApplyingPaneHeightConstraints,
                  splitView.arrangedSubviews.count > 1,
                  splitView.bounds.height > 0 else {
                return
            }

            let currentPosition = splitView.arrangedSubviews[0].frame.height
            let initialPosition = initialDividerPosition(totalHeight: splitView.bounds.height)
            let fallbackPosition = currentPosition.isFinite
                ? currentPosition
                : configuration.minimumTopPaneHeight
            let proposedPosition = initialPosition ?? fallbackPosition
            let constrainedPosition = constrainedDividerPosition(
                proposedPosition,
                totalHeight: splitView.bounds.height
            )

            if initialPosition != nil {
                hasAppliedInitialPaneHeight = true
            }

            guard constrainedPosition.isFinite,
                  abs(currentPosition - constrainedPosition) > 0.5 else {
                return
            }

            isApplyingPaneHeightConstraints = true
            splitView.setPosition(constrainedPosition, ofDividerAt: 0)
            isApplyingPaneHeightConstraints = false
        }

        private func initialDividerPosition(totalHeight: CGFloat) -> CGFloat? {
            guard !hasAppliedInitialPaneHeight else {
                return nil
            }

            if let bottomPaneHeight = configuration.initialBottomPaneHeight,
               bottomPaneHeight.isFinite {
                return totalHeight - bottomPaneHeight
            }

            if let topPaneHeight = configuration.initialTopPaneHeight,
               topPaneHeight.isFinite {
                return topPaneHeight
            }

            return nil
        }

        private func constrainedDividerPosition(
            _ proposedPosition: CGFloat,
            totalHeight: CGFloat
        ) -> CGFloat {
            let minimumPosition = max(
                0,
                configuration.minimumTopPaneHeight,
                totalHeight - configuration.maximumBottomPaneHeight
            )
            let maximumPosition = min(
                totalHeight,
                configuration.maximumTopPaneHeight,
                totalHeight - configuration.minimumBottomPaneHeight
            )

            guard minimumPosition <= maximumPosition else {
                let proposedBottomPaneHeight = totalHeight - proposedPosition
                let bottomPaneHeight = min(
                    max(proposedBottomPaneHeight, configuration.minimumBottomPaneHeight),
                    configuration.maximumBottomPaneHeight
                )
                return min(max(totalHeight - bottomPaneHeight, 0), totalHeight)
            }

            return min(max(proposedPosition, minimumPosition), maximumPosition)
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

private final class VSplitPaneSplitView: NSSplitView {
    var layoutHandler: (@MainActor (NSSplitView) -> Void)?

    override func layout() {
        super.layout()
        layoutHandler?(self)
    }
}

private func vSplitPanePreviewPanel(
    title: String,
    target: String,
    systemImage: String,
    color: Color
) -> some View {
    GeometryReader { proxy in
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                    .foregroundStyle(color)
                Text(title)
                    .font(.headline)
                Spacer()
            }

            Text(target)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text("\(Int(proxy.size.height.rounded())) px")
                .font(.system(.title2, design: .monospaced).weight(.semibold))

            Spacer()
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(color.opacity(0.12))
    }
}

#Preview("V Split Pane Bottom Initial Height") {
    VSplitPane {
        vSplitPanePreviewPanel(
            title: "Editor",
            target: "Flexible top pane",
            systemImage: "square.and.pencil",
            color: .blue
        )

        vSplitPanePreviewPanel(
            title: "Console",
            target: "Initial height 120 px",
            systemImage: "terminal",
            color: .green
        )
    }
    .topPaneHeight(minimum: 180)
    .bottomPaneHeight(120, minimum: 80, maximum: 180)
    .dividerDragStrip(height: 10)
    .frame(width: 560, height: 420)
}

#Preview("V Split Pane Bottom Maximum Clamp") {
    VSplitPane {
        vSplitPanePreviewPanel(
            title: "Editor",
            target: "Bottom request exceeds max",
            systemImage: "square.and.pencil",
            color: .indigo
        )

        vSplitPanePreviewPanel(
            title: "Console",
            target: "Requested 220 px, max 120 px",
            systemImage: "lock.rectangle",
            color: .orange
        )
    }
    .topPaneHeight(minimum: 180)
    .bottomPaneHeight(220, minimum: 80, maximum: 120)
    .dividerDragStrip(height: 10)
    .frame(width: 560, height: 420)
}

#Preview("V Split Pane Top Initial Height") {
    VSplitPane {
        vSplitPanePreviewPanel(
            title: "Timeline",
            target: "Initial height 220 px",
            systemImage: "list.bullet.rectangle",
            color: .purple
        )

        vSplitPanePreviewPanel(
            title: "Output",
            target: "Flexible bottom pane",
            systemImage: "text.alignleft",
            color: .teal
        )
    }
    .topPaneHeight(220, minimum: 160, maximum: 280)
    .bottomPaneHeight(minimum: 100)
    .dividerDragStrip(height: 10)
    .frame(width: 560, height: 420)
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
    .topPaneHeight(0, minimum: 0)
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
    .bottomPaneHeight(0, minimum: 0)
    .dividerDragStrip(height: 10)
    .frame(width: 620, height: 420)
}
