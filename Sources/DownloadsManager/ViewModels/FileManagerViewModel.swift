import Foundation
import SwiftUI
import AppKit

@MainActor
class FileManagerViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var allFiles: [FileItem] = []
    @Published var selectedSidebarItem: SidebarItem = .all
    @Published var selectedFiles: Set<FileItem> = []
    @Published var selectedFileForPreview: FileItem? = nil
    @Published var searchText: String = ""
    @Published var sortOption: SortOption = .dateModified
    @Published var sortDirection: SortDirection = .descending
    @Published var dateFilter: DateFilter = .all
    @Published var isLoading: Bool = false
    @Published var duplicateGroups: [DuplicateGroup] = []
    @Published var isDetectingDuplicates: Bool = false
    @Published var showDeleteConfirmation: Bool = false
    @Published var showMovePanel: Bool = false
    @Published var statusMessage: String = ""

    // MARK: - Private

    private let scanner = FileScanner()
    private let duplicateDetector = DuplicateDetector()

    // MARK: - Computed Properties

    var filteredFiles: [FileItem] {
        var files = allFiles

        // Filter by sidebar selection
        switch selectedSidebarItem {
        case .all:
            break
        case .category(let category):
            if category != .all {
                files = files.filter { $0.category == category }
            }
        case .sizeCategory(let sizeCategory):
            files = files.filter { $0.sizeCategory == sizeCategory }
        case .duplicates:
            let duplicateURLs = Set(duplicateGroups.flatMap { $0.files.map { $0.url } })
            files = files.filter { duplicateURLs.contains($0.url) }
        }

        // Filter by date
        if dateFilter != .all {
            files = files.filter { dateFilter.matches(date: $0.dateModified) }
        }

        // Filter by search text
        if !searchText.isEmpty {
            files = files.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }

        // Sort
        files.sort { a, b in
            let result: Bool
            switch sortOption {
            case .name:
                result = a.name.localizedCaseInsensitiveCompare(b.name) == .orderedAscending
            case .size:
                result = a.size < b.size
            case .dateModified:
                result = a.dateModified < b.dateModified
            case .dateCreated:
                result = a.dateCreated < b.dateCreated
            }
            return sortDirection == .ascending ? result : !result
        }

        return files
    }

    var totalSize: Int64 {
        filteredFiles.reduce(0) { $0 + $1.size }
    }

    var formattedTotalSize: String {
        FileSizeFormatter.format(bytes: totalSize)
    }

    // MARK: - Category Counts

    func fileCount(for category: FileCategory) -> Int {
        if category == .all {
            return allFiles.count
        }
        return allFiles.filter { $0.category == category }.count
    }

    func fileCount(for sizeCategory: FileSizeCategory) -> Int {
        allFiles.filter { $0.sizeCategory == sizeCategory }.count
    }

    func totalSize(for category: FileCategory) -> Int64 {
        if category == .all {
            return allFiles.reduce(0) { $0 + $1.size }
        }
        return allFiles.filter { $0.category == category }.reduce(0) { $0 + $1.size }
    }

    // MARK: - Actions

    func scanFiles() {
        isLoading = true
        statusMessage = "Scanning files..."
        Task {
            let files = await scanner.scanDownloads()
            self.allFiles = files
            self.isLoading = false
            self.statusMessage = "Scan complete. \(files.count) files found."
        }
    }

    func detectDuplicates() {
        isDetectingDuplicates = true
        statusMessage = "Detecting duplicates..."
        Task {
            let groups = await duplicateDetector.findDuplicates(in: allFiles)
            self.duplicateGroups = groups
            self.isDetectingDuplicates = false
            let totalDuplicates = groups.reduce(0) { $0 + $1.files.count - 1 }
            self.statusMessage = "Detection complete. Found \(groups.count) duplicate groups (\(totalDuplicates) removable)."
        }
    }

    func deleteSelectedFiles() {
        let filesToDelete = Array(selectedFiles)
        var deletedCount = 0

        for file in filesToDelete {
            do {
                try FileManager.default.removeItem(at: file.url)
                allFiles.removeAll { $0 == file }
                selectedFiles.remove(file)
                deletedCount += 1
            } catch {
                print("Failed to delete \(file.name): \(error)")
            }
        }

        if selectedFileForPreview != nil && !allFiles.contains(where: { $0 == selectedFileForPreview }) {
            selectedFileForPreview = nil
        }

        statusMessage = "Permanently deleted \(deletedCount) file(s)."

        // Refresh duplicate groups
        if !duplicateGroups.isEmpty {
            detectDuplicates()
        }
    }

    func deleteFiles(_ files: [FileItem]) {
        var deletedCount = 0
        for file in files {
            do {
                try FileManager.default.removeItem(at: file.url)
                allFiles.removeAll { $0 == file }
                selectedFiles.remove(file)
                deletedCount += 1
            } catch {
                print("Failed to delete \(file.name): \(error)")
            }
        }

        if selectedFileForPreview != nil && !allFiles.contains(where: { $0 == selectedFileForPreview }) {
            selectedFileForPreview = nil
        }

        statusMessage = "Permanently deleted \(deletedCount) file(s)."
    }

    func moveSelectedFiles() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.message = "Choose destination folder"
        panel.prompt = "Move Here"

        panel.begin { [weak self] response in
            guard let self = self, response == .OK, let destinationURL = panel.url else { return }

            Task { @MainActor in
                self.moveFiles(Array(self.selectedFiles), to: destinationURL)
            }
        }
    }

    func moveFiles(_ files: [FileItem], to destination: URL) {
        var movedCount = 0
        for file in files {
            let destinationFileURL = destination.appendingPathComponent(file.name)
            do {
                try FileManager.default.moveItem(at: file.url, to: destinationFileURL)
                allFiles.removeAll { $0 == file }
                selectedFiles.remove(file)
                movedCount += 1
            } catch {
                print("Failed to move \(file.name): \(error)")
            }
        }

        if selectedFileForPreview != nil && !allFiles.contains(where: { $0 == selectedFileForPreview }) {
            selectedFileForPreview = nil
        }

        statusMessage = "Moved \(movedCount) file(s)."
    }

    func openFile(_ file: FileItem) {
        NSWorkspace.shared.open(file.url)
    }

    func revealInFinder(_ file: FileItem) {
        NSWorkspace.shared.activateFileViewerSelecting([file.url])
    }

    func selectAll() {
        selectedFiles = Set(filteredFiles)
    }

    func deselectAll() {
        selectedFiles.removeAll()
    }

    func toggleSort(_ option: SortOption) {
        if sortOption == option {
            sortDirection.toggle()
        } else {
            sortOption = option
            sortDirection = .descending
        }
    }
}
