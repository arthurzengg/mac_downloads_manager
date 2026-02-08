import SwiftUI
import QuickLookUI
import AppKit

struct FilePreviewView: View {
    @EnvironmentObject var viewModel: FileManagerViewModel
    let file: FileItem?

    var body: some View {
        if let file = file {
            VStack(spacing: 0) {
                // Preview area
                previewContent(for: file)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                Divider()

                // File details
                fileDetails(for: file)

                Divider()

                // Action buttons
                actionButtons(for: file)
            }
        } else {
            emptyPreview
        }
    }

    // MARK: - Preview Content

    @ViewBuilder
    private func previewContent(for file: FileItem) -> some View {
        switch file.category {
        case .images:
            imagePreview(for: file)
        default:
            genericPreview(for: file)
        }
    }

    private func imagePreview(for file: FileItem) -> some View {
        VStack {
            if let nsImage = NSImage(contentsOf: file.url) {
                Image(nsImage: nsImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(nsColor: .controlBackgroundColor))
                    )
                    .padding(12)
            } else {
                genericPreview(for: file)
            }
        }
    }

    private func genericPreview(for file: FileItem) -> some View {
        VStack(spacing: 16) {
            Spacer()

            // Large file icon
            Image(systemName: file.iconName)
                .font(.system(size: 64))
                .foregroundColor(file.iconColor)

            Text(file.name)
                .font(.headline)
                .lineLimit(2)
                .multilineTextAlignment(.center)

            Text(file.formattedSize)
                .font(.title3)
                .foregroundColor(.secondary)

            Spacer()
        }
        .padding()
    }

    // MARK: - File Details

    private func fileDetails(for file: FileItem) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            detailRow(label: "Name", value: file.name)
            detailRow(label: "Type", value: file.category.rawValue + " (.\(file.fileExtension))")
            detailRow(label: "Size", value: file.formattedSize)
            detailRow(label: "Modified", value: file.formattedDateModified)
            detailRow(label: "Created", value: file.formattedDateCreated)
            detailRow(label: "Path", value: file.url.path)
        }
        .padding(12)
    }

    private func detailRow(label: String, value: String) -> some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 60, alignment: .trailing)
            Text(value)
                .font(.caption)
                .lineLimit(1)
                .truncationMode(.middle)
        }
    }

    // MARK: - Action Buttons

    private func actionButtons(for file: FileItem) -> some View {
        HStack(spacing: 12) {
            Button(action: { viewModel.openFile(file) }) {
                Label("Open", systemImage: "arrow.up.forward.app")
            }
            .buttonStyle(.bordered)

            Button(action: { viewModel.revealInFinder(file) }) {
                Label("Finder", systemImage: "folder")
            }
            .buttonStyle(.bordered)

            Button(action: {
                viewModel.selectedFiles = [file]
                viewModel.moveSelectedFiles()
            }) {
                Label("Move", systemImage: "folder.badge.plus")
            }
            .buttonStyle(.bordered)

            Button(role: .destructive, action: {
                viewModel.deleteFiles([file])
            }) {
                Label("Delete", systemImage: "trash")
            }
            .buttonStyle(.bordered)
            .tint(.red)
        }
        .padding(12)
    }

    // MARK: - Empty

    private var emptyPreview: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "eye.slash")
                .font(.system(size: 40))
                .foregroundColor(.secondary.opacity(0.4))
            Text("Select a file to preview")
                .font(.headline)
                .foregroundColor(.secondary)
            Text("Click a file from the list on the left")
                .font(.caption)
                .foregroundColor(.secondary.opacity(0.7))
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
