# Rhythm

> 帮助你找到使用电脑的节奏 — 一款轻量的 macOS 菜单栏休息提醒应用。

## 功能

- **自定义休息节奏** — 设置工作间隔时长（默认 25 分钟）和每次休息时长（默认 5 分钟）
- **全屏半透明遮罩** — 休息时间到，整个屏幕变暗，大字体倒计时，按 ESC 可跳过
- **锁屏自动重置** — 检测到锁屏或合盖后自动重置工作计时器，避免重复提醒
- **数据记录** — 每次休息的实际时长、是否跳过，本地 JSON 持久化存储
- **菜单栏常驻** — 无 Dock 图标，轻量运行，不打扰工作流

## 系统要求

- macOS 13.0 (Ventura) 或更高版本
- Xcode 15.0+（编译）

## 快速开始

```bash
git clone https://github.com/your-username/rhythm.git
cd rhythm
open Rhythm.xcodeproj
```

在 Xcode 中：
1. 选择你的开发团队（Signing & Capabilities → Team）
2. 按 `Cmd+R` 运行

## 项目结构

```
Rhythm/
├── RhythmApp.swift              # 应用入口，MenuBarExtra 配置
├── AppDelegate.swift            # 生命周期管理，遮罩窗口控制
├── Models/
│   ├── UserSettings.swift       # 用户设置（UserDefaults）
│   └── BreakRecord.swift        # 休息记录数据模型
├── ViewModels/
│   └── TimerViewModel.swift     # 核心计时逻辑
├── Views/
│   ├── MenuBarView.swift        # 菜单栏下拉菜单
│   ├── OverlayWindowController.swift  # 全屏遮罩窗口管理
│   ├── OverlayView.swift        # 遮罩 UI（倒计时 + 跳过按钮）
│   └── SettingsView.swift       # 设置界面
├── Services/
│   ├── ScreenLockMonitor.swift  # 锁屏 / 屏幕休眠监听
│   └── DataStore.swift          # JSON 数据持久化
└── Resources/
    └── Info.plist               # 应用配置（LSUIElement = true）
```

## 数据存储

休息记录保存在：

```
~/Library/Application Support/Rhythm/break_records.json
```

每条记录包含：休息触发时间、计划时长、实际时长、是否跳过、跳过时刻。

## 许可证

MIT License — 详见 [LICENSE](LICENSE)
