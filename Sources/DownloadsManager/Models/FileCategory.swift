import Foundation
import SwiftUI

// MARK: - File Type Category

enum FileCategory: String, CaseIterable, Identifiable {
    case all = "All Files"
    case images = "Images"
    case documents = "Documents"
    case videos = "Videos"
    case audio = "Audio"
    case archives = "Archives"
    case applications = "Applications"
    case code = "Code"
    case other = "Other"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .all: return "folder.fill"
        case .images: return "photo.fill"
        case .documents: return "doc.fill"
        case .videos: return "film.fill"
        case .audio: return "music.note"
        case .archives: return "archivebox.fill"
        case .applications: return "app.fill"
        case .code: return "chevron.left.forwardslash.chevron.right"
        case .other: return "questionmark.folder.fill"
        }
    }

    var color: Color {
        switch self {
        case .all: return .blue
        case .images: return .green
        case .documents: return .orange
        case .videos: return .purple
        case .audio: return .pink
        case .archives: return .yellow
        case .applications: return .red
        case .code: return .cyan
        case .other: return .gray
        }
    }

    var extensions: Set<String> {
        switch self {
        case .all: return []
        case .images: return ["jpg", "jpeg", "png", "gif", "webp", "svg", "heic", "heif", "tiff", "tif", "bmp", "ico"]
        case .documents: return ["pdf", "doc", "docx", "xls", "xlsx", "ppt", "pptx", "txt", "md", "rtf", "csv", "pages", "numbers", "keynote"]
        case .videos: return ["mp4", "mov", "avi", "mkv", "wmv", "flv", "webm", "m4v"]
        case .audio: return ["mp3", "wav", "aac", "flac", "m4a", "ogg", "wma", "aiff"]
        case .archives: return ["zip", "rar", "7z", "tar", "gz", "bz2", "xz", "tgz"]
        case .applications: return ["app", "dmg", "pkg", "iso"]
        case .code: return ["py", "js", "ts", "jsx", "tsx", "swift", "java", "c", "cpp", "h", "hpp", "go", "rs", "rb", "php", "html", "css", "scss", "json", "xml", "yaml", "yml", "sh", "sql"]
        case .other: return []
        }
    }

    static func category(for fileExtension: String) -> FileCategory {
        let ext = fileExtension.lowercased()
        for category in FileCategory.allCases {
            if category == .all || category == .other { continue }
            if category.extensions.contains(ext) {
                return category
            }
        }
        return .other
    }
}

// MARK: - File Size Category

enum FileSizeCategory: String, CaseIterable, Identifiable {
    case tiny = "Tiny (<1MB)"
    case small = "Small (1-10MB)"
    case medium = "Medium (10-100MB)"
    case large = "Large (100MB-1GB)"
    case huge = "Huge (>1GB)"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .tiny: return "circle.fill"
        case .small: return "circle.lefthalf.filled"
        case .medium: return "circle.inset.filled"
        case .large: return "largecircle.fill.circle"
        case .huge: return "exclamationmark.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .tiny: return .green
        case .small: return .blue
        case .medium: return .yellow
        case .large: return .orange
        case .huge: return .red
        }
    }

    static func category(for size: Int64) -> FileSizeCategory {
        let mb: Int64 = 1_024 * 1_024
        let gb: Int64 = 1_024 * mb
        switch size {
        case ..<mb: return .tiny
        case mb..<(10 * mb): return .small
        case (10 * mb)..<(100 * mb): return .medium
        case (100 * mb)..<gb: return .large
        default: return .huge
        }
    }
}

// MARK: - Date Filter

enum DateFilter: String, CaseIterable, Identifiable {
    case all = "All Dates"
    case today = "Today"
    case thisWeek = "This Week"
    case thisMonth = "This Month"
    case older = "Older"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .all: return "calendar"
        case .today: return "sun.max.fill"
        case .thisWeek: return "calendar.badge.clock"
        case .thisMonth: return "calendar.circle"
        case .older: return "clock.arrow.circlepath"
        }
    }

    func matches(date: Date) -> Bool {
        let calendar = Calendar.current
        let now = Date()
        switch self {
        case .all:
            return true
        case .today:
            return calendar.isDateInToday(date)
        case .thisWeek:
            return calendar.isDate(date, equalTo: now, toGranularity: .weekOfYear)
        case .thisMonth:
            return calendar.isDate(date, equalTo: now, toGranularity: .month)
        case .older:
            let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
            return date < startOfMonth
        }
    }
}

// MARK: - Sort Option

enum SortOption: String, CaseIterable, Identifiable {
    case name = "Name"
    case size = "Size"
    case dateModified = "Date Modified"
    case dateCreated = "Date Created"

    var id: String { rawValue }
}

enum SortDirection {
    case ascending
    case descending

    mutating func toggle() {
        self = (self == .ascending) ? .descending : .ascending
    }
}

// MARK: - Sidebar Selection

enum SidebarItem: Hashable {
    case all
    case category(FileCategory)
    case sizeCategory(FileSizeCategory)
    case duplicates
}
