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

private struct MacSidebarHSplitPreview: View {
    @State private var selection: PreviewSidebarItem? = .dashboard
    @State private var isInspectorPresented = true

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
        HSplitPane {
            overview
            details
        }
        .leadingPaneWidth(minimum: 520)
        .trailingPaneWidth(minimum: 260)
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

                Button {
                    isInspectorPresented.toggle()
                } label: {
                    Image(systemName: "sidebar.trailing")
                }
                .help(isInspectorPresented ? "Hide Inspector" : "Show Inspector")
            }
        }
        .inspector(isPresented: $isInspectorPresented) {
            inspector
                .inspectorColumnWidth(min: 240, ideal: 280, max: 360)
        }
    }

    private var overview: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                HStack(spacing: 12) {
                    Image(systemName: selection?.systemImage ?? "rectangle.3.group")
                        .font(.system(size: 28))
                        .foregroundStyle(.secondary)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(selection?.rawValue ?? "Dashboard")
                            .font(.largeTitle.weight(.semibold))
                        Text("Service control center")
                            .foregroundStyle(.secondary)
                    }

                    Spacer()
                }

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 12)], spacing: 12) {
                    metric(title: "Running", value: "4")
                    metric(title: "Requests", value: "1,248")
                    metric(title: "Warnings", value: "2")
                    metric(title: "Latency", value: "184 ms")
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Services")
                        .font(.headline)

                    serviceRow(name: "api-gateway", status: "Ready", systemImage: "network")
                    serviceRow(name: "agent-runner", status: "Running", systemImage: "cpu")
                    serviceRow(name: "log-store", status: "Ready", systemImage: "internaldrive")
                    serviceRow(name: "metrics-proxy", status: "Idle", systemImage: "chart.xyaxis.line")
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private var details: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: "list.bullet.rectangle")
                    .foregroundStyle(.secondary)
                Text("Details")
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal, 12)
            .frame(height: 40)

            Divider()

            Form {
                Section("Selected Service") {
                    LabeledContent("Name", value: "api-gateway")
                    LabeledContent("Status", value: "Ready")
                    LabeledContent("Port", value: "18080")
                }

                Section("Controls") {
                    Toggle("Auto Restart", isOn: .constant(true))
                    Toggle("Verbose Logs", isOn: .constant(false))
                }

                Section("Limits") {
                    LabeledContent("CPU", value: "42%")
                    LabeledContent("Memory", value: "384 MB")
                }
            }
            .formStyle(.grouped)
            .scrollContentBackground(.hidden)
        }
        .background(Color(nsColor: .controlBackgroundColor))
    }

    private var inspector: some View {
        Form {
            Section("Selection") {
                LabeledContent("Item", value: selection?.rawValue ?? "None")
                LabeledContent("Scope", value: "Workspace")
            }

            Section("Runtime") {
                Toggle("Collect Metrics", isOn: .constant(true))
                Toggle("Notify on Warning", isOn: .constant(true))
            }

            Section("Metadata") {
                LabeledContent("Owner", value: "Operations")
                LabeledContent("Environment", value: "Local")
            }
        }
        .formStyle(.grouped)
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
        .padding(.horizontal, 12)
        .frame(height: 38)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
    }
}

private struct MacSidebarVSplitPreview: View {
    @State private var selection: PreviewSidebarItem? = .logs
    @State private var isInspectorPresented = true

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
        VSplitPane {
            timeline
            console
        }
        .topPaneHeight(minimum: 300)
        .bottomPaneHeight(minimum: 160)
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

                Button {
                    isInspectorPresented.toggle()
                } label: {
                    Image(systemName: "sidebar.trailing")
                }
                .help(isInspectorPresented ? "Hide Inspector" : "Show Inspector")
            }
        }
        .inspector(isPresented: $isInspectorPresented) {
            inspector
                .inspectorColumnWidth(min: 240, ideal: 280, max: 360)
        }
    }

    private var timeline: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                HStack(spacing: 12) {
                    Image(systemName: selection?.systemImage ?? "terminal")
                        .font(.system(size: 28))
                        .foregroundStyle(.secondary)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(selection?.rawValue ?? "Logs")
                            .font(.largeTitle.weight(.semibold))
                        Text("Deployment timeline")
                            .foregroundStyle(.secondary)
                    }

                    Spacer()
                }

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 180), spacing: 12)], spacing: 12) {
                    metric(title: "Build", value: "Passed")
                    metric(title: "Tests", value: "128")
                    metric(title: "Deploy", value: "Staged")
                    metric(title: "Errors", value: "0")
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Recent Events")
                        .font(.headline)

                    timelineRow(title: "Build completed", detail: "All targets compiled successfully")
                    timelineRow(title: "Tests passed", detail: "128 tests completed")
                    timelineRow(title: "Staging updated", detail: "Runtime image promoted")
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private var console: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Label("Console", systemImage: "terminal")
                    .font(.headline)

                Spacer()

                Text("Live")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.green)
            }
            .padding(.horizontal, 12)
            .frame(height: 40)

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    diagnosticLine("2026-05-18T10:42:20Z [runtime][info] service graph loaded")
                    diagnosticLine("2026-05-18T10:42:22Z [deploy][info] staging image promoted")
                    diagnosticLine("2026-05-18T10:42:23Z [runtime][info] health check passed")
                    diagnosticLine("2026-05-18T10:42:25Z [metrics][debug] p95 latency 184ms")
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .background(Color(nsColor: .textBackgroundColor))
    }

    private var inspector: some View {
        Form {
            Section("Selection") {
                LabeledContent("Item", value: selection?.rawValue ?? "None")
                LabeledContent("View", value: "Timeline")
            }

            Section("Filters") {
                Toggle("Show Info", isOn: .constant(true))
                Toggle("Show Debug", isOn: .constant(false))
                Toggle("Show Errors", isOn: .constant(true))
            }

            Section("Session") {
                LabeledContent("Target", value: "staging")
                LabeledContent("Status", value: "Live")
            }
        }
        .formStyle(.grouped)
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

    private func timelineRow(title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.body.weight(.medium))
                Text(detail)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 12)
        }
        .padding(12)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
    }

    private func diagnosticLine(_ text: String) -> some View {
        Text(text)
            .font(.system(.caption, design: .monospaced))
            .textSelection(.enabled)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview("macOS Sidebar H Split") {
    MacSidebarHSplitPreview()
}

#Preview("macOS Sidebar V Split") {
    MacSidebarVSplitPreview()
}
