import AppKit
import SwiftUI

public struct HSplitPane<Content: View>: View {
    @Environment(\.hSplitPaneInitialLeadingPaneWidth) private var initialLeadingPaneWidth
    @Environment(\.hSplitPaneInitialTrailingPaneWidth) private var initialTrailingPaneWidth
    @Environment(\.hSplitPaneMinimumLeadingPaneWidth) private var minimumLeadingPaneWidth
    @Environment(\.hSplitPaneMinimumTrailingPaneWidth) private var minimumTrailingPaneWidth
    @Environment(\.hSplitPaneMaximumLeadingPaneWidth) private var maximumLeadingPaneWidth
    @Environment(\.hSplitPaneMaximumTrailingPaneWidth) private var maximumTrailingPaneWidth
    @Environment(\.hSplitPaneDividerDragStripWidth) private var dividerDragStripWidth

    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        Group(subviews: content) { subviews in
            HSplitPaneRepresentable(
                configuration: HSplitPaneConfiguration(
                    initialLeadingPaneWidth: initialLeadingPaneWidth,
                    initialTrailingPaneWidth: initialTrailingPaneWidth,
                    minimumLeadingPaneWidth: minimumLeadingPaneWidth,
                    minimumTrailingPaneWidth: minimumTrailingPaneWidth,
                    maximumLeadingPaneWidth: maximumLeadingPaneWidth,
                    maximumTrailingPaneWidth: maximumTrailingPaneWidth,
                    dividerDragStripWidth: dividerDragStripWidth
                ),
                subviews: subviews.map { AnyView($0) }
            )
        }
    }
}

public extension View {
    func leadingPaneWidth(_ width: CGFloat) -> some View {
        environment(\.hSplitPaneInitialLeadingPaneWidth, width)
    }

    func leadingPaneWidth(_ width: CGFloat, minimum minimumWidth: CGFloat) -> some View {
        leadingPaneWidth(width)
            .leadingPaneWidth(minimum: minimumWidth)
    }

    func leadingPaneWidth(_ width: CGFloat, maximum maximumWidth: CGFloat) -> some View {
        leadingPaneWidth(width)
            .leadingPaneWidth(maximum: maximumWidth)
    }

    func leadingPaneWidth(_ width: CGFloat, minimum minimumWidth: CGFloat, maximum maximumWidth: CGFloat) -> some View {
        leadingPaneWidth(width)
            .leadingPaneWidth(minimum: minimumWidth)
            .leadingPaneWidth(maximum: maximumWidth)
    }

    func trailingPaneWidth(_ width: CGFloat) -> some View {
        environment(\.hSplitPaneInitialTrailingPaneWidth, width)
    }

    func trailingPaneWidth(_ width: CGFloat, minimum minimumWidth: CGFloat) -> some View {
        trailingPaneWidth(width)
            .trailingPaneWidth(minimum: minimumWidth)
    }

    func trailingPaneWidth(_ width: CGFloat, maximum maximumWidth: CGFloat) -> some View {
        trailingPaneWidth(width)
            .trailingPaneWidth(maximum: maximumWidth)
    }

    func trailingPaneWidth(_ width: CGFloat, minimum minimumWidth: CGFloat, maximum maximumWidth: CGFloat) -> some View {
        trailingPaneWidth(width)
            .trailingPaneWidth(minimum: minimumWidth)
            .trailingPaneWidth(maximum: maximumWidth)
    }

    func leadingPaneWidth(minimum width: CGFloat) -> some View {
        environment(\.hSplitPaneMinimumLeadingPaneWidth, width)
    }

    func leadingPaneWidth(minimum minimumWidth: CGFloat, maximum maximumWidth: CGFloat) -> some View {
        leadingPaneWidth(minimum: minimumWidth)
            .leadingPaneWidth(maximum: maximumWidth)
    }

    func trailingPaneWidth(minimum width: CGFloat) -> some View {
        environment(\.hSplitPaneMinimumTrailingPaneWidth, width)
    }

    func trailingPaneWidth(minimum minimumWidth: CGFloat, maximum maximumWidth: CGFloat) -> some View {
        trailingPaneWidth(minimum: minimumWidth)
            .trailingPaneWidth(maximum: maximumWidth)
    }

    func leadingPaneWidth(maximum width: CGFloat) -> some View {
        environment(\.hSplitPaneMaximumLeadingPaneWidth, width)
    }

    func trailingPaneWidth(maximum width: CGFloat) -> some View {
        environment(\.hSplitPaneMaximumTrailingPaneWidth, width)
    }

    func dividerDragStrip(width: CGFloat) -> some View {
        environment(\.hSplitPaneDividerDragStripWidth, width)
    }
}

