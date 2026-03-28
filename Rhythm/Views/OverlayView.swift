import SwiftUI

/// 休息提醒的全屏半透明遮罩内容
struct OverlayView: View {
    @ObservedObject var viewModel: TimerViewModel

    var body: some View {
        ZStack {
            // 半透明黑色背景
            Color.black.opacity(0.78)
                .ignoresSafeArea()

            VStack(spacing: 40) {
                Text("该休息一下了")
                    .font(.system(size: 30, weight: .light, design: .rounded))
                    .foregroundStyle(.white.opacity(0.85))

                // 休息倒计时（大字体）
                Text(viewModel.formattedRemaining)
                    .font(.system(size: 100, weight: .thin, design: .monospaced))
                    .foregroundStyle(.white)

                // 跳过按钮（ESC 触发）
                Button {
                    viewModel.skipBreak()
                } label: {
                    Text("跳过  (ESC)")
                        .font(.system(size: 15))
                        .foregroundStyle(.white.opacity(0.65))
                        .padding(.horizontal, 28)
                        .padding(.vertical, 12)
                        .background(.white.opacity(0.12), in: Capsule())
                }
                .buttonStyle(.plain)
                .keyboardShortcut(.escape, modifiers: [])
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
