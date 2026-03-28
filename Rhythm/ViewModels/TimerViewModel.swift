import Foundation
import Combine

enum TimerPhase {
    case working
    case resting
    case paused
}

class TimerViewModel: ObservableObject {
    // MARK: - Published State
    @Published var phase: TimerPhase = .working
    @Published var remainingSeconds: Int = 0
    @Published var isOverlayVisible: Bool = false

    // MARK: - Dependencies
    let settings = UserSettings()
    private let screenLockMonitor = ScreenLockMonitor()
    private var timer: Timer?

    // MARK: - Computed Properties

    var formattedRemaining: String {
        let m = remainingSeconds / 60
        let s = remainingSeconds % 60
        return String(format: "%02d:%02d", m, s)
    }

    var statusText: String {
        switch phase {
        case .working: return "工作中 · \(formattedRemaining)"
        case .resting: return "休息中 · \(formattedRemaining)"
        case .paused:  return "已暂停 · \(formattedRemaining)"
        }
    }

    var todayStats: (completed: Int, skipped: Int) {
        let records = DataStore.shared.todayRecords()
        return (records.filter { !$0.wasSkipped }.count,
                records.filter {  $0.wasSkipped }.count)
    }

    // MARK: - Init

    init() {
        remainingSeconds = settings.workDuration * 60
        setupLockMonitor()
        startWorkCountdown()
    }

    // MARK: - Public Controls

    func pause() {
        guard phase == .working else { return }
        phase = .paused
        stopTimer()
    }

    func resume() {
        guard phase == .paused else { return }
        phase = .working
        startTimer()
    }

    /// 重置工作计时器并重新开始（锁屏或手动重置时调用）
    func resetWorkTimer() {
        stopTimer()
        isOverlayVisible = false
        phase = .working
        remainingSeconds = settings.workDuration * 60
        startTimer()
    }

    /// 用户按 ESC 跳过本次休息
    /// guard 防止 OverlayPanel.keyDown 和 SwiftUI .keyboardShortcut 同时触发导致双重调用
    func skipBreak() {
        guard phase == .resting else { return }
        let elapsed = settings.breakDuration * 60 - remainingSeconds
        let record = BreakRecord(
            scheduledDuration: settings.breakDuration * 60,
            actualDuration: elapsed,
            wasSkipped: true,
            skipTime: elapsed
        )
        DataStore.shared.save(record: record)
        endBreak()
    }

    /// 更新设置后重新开始工作计时
    func applySettings() {
        if phase == .working || phase == .paused {
            resetWorkTimer()
        }
    }

    // MARK: - Private Timer Logic

    private func startWorkCountdown() {
        phase = .working
        remainingSeconds = settings.workDuration * 60
        startTimer()
    }

    private func startBreakCountdown() {
        phase = .resting
        remainingSeconds = settings.breakDuration * 60
        isOverlayVisible = true
        startTimer()
    }

    private func endBreak() {
        stopTimer()
        isOverlayVisible = false
        startWorkCountdown()
    }

    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.tick()
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func tick() {
        guard remainingSeconds > 0 else {
            handleTimerEnd()
            return
        }
        remainingSeconds -= 1
    }

    private func handleTimerEnd() {
        stopTimer()
        switch phase {
        case .working, .paused:
            // 工作时间到，触发休息
            startBreakCountdown()
        case .resting:
            // 休息自然结束
            let record = BreakRecord(
                scheduledDuration: settings.breakDuration * 60,
                actualDuration: settings.breakDuration * 60,
                wasSkipped: false
            )
            DataStore.shared.save(record: record)
            endBreak()
        }
    }

    // MARK: - Screen Lock

    private func setupLockMonitor() {
        screenLockMonitor.onLock = { [weak self] in
            guard let self, self.settings.resetOnLock else { return }
            DispatchQueue.main.async {
                // 只有在工作或暂停状态时才重置（休息中锁屏不重置）
                if self.phase == .working || self.phase == .paused {
                    self.resetWorkTimer()
                }
            }
        }
    }
}
