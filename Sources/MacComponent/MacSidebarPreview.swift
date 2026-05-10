import SwiftUI

private enum PreviewSidebarItem: String, CaseIterable, Identifiable {
    case dashboard = "Dashboard"
    case services = "Services"
    case logs = "Logs"
    case settings = "Settings"

    var id: Self { self }

    var systemImage: String {
        switch self {
        case .dashboard:
            "rectangle.3.group"
        case .services:
            "server.rack"
        case .logs:
            "terminal"
        case .settings:
            "gearshape"
        }
    }
}

private struct MacSidebarPreview: View {
    @State private var selection: PreviewSidebarItem? = .dashboard
    @State private var isPanelExpanded = true

    var body: some View {
        NavigationSplitView {
            sidebar
                .navigationSplitViewColumnWidth(min: 200, ideal: 240, max: 280)
        } detail: {
            detail
        }
        .frame(width: 980, height: 680)
    }

    private var sidebar: some View {
        List(PreviewSidebarItem.allCases, selection: $selection) { item in
            Label(item.rawValue, systemImage: item.systemImage)
                .tag(item)
        }
        .listStyle(.sidebar)
        .navigationTitle("Workspace")
    }

    private var detail: some View {
        CollapsibleSplitView(isExpanded: $isPanelExpanded) {
            content
        } content: {
            diagnostics
        } header: {
            Label("Runtime Output", systemImage: "text.alignleft")
                .font(.headline)
        }
        .toolbar {
            ToolbarItemGroup {
                Button {
                } label: {
                    Image(systemName: "play.fill")
                }
                .help("Run")

                Button {
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .help("Refresh")
            }
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 12) {
                Image(systemName: selection?.systemImage ?? "rectangle.3.group")
                    .font(.system(size: 28))
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 4) {
                    Text(selection?.rawValue ?? "Dashboard")
                        .font(.largeTitle.weight(.semibold))
                    Text("Local runtime overview")
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 180), spacing: 12)], spacing: 12) {
                metric(title: "Running", value: "4")
                metric(title: "Requests", value: "1,248")
                metric(title: "Warnings", value: "2")
                metric(title: "Latency", value: "184 ms")
            }

            List {
                Section("Services") {
                    serviceRow(name: "api-gateway", status: "Ready", systemImage: "network")
                    serviceRow(name: "agent-runner", status: "Running", systemImage: "cpu")
                    serviceRow(name: "log-store", status: "Ready", systemImage: "internaldrive")
                }
            }
            .listStyle(.inset)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private var diagnostics: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                diagnosticLine("2026-05-11T02:58:10Z [runtime][info] gateway started on localhost:18080")
                diagnosticLine("2026-05-11T02:58:12Z [service][debug] agent-runner accepted request")
                diagnosticLine("2026-05-11T02:58:14Z [runtime][warning] slow-log-line durationMs=184")
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color(nsColor: .textBackgroundColor))
    }

    private func metric(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title2.weight(.semibold))
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
    }

    private func serviceRow(name: String, status: String, systemImage: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .foregroundStyle(.secondary)
                .frame(width: 20)
            Text(name)
            Spacer()
            Text(status)
                .foregroundStyle(.secondary)
        }
    }

    private func diagnosticLine(_ text: String) -> some View {
        Text(text)
            .font(.system(.caption, design: .monospaced))
            .textSelection(.enabled)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview("macOS Sidebar") {
    MacSidebarPreview()
}
