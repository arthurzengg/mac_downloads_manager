import Foundation

actor FileScanner {
    private let fileManager = FileManager.default

    /// Scan the Downloads directory and return all file items
    func scanDownloads() async -> [FileItem] {
        guard let downloadsURL = fileManager.urls(for: .downloadsDirectory, in: .userDomainMask).first else {
            return []
        }
        return scanDirectory(at: downloadsURL)
    }

    /// Scan a specific directory and return all file items (non-recursive)
    func scanDirectory(at url: URL) -> [FileItem] {
        let resourceKeys: Set<URLResourceKey> = [
            .fileSizeKey,
            .contentModificationDateKey,
            .creationDateKey,
            .isDirectoryKey,
            .isHiddenKey
        ]

        guard let enumerator = fileManager.enumerator(
            at: url,
            includingPropertiesForKeys: Array(resourceKeys),
            options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants]
        ) else {
            return []
        }

        var items: [FileItem] = []
        for case let fileURL as URL in enumerator {
            let item = FileItem(url: fileURL)
            items.append(item)
        }
        return items
    }
}
