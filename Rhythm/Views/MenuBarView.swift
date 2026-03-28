import SwiftUI
import AppKit

struct MenuBarView: View {
    @ObservedObject var viewModel: TimerViewModel

    var body: some View {
        // 当前状态行
        Text(viewModel.statusText)
            .font(.system(size: 13, weight: .medium))

        Divider()

        // 今日统计
        let stats = viewModel.todayStats
        Text("今日：完成 \(stats.completed) 次 · 跳过 \(stats.skipped) 次")
            .font(.system(size: 12))
            .foregroundStyle(.secondary)

        Divider()

        // 控制按钮
        if viewModel.phase == .paused {
            Button("继续") { viewModel.resume() }
        } else if viewModel.phase == .working {
            Button("暂停") { viewModel.pause() }
        }

        Button("重置计时器") { viewModel.resetWorkTimer() }

        Divider()

        Button("设置...") {
            NSApp.activate(ignoringOtherApps: true)
            // macOS 13 兼容写法：通过 Action 打开 SwiftUI Settings 场景
            NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        }

        Divider()

        Button("退出 Rhythm") {
            NSApplication.shared.terminate(nil)
        }
    }
}
