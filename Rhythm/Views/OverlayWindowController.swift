import AppKit
import SwiftUI

/// 管理全屏半透明遮罩窗口（覆盖所有显示器）
class OverlayWindowController {
    private var panels: [OverlayPanel] = []
    private let viewModel: TimerViewModel

    init(viewModel: TimerViewModel) {
        self.viewModel = viewModel
    }

    func show() {
        hide() // 先关闭旧窗口（防止重复）

        for screen in NSScreen.screens {
            let panel = OverlayPanel(
                contentRect: screen.frame,
                styleMask: [.borderless, .nonactivatingPanel],
                backing: .buffered,
                defer: false
            )
            // screenSaver 层级——覆盖一切，包括菜单栏
            panel.level = .screenSaver
            panel.isOpaque = false
            panel.backgroundColor = .clear
            panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
            panel.isMovable = false
            panel.onEscape = { [weak self] in
                self?.viewModel.skipBreak()
            }

            // contentView.frame 必须用局部坐标（相对于 panel），而非屏幕全局坐标
            // 否则在副显示器上内容会错位
            let contentView = NSHostingView(rootView: OverlayView(viewModel: viewModel))
            contentView.frame = NSRect(origin: .zero, size: screen.frame.size)
            panel.contentView = contentView
            panel.setFrame(screen.frame, display: false)
            panel.orderFrontRegardless()
            panels.append(panel)
        }

        // 激活 App，使 ESC 键可被捕获
        NSApp.activate(ignoringOtherApps: true)
        panels.first?.makeKey()
    }

    func hide() {
        panels.forEach { $0.close() }
        panels.removeAll()
    }
}

// MARK: - 自定义 NSPanel，拦截 ESC 键

class OverlayPanel: NSPanel {
    var onEscape: (() -> Void)?

    override var canBecomeKey: Bool { true }

    override func keyDown(with event: NSEvent) {
        if event.keyCode == 53 { // ESC
            onEscape?()
        } else {
            super.keyDown(with: event)
        }
    }
}
