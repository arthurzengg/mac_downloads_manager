import Foundation
import SwiftUI

struct FileItem: Identifiable, Hashable {
    let id: UUID
    let url: URL
    let name: String
    let fileExtension: String
    let size: Int64
    let dateModified: Date
    let dateCreated: Date
    let isDirectory: Bool
    let category: FileCategory
    let sizeCategory: FileSizeCategory

    init(url: URL) {
        self.id = UUID()
        self.url = url
        self.name = url.lastPathComponent
        self.fileExtension = url.pathExtension.lowercased()

        let resourceValues = try? url.resourceValues(forKeys: [
            .fileSizeKey,
            .contentModificationDateKey,
            .creationDateKey,
            .isDirectoryKey
        ])

        self.size = Int64(resourceValues?.fileSize ?? 0)
        self.dateModified = resourceValues?.contentModificationDate ?? Date.distantPast
        self.dateCreated = resourceValues?.creationDate ?? Date.distantPast
        self.isDirectory = resourceValues?.isDirectory ?? false
        self.category = FileCategory.category(for: url.pathExtension)
        self.sizeCategory = FileSizeCategory.category(for: self.size)
    }

    var formattedSize: String {
        FileSizeFormatter.format(bytes: size)
    }

    var formattedDateModified: String {
        FileItem.dateFormatter.string(from: dateModified)
    }

    var formattedDateCreated: String {
        FileItem.dateFormatter.string(from: dateCreated)
    }

    var iconName: String {
        if isDirectory {
            return "folder.fill"
        }
        return category.icon
    }

    var iconColor: Color {
        if isDirectory {
            return .blue
        }
        return category.color
    }

    // MARK: - Hashable

    static func == (lhs: FileItem, rhs: FileItem) -> Bool {
        lhs.url == rhs.url
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(url)
    }

    // MARK: - Private

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "en_US")
        return formatter
    }()
}
