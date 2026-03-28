import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: TimerViewModel

    @State private var workMinutes: Double  = 25
    @State private var breakMinutes: Double = 5
    @State private var resetOnLock: Bool    = true

    var body: some View {
        Form {
            Section("时间设置") {
                HStack {
                    Text("工作间隔")
                    Spacer()
                    Slider(value: $workMinutes, in: 5...120, step: 1)
                        .frame(width: 180)
                    Text("\(Int(workMinutes)) 分钟")
                        .monospacedDigit()
                        .frame(width: 56, alignment: .trailing)
                }

                HStack {
                    Text("休息时长")
                    Spacer()
                    Slider(value: $breakMinutes, in: 1...30, step: 1)
                        .frame(width: 180)
                    Text("\(Int(breakMinutes)) 分钟")
                        .monospacedDigit()
                        .frame(width: 56, alignment: .trailing)
                }
            }

            Section("行为设置") {
                Toggle("锁屏后重置工作计时器", isOn: $resetOnLock)
            }

            Section {
                HStack {
                    Spacer()
                    Button("应用设置") {
                        viewModel.settings.workDuration  = Int(workMinutes)
                        viewModel.settings.breakDuration = Int(breakMinutes)
                        viewModel.settings.resetOnLock   = resetOnLock
                        viewModel.applySettings()
                    }
                    .keyboardShortcut(.return, modifiers: .command)
                }
            }
        }
        .formStyle(.grouped)
        .frame(width: 420, height: 260)
        .onAppear {
            workMinutes  = Double(viewModel.settings.workDuration)
            breakMinutes = Double(viewModel.settings.breakDuration)
            resetOnLock  = viewModel.settings.resetOnLock
        }
    }
}
