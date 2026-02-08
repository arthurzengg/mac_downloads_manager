import SwiftUI

struct FileRowView: View {
    let file: FileItem
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 12) {
            // File icon
            Image(systemName: file.iconName)
                .font(.title2)
                .foregroundColor(file.iconColor)
                .frame(width: 32, height: 32)

            // File info
            VStack(alignment: .leading, spacing: 3) {
                Text(file.name)
                    .font(.body)
                    .lineLimit(1)
                    .truncationMode(.middle)

                HStack(spacing: 8) {
                    Text(file.formattedSize)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("·")
                        .foregroundColor(.secondary)

                    Text(file.formattedDateModified)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            // Category badge
            Text(file.category.rawValue)
                .font(.caption2)
                .foregroundColor(file.category.color)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(file.category.color.opacity(0.12))
                .clipShape(Capsule())
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .contentShape(Rectangle())
        .background(isSelected ? Color.accentColor.opacity(0.15) : Color.clear)
        .cornerRadius(6)
    }
}
