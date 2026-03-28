# Rhythm - macOS 休息提醒应用 设计文档

## 1. 项目概述

**Rhythm** 是一款 macOS 原生应用，帮助用户在长时间使用电脑时保持健康的休息节奏。应用运行在菜单栏（Menu Bar），通过全屏半透明遮罩提醒用户休息，并记录用户的休息行为数据。

**技术栈：** Swift + SwiftUI，原生 macOS 开发

**最低系统要求：** macOS 13.0 (Ventura)

---

## 2. 核心功能（一期）

### 2.1 自定义休息节奏

用户可以设置：

- **工作间隔时长**：两次休息之间的时间（默认 25 分钟，范围 5~120 分钟）
- **休息时长**：每次休息的持续时间（默认 5 分钟，范围 1~30 分钟）
- 计时器在应用启动后自动开始倒计时

### 2.2 锁屏重置计时器

- 监听系统锁屏事件（`NSWorkspace.screensDidSleepNotification` / `com.apple.screenIsLocked`）
- 当检测到锁屏时，**立即重置工作计时器**，从零开始重新计时
- 逻辑：锁屏意味着用户已经离开电脑休息了，无需再次提醒

### 2.3 全屏半透明遮罩提醒

- 工作时间到达后，弹出**全屏半透明遮罩**（黑色，透明度约 70%）
- 遮罩覆盖所有屏幕（多显示器支持）
- 遮罩中央显示：
  - 休息倒计时（大字体）
  - "该休息了" 提示文字
  - "跳过 (ESC)" 按钮
- 按 **ESC** 键可立即关闭遮罩，跳过本次休息
- 休息倒计时结束后，遮罩自动消失

### 2.4 用户数据记录

记录每次休息事件，字段包括：

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | UUID | 唯一标识 |
| `timestamp` | Date | 休息触发时间 |
| `scheduledDuration` | Int | 计划休息时长（秒） |
| `actualDuration` | Int | 实际休息时长（秒） |
| `wasSkipped` | Bool | 是否被 ESC 跳过 |
| `skipTime` | Int? | 跳过时距离开始已过的秒数（如未跳过则为 nil） |

**存储方式：** 使用 SwiftData（或 JSON 文件）持久化到本地 `~/Library/Application Support/Rhythm/`

---

## 3. 应用架构

```
Rhythm/
├── RhythmApp.swift              # 应用入口，菜单栏应用配置
├── Models/
│   ├── BreakRecord.swift         # 休息记录数据模型
│   └── UserSettings.swift        # 用户设置模型
├── ViewModels/
│   └── TimerViewModel.swift      # 核心计时逻辑
├── Views/
│   ├── MenuBarView.swift         # 菜单栏下拉菜单 UI
│   ├── OverlayWindow.swift       # 全屏遮罩窗口
│   ├── OverlayView.swift         # 遮罩内容视图
│   └── SettingsView.swift        # 设置界面
├── Services/
│   ├── ScreenLockMonitor.swift   # 锁屏监听服务
│   └── DataStore.swift           # 数据持久化服务
└── Resources/
    └── Assets.xcassets           # 图标等资源
```

### 3.1 关键组件说明

**RhythmApp（应用入口）**
- 配置为菜单栏应用（`MenuBarExtra`），无 Dock 图标
- 管理应用生命周期

**TimerViewModel（核心逻辑）**
- 维护工作倒计时状态
- 当倒计时归零时触发休息提醒
- 响应锁屏事件重置计时器
- 管理休息倒计时

**OverlayWindow（遮罩窗口）**
- `NSPanel` 子类，设置为：
  - `level: .screenSaver`（覆盖一切）
  - `styleMask: [.borderless, .fullSizeContentView]`
  - `isOpaque: false`，背景透明
  - 覆盖所有显示器（`NSScreen.screens`）
- 监听 ESC 键事件

**ScreenLockMonitor（锁屏监听）**
- 使用 `DistributedNotificationCenter` 监听：
  - `com.apple.screenIsLocked` → 重置计时
  - `com.apple.screenIsUnlocked` → 可选：开始新一轮计时

---

## 4. 用户界面设计

### 4.1 菜单栏图标

- 菜单栏显示一个简洁的节拍/节奏图标
- 点击后显示下拉菜单：
  - 当前状态（"工作中 - 剩余 18:32"）
  - 暂停 / 继续
  - 今日统计（完成 X 次休息，跳过 X 次）
  - 设置...
  - 退出

### 4.2 设置界面

简洁的 SwiftUI 设置窗口：
- 工作间隔：滑块 + 数字输入（5~120 分钟）
- 休息时长：滑块 + 数字输入（1~30 分钟）
- 开机自启动 开关
- 锁屏重置计时器 开关（默认开启）

### 4.3 休息遮罩界面

```
┌─────────────────────────────────────┐
│                                     │
│          半透明黑色背景（70%）         │
│                                     │
│            🕐 04:32                 │
│          该休息一下了                 │
│                                     │
│          [ 跳过 (ESC) ]              │
│                                     │
└─────────────────────────────────────┘
```

---

## 5. 数据流

```
应用启动
  └→ 加载用户设置
  └→ 启动工作倒计时
  └→ 启动锁屏监听
       │
       ├─ [锁屏事件] → 重置工作倒计时 → 重新开始
       │
       └─ [倒计时归零] → 显示全屏遮罩 → 开始休息倒计时
                              │
                              ├─ [ESC 跳过] → 记录（skipped=true）→ 关闭遮罩 → 重置工作倒计时
                              │
                              └─ [休息完成] → 记录（skipped=false）→ 关闭遮罩 → 重置工作倒计时
```

---

## 6. 项目结构（Git 仓库）

```
Rhythm/
├── README.md                    # 项目介绍
├── LICENSE                      # 开源协议（MIT）
├── .gitignore                   # Xcode + Swift 忽略规则
├── Rhythm.xcodeproj/            # Xcode 项目文件
└── Rhythm/                      # 源代码目录
    ├── RhythmApp.swift
    ├── Models/
    ├── ViewModels/
    ├── Views/
    ├── Services/
    └── Resources/
```

---

## 7. 一期里程碑

| 阶段 | 内容 | 预期 |
|------|------|------|
| M1 | 项目搭建 + 菜单栏应用骨架 | 基本运行 |
| M2 | 计时器逻辑 + 全屏遮罩 | 核心功能可用 |
| M3 | 锁屏监听 + 设置界面 | 功能完整 |
| M4 | 数据记录 + 今日统计 | 数据可追溯 |
| M5 | 打磨 UI + 开机自启 + GitHub 发布 | 可发布状态 |

---

## 8. 待确认事项

1. 是否需要声音提醒（休息开始时播放提示音）？
2. 数据是否需要导出功能（如导出 CSV）？
3. 是否考虑长休息（如每 4 个短休息后一个 15 分钟长休息，类似番茄钟）？
4. 开源协议偏好（建议 MIT）？
