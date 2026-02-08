import SwiftUI

@main
struct DownloadsManagerApp: App {
    @StateObject private var viewModel = FileManagerViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .frame(minWidth: 900, minHeight: 600)
        }
        .windowStyle(.titleBar)
        .defaultSize(width: 1200, height: 750)
    }
}
