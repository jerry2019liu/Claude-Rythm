import Foundation
import AppKit

/// 监听系统锁屏和屏幕休眠事件
class ScreenLockMonitor {
    var onLock: (() -> Void)?
    var onUnlock: (() -> Void)?

    private var dncObservers: [Any] = []
    private var wsObservers:  [Any] = []

    init() {
        let dnc = DistributedNotificationCenter.default()

        // 系统锁屏通知
        dncObservers.append(
            dnc.addObserver(forName: .init("com.apple.screenIsLocked"),
                            object: nil, queue: .main) { [weak self] _ in
                self?.onLock?()
            }
        )

        // 系统解锁通知
        dncObservers.append(
            dnc.addObserver(forName: .init("com.apple.screenIsUnlocked"),
                            object: nil, queue: .main) { [weak self] _ in
                self?.onUnlock?()
            }
        )

        // 屏幕休眠（合盖 / 节能）也视为离开
        wsObservers.append(
            NSWorkspace.shared.notificationCenter.addObserver(
                forName: NSWorkspace.screensDidSleepNotification,
                object: nil, queue: .main) { [weak self] _ in
                    self?.onLock?()
                }
        )
    }

    deinit {
        let dnc = DistributedNotificationCenter.default()
        dncObservers.forEach { dnc.removeObserver($0) }
        wsObservers.forEach  { NSWorkspace.shared.notificationCenter.removeObserver($0) }
    }
}
