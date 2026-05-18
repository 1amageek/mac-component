import SwiftUI

public struct CollapsibleView<Main: View, Content: View, Header: View>: View {
    @Environment(\.collapsibleViewHeaderHeight) private var headerHeight
    @Environment(\.collapsibleViewHeaderHorizontalPadding) private var headerHorizontalPadding
    @Environment(\.collapsibleViewToggleButtonSystemImage) private var toggleButtonSystemImage
    @Environment(\.collapsibleViewExpandedButtonHelp) private var expandedButtonHelp
    @Environment(\.collapsibleViewCollapsedButtonHelp) private var collapsedButtonHelp

    @Binding private var isExpanded: Bool
    private let main: Main
    private let content: Content
    private let header: Header

    public init(
        isExpanded: Binding<Bool>,
        @ViewBuilder main: () -> Main,
        @ViewBuilder content: () -> Content,
        @ViewBuilder header: () -> Header
    ) {
        self._isExpanded = isExpanded
        self.main = main()
        self.content = content()
        self.header = header()
    }

    public var body: some View {
        if isExpanded {
            VSplitPane {
                main
                footerPanel
            }
        } else {
            VStack(spacing: 0) {
                main
                headerBar
            }
        }
    }

    private var footerPanel: some View {
        VStack(spacing: 0) {
            headerBar
            Divider()
            content
        }
    }

    private var headerBar: some View {
        ZStack {
            Rectangle().fill(.bar)
            VStack(spacing: 0) {
                Divider()
                HStack(spacing: 8) {
                    header

                    Spacer(minLength: 8)

                    panelVisibilityButton
                }
                .padding(.horizontal, headerHorizontalPadding)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(height: headerHeight)
        .clipped()
    }

    private var panelVisibilityButton: some View {
        Button {
            isExpanded.toggle()
        } label: {
            Image(systemName: toggleButtonSystemImage)
                .symbolRenderingMode(.hierarchical)
                .font(.body)
                .frame(width: 28, height: 28)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .foregroundStyle(isExpanded ? AnyShapeStyle(Color.accentColor) : AnyShapeStyle(.secondary))
        .help(isExpanded ? expandedButtonHelp : collapsedButtonHelp)
    }
}

public extension View {
    func collapsibleHeaderHeight(_ height: CGFloat) -> some View {
        environment(\.collapsibleViewHeaderHeight, height)
    }

    func collapsibleHeaderHorizontalPadding(_ length: CGFloat) -> some View {
        environment(\.collapsibleViewHeaderHorizontalPadding, length)
    }

    func collapsibleToggleButton(systemImage: String) -> some View {
        environment(\.collapsibleViewToggleButtonSystemImage, systemImage)
    }

    func collapsibleToggleHelp(expanded: String, collapsed: String) -> some View {
        environment(\.collapsibleViewExpandedButtonHelp, expanded)
            .environment(\.collapsibleViewCollapsedButtonHelp, collapsed)
    }
}

private struct CollapsibleViewHeaderHeightKey: EnvironmentKey {
    static let defaultValue: CGFloat = 36
}

private struct CollapsibleViewHeaderHorizontalPaddingKey: EnvironmentKey {
    static let defaultValue: CGFloat = 10
}

private struct CollapsibleViewToggleButtonSystemImageKey: EnvironmentKey {
    static let defaultValue = "rectangle.bottomthird.inset.filled"
}

private struct CollapsibleViewExpandedButtonHelpKey: EnvironmentKey {
    static let defaultValue = "Hide Panel"
}

private struct CollapsibleViewCollapsedButtonHelpKey: EnvironmentKey {
    static let defaultValue = "Show Panel"
}

private extension EnvironmentValues {
    var collapsibleViewHeaderHeight: CGFloat {
        get { self[CollapsibleViewHeaderHeightKey.self] }
        set { self[CollapsibleViewHeaderHeightKey.self] = newValue }
    }

    var collapsibleViewHeaderHorizontalPadding: CGFloat {
        get { self[CollapsibleViewHeaderHorizontalPaddingKey.self] }
        set { self[CollapsibleViewHeaderHorizontalPaddingKey.self] = newValue }
    }

    var collapsibleViewToggleButtonSystemImage: String {
        get { self[CollapsibleViewToggleButtonSystemImageKey.self] }
        set { self[CollapsibleViewToggleButtonSystemImageKey.self] = newValue }
    }

    var collapsibleViewExpandedButtonHelp: String {
        get { self[CollapsibleViewExpandedButtonHelpKey.self] }
        set { self[CollapsibleViewExpandedButtonHelpKey.self] = newValue }
    }

    var collapsibleViewCollapsedButtonHelp: String {
        get { self[CollapsibleViewCollapsedButtonHelpKey.self] }
        set { self[CollapsibleViewCollapsedButtonHelpKey.self] = newValue }
    }
}

#Preview("Collapsible View") {
    @Previewable @State var isExpanded = true

    CollapsibleView(isExpanded: $isExpanded) {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: "rectangle.3.group")
                    .font(.system(size: 28))
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Workspace")
                        .font(.largeTitle.weight(.semibold))
                    Text("Main content remains visible")
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            List {
                Section("Services") {
                    Label("api-gateway", systemImage: "network")
                    Label("agent-runner", systemImage: "cpu")
                    Label("log-store", systemImage: "internaldrive")
                }
            }
            .listStyle(.inset)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color(nsColor: .windowBackgroundColor))
    } content: {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                Text("2026-05-18T10:42:20Z runtime started")
                Text("2026-05-18T10:42:22Z request accepted")
                Text("2026-05-18T10:42:23Z response completed")
            }
            .font(.system(.caption, design: .monospaced))
            .textSelection(.enabled)
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color(nsColor: .textBackgroundColor))
    } header: {
        Label("Runtime Output", systemImage: "text.alignleft")
            .font(.headline)
    }
    .topPaneHeight(minimum: 260)
    .bottomPaneHeight(minimum: 120)
    .dividerDragStrip(height: 10)
    .collapsibleHeaderHeight(40)
    .frame(width: 820, height: 620)
}
