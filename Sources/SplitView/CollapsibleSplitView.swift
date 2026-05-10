import SwiftUI

public struct CollapsibleSplitView<Main: View, Content: View, Header: View>: View {
    @Binding private var isExpanded: Bool
    private let configuration: CollapsibleSplitViewConfiguration
    private let main: Main
    private let content: Content
    private let header: Header

    public init(
        isExpanded: Binding<Bool>,
        configuration: CollapsibleSplitViewConfiguration = CollapsibleSplitViewConfiguration(),
        @ViewBuilder main: () -> Main,
        @ViewBuilder content: () -> Content,
        @ViewBuilder header: () -> Header
    ) {
        self._isExpanded = isExpanded
        self.configuration = configuration
        self.main = main()
        self.content = content()
        self.header = header()
    }

    public var body: some View {
        if isExpanded {
            NativeVSplitView(configuration: configuration.splitViewConfiguration) {
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
                .padding(.horizontal, configuration.headerHorizontalPadding)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(height: configuration.headerHeight)
        .clipped()
    }

    private var panelVisibilityButton: some View {
        Button {
            isExpanded.toggle()
        } label: {
            Image(systemName: configuration.panelButtonSystemImage)
                .symbolRenderingMode(.hierarchical)
                .font(.body)
                .frame(width: 28, height: 28)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .foregroundStyle(isExpanded ? AnyShapeStyle(Color.accentColor) : AnyShapeStyle(.secondary))
        .help(isExpanded ? configuration.expandedButtonHelp : configuration.collapsedButtonHelp)
    }
}

public struct CollapsibleSplitViewConfiguration: Sendable {
    public var splitViewConfiguration: NativeVSplitViewConfiguration
    public var headerHeight: CGFloat
    public var headerHorizontalPadding: CGFloat
    public var panelButtonSystemImage: String
    public var expandedButtonHelp: String
    public var collapsedButtonHelp: String

    public init(
        splitViewConfiguration: NativeVSplitViewConfiguration = NativeVSplitViewConfiguration(),
        headerHeight: CGFloat = 40,
        headerHorizontalPadding: CGFloat = 10,
        panelButtonSystemImage: String = "rectangle.bottomthird.inset.filled",
        expandedButtonHelp: String = "Hide Panel",
        collapsedButtonHelp: String = "Show Panel"
    ) {
        self.splitViewConfiguration = splitViewConfiguration
        self.headerHeight = headerHeight
        self.headerHorizontalPadding = headerHorizontalPadding
        self.panelButtonSystemImage = panelButtonSystemImage
        self.expandedButtonHelp = expandedButtonHelp
        self.collapsedButtonHelp = collapsedButtonHelp
    }
}
