import SwiftUI

struct SidebarView: View {
    @EnvironmentObject var viewModel: FileManagerViewModel

    var body: some View {
        List(selection: $viewModel.selectedSidebarItem) {
            // All files
            sidebarRow(
                item: .all,
                icon: "folder.fill",
                label: "All Files",
                count: viewModel.fileCount(for: .all),
                color: .blue
            )

            // By type
            Section("By Type") {
                ForEach(FileCategory.allCases.filter { $0 != .all }) { category in
                    sidebarRow(
                        item: .category(category),
                        icon: category.icon,
                        label: category.rawValue,
                        count: viewModel.fileCount(for: category),
                        color: category.color
                    )
                }
            }

            // By size
            Section("By Size") {
                ForEach(FileSizeCategory.allCases) { sizeCategory in
                    sidebarRow(
                        item: .sizeCategory(sizeCategory),
                        icon: sizeCategory.icon,
                        label: sizeCategory.rawValue,
                        count: viewModel.fileCount(for: sizeCategory),
                        color: sizeCategory.color
                    )
                }
            }

            // Duplicates
            Section("Tools") {
                sidebarRow(
                    item: .duplicates,
                    icon: "doc.on.doc.fill",
                    label: "Duplicates",
                    count: viewModel.duplicateGroups.reduce(0) { $0 + $1.files.count },
                    color: .red
                )
            }
        }
        .listStyle(.sidebar)
        .frame(minWidth: 200)
    }

    @ViewBuilder
    private func sidebarRow(item: SidebarItem, icon: String, label: String, count: Int, color: Color) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 20)
            Text(label)
            Spacer()
            if count > 0 {
                Text("\(count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.secondary.opacity(0.15))
                    .clipShape(Capsule())
            }
        }
        .tag(item)
    }
}
