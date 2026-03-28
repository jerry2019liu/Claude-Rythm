import AppKit
import Combine

class AppDelegate: NSObject, NSApplicationDelegate {
    let timerViewModel = TimerViewModel()

    private var overlayController: OverlayWindowController?
    private var cancellables = Set<AnyCancellable>()

    func applicationDidFinishLaunching(_ notification: Notification) {
        overlayController = OverlayWindowController(viewModel: timerViewModel)

        timerViewModel.$isOverlayVisible
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isVisible in
                if isVisible {
                    self?.overlayController?.show()
                } else {
                    self?.overlayController?.hide()
                }
            }
            .store(in: &cancellables)
    }
}
