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

        self.dateModified = resourceValues?.contentModificationDate ?? Date.distantPast
        self.dateCreated = resourceValues?.creationDate ?? Date.distantPast
        self.isDirectory = resourceValues?.isDirectory ?? false

        // For directories, recursively calculate total size
        if self.isDirectory {
            self.size = FileItem.directorySize(at: url)
        } else {
            self.size = Int64(resourceValues?.fileSize ?? 0)
        }

        self.category = FileCategory.category(for: url.pathExtension, isDirectory: self.isDirectory)
        self.sizeCategory = FileSizeCategory.category(for: self.size)
    }

    /// Recursively calculate the total size of a directory
    private static func directorySize(at url: URL) -> Int64 {
        let fm = FileManager.default
        guard let enumerator = fm.enumerator(
            at: url,
            includingPropertiesForKeys: [.fileSizeKey, .isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) else {
            return 0
        }

        var totalSize: Int64 = 0
        for case let fileURL as URL in enumerator {
            let values = try? fileURL.resourceValues(forKeys: [.fileSizeKey, .isDirectoryKey])
            if values?.isDirectory == false {
                totalSize += Int64(values?.fileSize ?? 0)
            }
        }
        return totalSize
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
