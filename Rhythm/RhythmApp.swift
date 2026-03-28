import SwiftUI

@main
struct RhythmApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        MenuBarExtra("Rhythm", systemImage: "waveform") {
            MenuBarView(viewModel: appDelegate.timerViewModel)
        }
        .menuBarExtraStyle(.menu)

        Settings {
            SettingsView(viewModel: appDelegate.timerViewModel)
        }
    }
}
