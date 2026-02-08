import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: FileManagerViewModel
    @State private var columnVisibility: NavigationSplitViewVisibility = .all

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            // Sidebar
            SidebarView()
        } content: {
            // Main content area
            mainContent
        } detail: {
            // Preview panel
            detailPanel
        }
        .navigationSplitViewStyle(.balanced)
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                toolbarItems
            }
        }
        .alert("Permanently Delete", isPresented: $viewModel.showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete Permanently", role: .destructive) {
                viewModel.deleteSelectedFiles()
            }
        } message: {
            Text("Are you sure you want to permanently delete \(viewModel.selectedFiles.count) file(s)? This action cannot be undone.")
        }
        .onAppear {
            viewModel.scanFiles()
        }
    }

    // MARK: - Main Content

    @ViewBuilder
    private var mainContent: some View {
        switch viewModel.selectedSidebarItem {
        case .duplicates:
            DuplicateView()
        default:
            FileListView()
        }
    }

    // MARK: - Detail Panel

    @ViewBuilder
    private var detailPanel: some View {
        FilePreviewView(file: viewModel.selectedFileForPreview)
            .frame(minWidth: 260)
    }

    // MARK: - Toolbar

    @ViewBuilder
    private var toolbarItems: some View {
        Button(action: { viewModel.scanFiles() }) {
            Label("Refresh", systemImage: "arrow.clockwise")
        }
        .help("Rescan Downloads folder")
        .disabled(viewModel.isLoading)

        Button(action: { viewModel.detectDuplicates() }) {
            Label("Duplicates", systemImage: "doc.on.doc")
        }
        .help("Detect duplicate files")
        .disabled(viewModel.isDetectingDuplicates || viewModel.allFiles.isEmpty)

        if !viewModel.selectedFiles.isEmpty {
            Divider()

            Button(action: { viewModel.moveSelectedFiles() }) {
                Label("Move", systemImage: "folder.badge.plus")
            }
            .help("Move selected files")

            Button(action: { viewModel.showDeleteConfirmation = true }) {
                Label("Delete", systemImage: "trash")
            }
            .help("Delete selected files")
        }
    }
}
