import SwiftUI

struct FileListView: View {
    @EnvironmentObject var viewModel: FileManagerViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Toolbar header
            fileListToolbar

            Divider()

            // File list
            if viewModel.isLoading {
                loadingView
            } else if viewModel.filteredFiles.isEmpty {
                emptyView
            } else {
                fileList
            }

            Divider()

            // Status bar
            statusBar
        }
    }

    // MARK: - Toolbar

    private var fileListToolbar: some View {
        HStack(spacing: 12) {
            // Search field
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search files...", text: $viewModel.searchText)
                    .textFieldStyle(.plain)
                if !viewModel.searchText.isEmpty {
                    Button(action: { viewModel.searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(6)
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(8)

            // Date filter
            Picker("", selection: $viewModel.dateFilter) {
                ForEach(DateFilter.allCases) { filter in
                    Label(filter.rawValue, systemImage: filter.icon)
                        .tag(filter)
                }
            }
            .pickerStyle(.menu)
            .frame(width: 120)

            // Sort options
            Menu {
                ForEach(SortOption.allCases) { option in
                    Button(action: { viewModel.toggleSort(option) }) {
                        HStack {
                            Text(option.rawValue)
                            if viewModel.sortOption == option {
                                Image(systemName: viewModel.sortDirection == .ascending ? "chevron.up" : "chevron.down")
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.up.arrow.down")
                    Text(viewModel.sortOption.rawValue)
                        .font(.caption)
                }
            }

            // Actions
            HStack(spacing: 8) {
                Button(action: { viewModel.scanFiles() }) {
                    Image(systemName: "arrow.clockwise")
                }
                .help("Refresh file list")

                Button(action: { viewModel.selectAll() }) {
                    Image(systemName: "checkmark.circle")
                }
                .help("Select all")

                if !viewModel.selectedFiles.isEmpty {
                    Button(action: { viewModel.showDeleteConfirmation = true }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                    .help("Delete selected files")

                    Button(action: { viewModel.moveSelectedFiles() }) {
                        Image(systemName: "folder.badge.plus")
                    }
                    .help("Move selected files")
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    // MARK: - File List

    private var fileList: some View {
        ScrollView {
            LazyVStack(spacing: 2) {
                ForEach(viewModel.filteredFiles) { file in
                    FileRowView(
                        file: file,
                        isSelected: viewModel.selectedFiles.contains(file)
                    )
                    .onTapGesture {
                        handleFileTap(file)
                    }
                    .contextMenu {
                        fileContextMenu(for: file)
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
        }
    }

    // MARK: - Context Menu

    @ViewBuilder
    private func fileContextMenu(for file: FileItem) -> some View {
        Button(action: { viewModel.openFile(file) }) {
            Label("Open", systemImage: "arrow.up.forward.app")
        }

        Button(action: { viewModel.revealInFinder(file) }) {
            Label("Show in Finder", systemImage: "folder")
        }

        Divider()

        Button(action: {
            viewModel.selectedFiles = [file]
            viewModel.moveSelectedFiles()
        }) {
            Label("Move to...", systemImage: "folder.badge.plus")
        }

        Divider()

        Button(role: .destructive, action: {
            viewModel.deleteFiles([file])
        }) {
            Label("Delete Permanently", systemImage: "trash")
        }
    }

    // MARK: - Empty & Loading

    private var loadingView: some View {
        VStack(spacing: 12) {
            Spacer()
            ProgressView()
                .scaleEffect(1.2)
            Text("Scanning files...")
                .foregroundColor(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptyView: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.secondary.opacity(0.5))
            Text("No files found")
                .font(.title3)
                .foregroundColor(.secondary)
            if !viewModel.searchText.isEmpty {
                Text("Try a different search term")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Status Bar

    private var statusBar: some View {
        HStack {
            Text(viewModel.statusMessage)
                .font(.caption)
                .foregroundColor(.secondary)

            Spacer()

            if !viewModel.selectedFiles.isEmpty {
                Text("\(viewModel.selectedFiles.count) selected")
                    .font(.caption)
                    .foregroundColor(.accentColor)
            }

            Text("\(viewModel.filteredFiles.count) files · \(viewModel.formattedTotalSize)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
    }

    // MARK: - Helpers

    private func handleFileTap(_ file: FileItem) {
        if NSEvent.modifierFlags.contains(.command) {
            // Cmd + click: toggle selection
            if viewModel.selectedFiles.contains(file) {
                viewModel.selectedFiles.remove(file)
            } else {
                viewModel.selectedFiles.insert(file)
            }
        } else {
            // Normal click: single selection
            viewModel.selectedFiles = [file]
        }
        viewModel.selectedFileForPreview = file
    }
}