private struct HSplitPaneConfiguration: Sendable {
    var initialLeadingPaneWidth: CGFloat?
    var initialTrailingPaneWidth: CGFloat?
    var minimumLeadingPaneWidth: CGFloat
    var minimumTrailingPaneWidth: CGFloat
    var maximumLeadingPaneWidth: CGFloat
    var maximumTrailingPaneWidth: CGFloat
    var dividerDragStripWidth: CGFloat

    init(
        initialLeadingPaneWidth: CGFloat? = nil,
        initialTrailingPaneWidth: CGFloat? = nil,
        minimumLeadingPaneWidth: CGFloat = 200,
        minimumTrailingPaneWidth: CGFloat = 80,
        maximumLeadingPaneWidth: CGFloat = .infinity,
        maximumTrailingPaneWidth: CGFloat = .infinity,
        dividerDragStripWidth: CGFloat = 8
    ) {
        self.initialLeadingPaneWidth = initialLeadingPaneWidth
        self.initialTrailingPaneWidth = initialTrailingPaneWidth
        self.minimumLeadingPaneWidth = minimumLeadingPaneWidth
        self.minimumTrailingPaneWidth = minimumTrailingPaneWidth
        self.maximumLeadingPaneWidth = max(maximumLeadingPaneWidth, minimumLeadingPaneWidth)
        self.maximumTrailingPaneWidth = max(maximumTrailingPaneWidth, minimumTrailingPaneWidth)
        self.dividerDragStripWidth = dividerDragStripWidth
    }
}

private struct HSplitPaneInitialLeadingPaneWidthKey: EnvironmentKey {
    static let defaultValue: CGFloat? = nil
}

private struct HSplitPaneInitialTrailingPaneWidthKey: EnvironmentKey {
    static let defaultValue: CGFloat? = nil
}

private struct HSplitPaneMinimumLeadingPaneWidthKey: EnvironmentKey {
    static let defaultValue: CGFloat = 200
}

private struct HSplitPaneMinimumTrailingPaneWidthKey: EnvironmentKey {
    static let defaultValue: CGFloat = 80
}

private struct HSplitPaneMaximumLeadingPaneWidthKey: EnvironmentKey {
    static let defaultValue: CGFloat = .infinity
}

private struct HSplitPaneMaximumTrailingPaneWidthKey: EnvironmentKey {
    static let defaultValue: CGFloat = .infinity
}

private struct HSplitPaneDividerDragStripWidthKey: EnvironmentKey {
    static let defaultValue: CGFloat = 8
}

private extension EnvironmentValues {
    var hSplitPaneInitialLeadingPaneWidth: CGFloat? {
        get { self[HSplitPaneInitialLeadingPaneWidthKey.self] }
        set { self[HSplitPaneInitialLeadingPaneWidthKey.self] = newValue }
    }

    var hSplitPaneInitialTrailingPaneWidth: CGFloat? {
        get { self[HSplitPaneInitialTrailingPaneWidthKey.self] }
        set { self[HSplitPaneInitialTrailingPaneWidthKey.self] = newValue }
    }

    var hSplitPaneMinimumLeadingPaneWidth: CGFloat {
        get { self[HSplitPaneMinimumLeadingPaneWidthKey.self] }
        set { self[HSplitPaneMinimumLeadingPaneWidthKey.self] = newValue }
    }

    var hSplitPaneMinimumTrailingPaneWidth: CGFloat {
        get { self[HSplitPaneMinimumTrailingPaneWidthKey.self] }
        set { self[HSplitPaneMinimumTrailingPaneWidthKey.self] = newValue }
    }

    var hSplitPaneMaximumLeadingPaneWidth: CGFloat {
        get { self[HSplitPaneMaximumLeadingPaneWidthKey.self] }
        set { self[HSplitPaneMaximumLeadingPaneWidthKey.self] = newValue }
    }

    var hSplitPaneMaximumTrailingPaneWidth: CGFloat {
        get { self[HSplitPaneMaximumTrailingPaneWidthKey.self] }
        set { self[HSplitPaneMaximumTrailingPaneWidthKey.self] = newValue }
    }

    var hSplitPaneDividerDragStripWidth: CGFloat {
        get { self[HSplitPaneDividerDragStripWidthKey.self] }
        set { self[HSplitPaneDividerDragStripWidthKey.self] = newValue }
    }
}

private struct HSplitPaneRepresentable: NSViewRepresentable {
    let configuration: HSplitPaneConfiguration
    let subviews: [AnyView]

