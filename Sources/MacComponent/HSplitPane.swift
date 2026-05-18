import AppKit
import SwiftUI

public struct HSplitPane<Content: View>: View {
    @Environment(\.hSplitPaneMinimumLeadingPaneWidth) private var minimumLeadingPaneWidth
    @Environment(\.hSplitPaneMinimumTrailingPaneWidth) private var minimumTrailingPaneWidth
    @Environment(\.hSplitPaneDividerDragStripWidth) private var dividerDragStripWidth

    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        Group(subviews: content) { subviews in
            HSplitPaneRepresentable(
                configuration: HSplitPaneConfiguration(
                    minimumLeadingPaneWidth: minimumLeadingPaneWidth,
                    minimumTrailingPaneWidth: minimumTrailingPaneWidth,
                    dividerDragStripWidth: dividerDragStripWidth
                ),
                subviews: subviews.map { AnyView($0) }
            )
        }
    }
}

public extension View {
    func leadingPaneWidth(minimum width: CGFloat) -> some View {
        environment(\.hSplitPaneMinimumLeadingPaneWidth, width)
    }

    func trailingPaneWidth(minimum width: CGFloat) -> some View {
        environment(\.hSplitPaneMinimumTrailingPaneWidth, width)
    }

    func dividerDragStrip(width: CGFloat) -> some View {
        environment(\.hSplitPaneDividerDragStripWidth, width)
    }
}

private struct HSplitPaneConfiguration: Sendable {
    var minimumLeadingPaneWidth: CGFloat
    var minimumTrailingPaneWidth: CGFloat
    var dividerDragStripWidth: CGFloat

    init(
        minimumLeadingPaneWidth: CGFloat = 200,
        minimumTrailingPaneWidth: CGFloat = 80,
        dividerDragStripWidth: CGFloat = 8
    ) {
        self.minimumLeadingPaneWidth = minimumLeadingPaneWidth
        self.minimumTrailingPaneWidth = minimumTrailingPaneWidth
        self.dividerDragStripWidth = dividerDragStripWidth
    }
}

private struct HSplitPaneMinimumLeadingPaneWidthKey: EnvironmentKey {
    static let defaultValue: CGFloat = 200
}

private struct HSplitPaneMinimumTrailingPaneWidthKey: EnvironmentKey {
    static let defaultValue: CGFloat = 80
}

private struct HSplitPaneDividerDragStripWidthKey: EnvironmentKey {
    static let defaultValue: CGFloat = 8
}

private extension EnvironmentValues {
    var hSplitPaneMinimumLeadingPaneWidth: CGFloat {
        get { self[HSplitPaneMinimumLeadingPaneWidthKey.self] }
        set { self[HSplitPaneMinimumLeadingPaneWidthKey.self] = newValue }
    }

    var hSplitPaneMinimumTrailingPaneWidth: CGFloat {
        get { self[HSplitPaneMinimumTrailingPaneWidthKey.self] }
        set { self[HSplitPaneMinimumTrailingPaneWidthKey.self] = newValue }
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
        let splitView = NSSplitView()
        splitView.isVertical = true
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

        init(configuration: HSplitPaneConfiguration) {
            self.configuration = configuration
        }

        func splitView(
            _ splitView: NSSplitView,
            constrainMinCoordinate proposedMinimumPosition: CGFloat,
            ofSubviewAt dividerIndex: Int
        ) -> CGFloat {
            max(proposedMinimumPosition, configuration.minimumLeadingPaneWidth)
        }

        func splitView(
            _ splitView: NSSplitView,
            constrainMaxCoordinate proposedMaximumPosition: CGFloat,
            ofSubviewAt dividerIndex: Int
        ) -> CGFloat {
            min(proposedMaximumPosition, splitView.bounds.width - configuration.minimumTrailingPaneWidth)
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
    .leadingPaneWidth(minimum: 0)
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
    .trailingPaneWidth(minimum: 0)
    .dividerDragStrip(width: 10)
    .frame(width: 520, height: 360)
}
