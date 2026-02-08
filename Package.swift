// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "DownloadsManager",
    platforms: [
        .macOS(.v14)
    ],
    targets: [
        .executableTarget(
            name: "DownloadsManager",
            path: "Sources/DownloadsManager",
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        )
    ]
)