    func makeNSView(context: Context) -> NSSplitView {
        let splitView = HSplitPaneSplitView()
        splitView.isVertical = true
        splitView.dividerStyle = .thin
        splitView.delegate = context.coordinator
        splitView.layoutHandler = { [weak coordinator = context.coordinator] splitView in
            coordinator?.applyPaneWidthConstraints(to: splitView)
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
            context.coordinator.resetInitialPaneWidth()
            rebuildSubviews(splitView)
        }

        context.coordinator.applyPaneWidthConstraints(to: splitView)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(configuration: configuration)
    }

    private func rebuildSubviews(_ splitView: NSSplitView) {
        let oldWidths = splitView.arrangedSubviews.map(\.frame.width)
        let totalOldWidth = oldWidths.reduce(0, +)

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

        if totalOldWidth > 0, oldWidths.count == subviews.count {
            for (index, width) in oldWidths.enumerated() where index < splitView.arrangedSubviews.count {
                let view = splitView.arrangedSubviews[index]
                var frame = view.frame
                frame.size.width = width
                view.frame = frame
            }
            splitView.adjustSubviews()
        }
    }

    final class Coordinator: NSObject, NSSplitViewDelegate {
        var configuration: HSplitPaneConfiguration
        private var isApplyingPaneWidthConstraints = false
        private var hasAppliedInitialPaneWidth = false

        init(configuration: HSplitPaneConfiguration) {
            self.configuration = configuration
        }

        func update(configuration: HSplitPaneConfiguration) {
            if self.configuration.initialLeadingPaneWidth != configuration.initialLeadingPaneWidth ||
                self.configuration.initialTrailingPaneWidth != configuration.initialTrailingPaneWidth {
                hasAppliedInitialPaneWidth = false
            }

            self.configuration = configuration
        }

        func resetInitialPaneWidth() {
            hasAppliedInitialPaneWidth = false
        }

        @MainActor
        func applyPaneWidthConstraints(to splitView: NSSplitView) {
            guard !isApplyingPaneWidthConstraints,
                  splitView.arrangedSubviews.count > 1,
                  splitView.bounds.width > 0 else {
                return
            }

            let currentPosition = splitView.arrangedSubviews[0].frame.width
            let initialPosition = initialDividerPosition(totalWidth: splitView.bounds.width)
            let fallbackPosition = currentPosition.isFinite
                ? currentPosition
                : configuration.minimumLeadingPaneWidth
            let proposedPosition = initialPosition ?? fallbackPosition
            let constrainedPosition = constrainedDividerPosition(
                proposedPosition,
                totalWidth: splitView.bounds.width
            )

            if initialPosition != nil {
                hasAppliedInitialPaneWidth = true
            }

            guard constrainedPosition.isFinite,
                  abs(currentPosition - constrainedPosition) > 0.5 else {
                return
            }

            isApplyingPaneWidthConstraints = true
            splitView.setPosition(constrainedPosition, ofDividerAt: 0)
            isApplyingPaneWidthConstraints = false
        }

        private func initialDividerPosition(totalWidth: CGFloat) -> CGFloat? {
            guard !hasAppliedInitialPaneWidth else {
                return nil
            }

            if let trailingPaneWidth = configuration.initialTrailingPaneWidth,
               trailingPaneWidth.isFinite {
                return totalWidth - trailingPaneWidth
            }

            if let leadingPaneWidth = configuration.initialLeadingPaneWidth,
               leadingPaneWidth.isFinite {
                return leadingPaneWidth
            }

            return nil
        }

        private func constrainedDividerPosition(
            _ proposedPosition: CGFloat,
            totalWidth: CGFloat
        ) -> CGFloat {
            let minimumPosition = max(
                0,
                configuration.minimumLeadingPaneWidth,
                totalWidth - configuration.maximumTrailingPaneWidth
            )
            let maximumPosition = min(
                totalWidth,
                configuration.maximumLeadingPaneWidth,
                totalWidth - configuration.minimumTrailingPaneWidth
            )

            guard minimumPosition <= maximumPosition else {
                let proposedTrailingPaneWidth = totalWidth - proposedPosition
                let trailingPaneWidth = min(
                    max(proposedTrailingPaneWidth, configuration.minimumTrailingPaneWidth),
                    configuration.maximumTrailingPaneWidth
                )
                return min(max(totalWidth - trailingPaneWidth, 0), totalWidth)
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
                configuration.minimumLeadingPaneWidth,
                splitView.bounds.width - configuration.maximumTrailingPaneWidth
            )
        }

