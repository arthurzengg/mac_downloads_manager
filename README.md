# Downloads Manager

A native macOS application for managing files in the Downloads folder. Quickly browse, organize, preview, and clean up your downloads.

## Features

- **Categorize by Type**: Images, Documents, Videos, Audio, Archives, Applications, Code, Folders, and more
- **Group by Size**: Tiny (<1MB), Small (1-10MB), Medium (10-100MB), Large (100MB-1GB), Huge (>1GB)
- **Filter by Date**: Today, This Week, This Month, Older
- **Folder Support**: Folders are categorized separately with accurate recursive size calculation
- **File Preview**: Quick preview for images and file metadata display
- **Duplicate Detection**: Detect duplicate files based on MD5 hash, with one-click cleanup
- **Permanent Delete**: Instantly free disk space — files are permanently deleted, not moved to Trash
- **Batch Operations**: Multi-select files (Cmd+Click) for batch delete or move
- **Move Files**: Move files to any folder via a system folder picker
- **Search & Sort**: Search by filename, sort by name, size, or date

## Layout

The app features a three-column layout:

| Sidebar | File List | Preview Panel |
|---------|-----------|---------------|
| Browse by type, size, or duplicates | Search, sort, and multi-select files | View file details and perform actions |

## Build & Run

Requires **macOS 14+** and **Xcode** with Swift 5.9+.

```bash
git clone https://github.com/arthurzengg/mac_downloads_manager.git
cd mac_downloads_manager
bash build.sh
open ".build/Downloads Manager.app"
```

## Tech Stack

- **Swift 5.9+** — Language
- **SwiftUI** — UI framework (NavigationSplitView three-column layout)
- **CryptoKit** — MD5 hashing for duplicate detection
- **FileManager** — File scanning, deletion, and move operations

## Project Structure

```
Sources/DownloadsManager/
├── App.swift                          # App entry point
├── Models/
│   ├── FileCategory.swift             # Type/size/date enums
│   └── FileItem.swift                 # File data model
├── ViewModels/
│   └── FileManagerViewModel.swift     # Core business logic
├── Views/
│   ├── ContentView.swift              # Three-column main layout
│   ├── SidebarView.swift              # Sidebar navigation
│   ├── FileListView.swift             # File list with search/sort
│   ├── FileRowView.swift              # Single file row
│   ├── FilePreviewView.swift          # Preview panel
│   └── DuplicateView.swift            # Duplicate detection UI
└── Utilities/
    ├── FileScanner.swift              # Downloads folder scanner
    ├── DuplicateDetector.swift        # MD5-based duplicate finder
    └── FileSizeFormatter.swift        # Human-readable file sizes
```

## License

MIT
