import Foundation
import CryptoKit

struct DuplicateGroup: Identifiable {
    let id = UUID()
    let hash: String
    let size: Int64
    var files: [FileItem]

    var formattedSize: String {
        FileSizeFormatter.format(bytes: size)
    }

    var wastedSpace: Int64 {
        size * Int64(files.count - 1)
    }

    var formattedWastedSpace: String {
        FileSizeFormatter.format(bytes: wastedSpace)
    }
}

actor DuplicateDetector {
    /// Detect duplicate files based on file size + MD5 hash
    func findDuplicates(in files: [FileItem]) async -> [DuplicateGroup] {
        // Step 1: Group files by size (quick filter)
        let nonDirectoryFiles = files.filter { !$0.isDirectory && $0.size > 0 }
        var sizeGroups: [Int64: [FileItem]] = [:]
        for file in nonDirectoryFiles {
            sizeGroups[file.size, default: []].append(file)
        }

        // Only keep groups with 2+ files of the same size
        let potentialDuplicates = sizeGroups.filter { $0.value.count >= 2 }

        // Step 2: For same-size files, compute MD5 hash
        var duplicateGroups: [DuplicateGroup] = []

        for (size, sameFiles) in potentialDuplicates {
            var hashGroups: [String: [FileItem]] = [:]

            for file in sameFiles {
                if let hash = computeMD5(for: file.url) {
                    hashGroups[hash, default: []].append(file)
                }
            }

            // Keep only groups with actual duplicates (same hash)
            for (hash, hashFiles) in hashGroups where hashFiles.count >= 2 {
                let group = DuplicateGroup(hash: hash, size: size, files: hashFiles)
                duplicateGroups.append(group)
            }
        }

        // Sort by wasted space (largest first)
        duplicateGroups.sort { $0.wastedSpace > $1.wastedSpace }
        return duplicateGroups
    }

    /// Compute MD5 hash for a file
    private func computeMD5(for url: URL) -> String? {
        guard let data = try? Data(contentsOf: url) else {
            return nil
        }
        let digest = Insecure.MD5.hash(data: data)
        return digest.map { String(format: "%02hhx", $0) }.joined()
    }
}
