import AppKit
import SwiftUI

public struct VSplitPane<Content: View>: View {
    @Environment(\.vSplitPaneMinimumTopPaneHeight) private var minimumTopPaneHeight
    @Environment(\.vSplitPaneMinimumBottomPaneHeight) private var minimumBottomPaneHeight
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

    func dividerDragStrip(height: CGFloat) -> some View {
        environment(\.vSplitPaneDividerDragStripHeight, height)
    }
}

private struct VSplitPaneConfiguration: Sendable {
    var minimumTopPaneHeight: CGFloat
    var minimumBottomPaneHeight: CGFloat
    var dividerDragStripHeight: CGFloat

    init(
        minimumTopPaneHeight: CGFloat = 200,
        minimumBottomPaneHeight: CGFloat = 80,
        dividerDragStripHeight: CGFloat = 8
    ) {
        self.minimumTopPaneHeight = minimumTopPaneHeight
        self.minimumBottomPaneHeight = minimumBottomPaneHeight
        self.dividerDragStripHeight = dividerDragStripHeight
    }
}

private struct VSplitPaneMinimumTopPaneHeightKey: EnvironmentKey {
    static let defaultValue: CGFloat = 200
}

private struct VSplitPaneMinimumBottomPaneHeightKey: EnvironmentKey {
    static let defaultValue: CGFloat = 80
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
            drawDividerIn dirtyRect: NSRect
        ) {
            NSColor.separatorColor.setFill()
            NSBezierPath.fill(NSRect(
                x: dirtyRect.minX,
                y: dirtyRect.midY - 0.5,
                width: dirtyRect.width,
                height: 1
            ))
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

#Preview("V Split Pane") {
    VSplitPane {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 28))
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Editor")
                        .font(.largeTitle.weight(.semibold))
                    Text("Top pane resizes freely")
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            List {
                Section("Sections") {
                    Label("Canvas", systemImage: "rectangle.and.pencil.and.ellipsis")
                    Label("Properties", systemImage: "slider.horizontal.3")
                    Label("History", systemImage: "clock.arrow.circlepath")
                }
            }
            .listStyle(.inset)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color(nsColor: .windowBackgroundColor))

        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: "terminal")
                    .foregroundStyle(.secondary)
                Text("Output")
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal, 14)
            .frame(height: 40)

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    Text("2026-05-18T10:40:12Z build started")
                    Text("2026-05-18T10:40:13Z resolving package graph")
                    Text("2026-05-18T10:40:14Z build complete")
                }
                .font(.system(.caption, design: .monospaced))
                .textSelection(.enabled)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .background(Color(nsColor: .textBackgroundColor))
    }
    .topPaneHeight(minimum: 260)
    .bottomPaneHeight(minimum: 120)
    .dividerDragStrip(height: 10)
    .frame(width: 820, height: 620)
}
