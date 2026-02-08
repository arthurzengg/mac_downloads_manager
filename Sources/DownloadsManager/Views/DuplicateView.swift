import SwiftUI

struct DuplicateView: View {
    @EnvironmentObject var viewModel: FileManagerViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Header
            duplicateHeader

            Divider()

            if viewModel.isDetectingDuplicates {
                loadingView
            } else if viewModel.duplicateGroups.isEmpty {
                emptyView
            } else {
                duplicateList
            }
        }
    }

    // MARK: - Header

    private var duplicateHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Duplicate Detection")
                    .font(.headline)
                if !viewModel.duplicateGroups.isEmpty {
                    let totalWasted = viewModel.duplicateGroups.reduce(Int64(0)) { $0 + $1.wastedSpace }
                    Text("Found \(viewModel.duplicateGroups.count) duplicate groups. \(FileSizeFormatter.format(bytes: totalWasted)) can be freed.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Button(action: { viewModel.detectDuplicates() }) {
                Label(
                    viewModel.duplicateGroups.isEmpty ? "Start Scan" : "Rescan",
                    systemImage: "doc.on.doc"
                )
            }
            .buttonStyle(.bordered)
            .disabled(viewModel.isDetectingDuplicates || viewModel.allFiles.isEmpty)
        }
        .padding(12)
    }

    // MARK: - Duplicate List

    private var duplicateList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.duplicateGroups) { group in
                    DuplicateGroupCard(group: group)
                }
            }
            .padding(12)
        }
    }

    // MARK: - Empty & Loading

    private var loadingView: some View {
        VStack(spacing: 12) {
            Spacer()
            ProgressView()
                .scaleEffect(1.2)
            Text("Detecting duplicate files...")
                .foregroundColor(.secondary)
            Text("This may take a while depending on the number and size of files")
                .font(.caption)
                .foregroundColor(.secondary.opacity(0.7))
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptyView: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "checkmark.circle")
                .font(.system(size: 48))
                .foregroundColor(.green.opacity(0.5))
            Text("No duplicates found")
                .font(.title3)
                .foregroundColor(.secondary)
            Text("Click \"Start Scan\" to detect duplicate files")
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Duplicate Group Card

struct DuplicateGroupCard: View {
    @EnvironmentObject var viewModel: FileManagerViewModel
    let group: DuplicateGroup
    @State private var selectedToKeep: FileItem?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Group header
            HStack {
                Image(systemName: "doc.on.doc.fill")
                    .foregroundColor(.orange)
                Text("\(group.files.count) identical files")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text("· \(group.formattedSize) each")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Text("Can free \(group.formattedWastedSpace)")
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.red.opacity(0.1))
                    .clipShape(Capsule())
            }

            Divider()

            // File list
            ForEach(group.files) { file in
                HStack(spacing: 10) {
                    // Radio-like selection
                    Image(systemName: selectedToKeep == file ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(selectedToKeep == file ? .green : .secondary)
                        .onTapGesture {
                            selectedToKeep = file
                        }

                    Image(systemName: file.iconName)
                        .foregroundColor(file.iconColor)
                        .frame(width: 20)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(file.name)
                            .font(.caption)
                            .lineLimit(1)
                        Text(file.url.deletingLastPathComponent().path)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }

                    Spacer()

                    Text(file.formattedDateModified)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 2)
            }

            // Delete button
            if selectedToKeep != nil {
                HStack {
                    Spacer()
                    Button(action: deleteOtherFiles) {
                        Label("Delete Other Copies", systemImage: "trash")
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                }
            }
        }
        .padding(12)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(10)
    }

    private func deleteOtherFiles() {
        guard let keeper = selectedToKeep else { return }
        let filesToDelete = group.files.filter { $0 != keeper }
        viewModel.deleteFiles(filesToDelete)
    }
}
