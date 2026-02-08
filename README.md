# Downloads Manager

A native macOS application for managing files in the Downloads folder.

## Features

- **Categorize by Type**: Images, Documents, Videos, Audio, Archives, Code, etc.
- **Group by Size**: Tiny, Small, Medium, Large, Huge
- **Filter by Date**: Today, This Week, This Month, Older
- **File Preview**: Quick preview for images, PDFs, and more
- **Duplicate Detection**: Detect duplicate files based on MD5 hash
- **Batch Operations**: Multi-select files for batch delete or move

## Screenshot

The app features a three-column layout:
- **Sidebar**: Browse files by type, size category, or find duplicates
- **File List**: Search, sort, and multi-select files (Cmd+Click)
- **Preview Panel**: View file details and perform actions

## Build & Run

Requires macOS 14+ and Xcode with Swift 5.9+.

```bash
cd mac_downloads_manager
bash build.sh
open ".build/Downloads Manager.app"
```

## Tech Stack

- Swift 5.9+
- SwiftUI
- CryptoKit (MD5 hashing)
- QuickLook (file preview)

## License

MIT