        func splitView(
            _ splitView: NSSplitView,
            constrainMaxCoordinate proposedMaximumPosition: CGFloat,
            ofSubviewAt dividerIndex: Int
        ) -> CGFloat {
            min(
                proposedMaximumPosition,
                configuration.maximumLeadingPaneWidth,
                splitView.bounds.width - configuration.minimumTrailingPaneWidth
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

            let trailingPane = splitView.arrangedSubviews[dividerIndex + 1]
            let paneFrame = trailingPane.frame
            return NSRect(
                x: paneFrame.origin.x,
                y: paneFrame.origin.y,
                width: configuration.dividerDragStripWidth,
                height: paneFrame.height
            )
        }
    }
}

private final class HSplitPaneSplitView: NSSplitView {
    var layoutHandler: (@MainActor (NSSplitView) -> Void)?

    override func layout() {
        super.layout()
        layoutHandler?(self)
    }
}

private func hSplitPanePreviewPanel(
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

            Text("\(Int(proxy.size.width.rounded())) px")
                .font(.system(.title2, design: .monospaced).weight(.semibold))

            Spacer()
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(color.opacity(0.12))
    }
}

#Preview("H Split Pane Trailing Initial Width") {
    HSplitPane {
        hSplitPanePreviewPanel(
            title: "Content",
            target: "Flexible leading pane",
            systemImage: "rectangle.3.group",
            color: .blue
        )

        hSplitPanePreviewPanel(
            title: "Inspector",
            target: "Initial width 120 px",
            systemImage: "sidebar.trailing",
            color: .green
        )
    }
    .leadingPaneWidth(minimum: 180)
    .trailingPaneWidth(120, minimum: 80, maximum: 220)
    .dividerDragStrip(width: 10)
    .frame(width: 520, height: 280)
}

#Preview("H Split Pane Trailing Maximum Clamp") {
    HSplitPane {
        hSplitPanePreviewPanel(
            title: "Content",
            target: "Trailing request exceeds max",
            systemImage: "rectangle.3.group",
            color: .indigo
        )

        hSplitPanePreviewPanel(
            title: "Inspector",
            target: "Requested 240 px, max 120 px",
            systemImage: "lock.rectangle",
            color: .orange
        )
    }
    .leadingPaneWidth(minimum: 180)
    .trailingPaneWidth(240, minimum: 80, maximum: 120)
    .dividerDragStrip(width: 10)
    .frame(width: 520, height: 280)
}

#Preview("H Split Pane Leading Initial Width") {
    HSplitPane {
        hSplitPanePreviewPanel(
            title: "Navigator",
            target: "Initial width 160 px",
            systemImage: "sidebar.leading",
            color: .purple
        )

        hSplitPanePreviewPanel(
            title: "Detail",
            target: "Flexible trailing pane",
            systemImage: "doc.text",
            color: .teal
        )
    }
    .leadingPaneWidth(160, minimum: 120, maximum: 220)
    .trailingPaneWidth(minimum: 200)
    .dividerDragStrip(width: 10)
    .frame(width: 520, height: 280)
}

#Preview("H Split Pane Leading Zero") {
    HSplitPane {
        Color.clear
            .frame(width: 0)

        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: "sidebar.trailing")
                    .font(.system(size: 28))
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Details")
                        .font(.largeTitle.weight(.semibold))
                    Text("Leading pane is zero width")
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            List {
                Section("Selection") {
                    Label("api-gateway", systemImage: "network")
                    Label("Ready", systemImage: "checkmark.circle")
                    Label("Port 18080", systemImage: "number")
                }
            }
            .listStyle(.inset)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color(nsColor: .windowBackgroundColor))
    }
    .leadingPaneWidth(0, minimum: 0)
    .trailingPaneWidth(minimum: 220)
    .dividerDragStrip(width: 10)
    .frame(width: 520, height: 360)
}

#Preview("H Split Pane Trailing Zero") {
    HSplitPane {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: "rectangle.3.group")
                    .foregroundStyle(.secondary)
                Text("Workspace")
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal, 14)
            .frame(height: 44)

            Divider()

            Form {
                Section("Layout") {
                    LabeledContent("Leading Min", value: "220 px")
                    LabeledContent("Trailing Min", value: "0 px")
                    LabeledContent("Drag Strip", value: "10 px")
                }

                Section("Services") {
                    LabeledContent("Running", value: "4")
                    LabeledContent("Warnings", value: "2")
                }
            }
            .formStyle(.grouped)
            .scrollContentBackground(.hidden)
        }
        .background(Color(nsColor: .controlBackgroundColor))

        Color.clear
            .frame(width: 0)
    }
    .leadingPaneWidth(minimum: 220)
    .trailingPaneWidth(0, minimum: 0)
    .dividerDragStrip(width: 10)
    .frame(width: 520, height: 360)
}
