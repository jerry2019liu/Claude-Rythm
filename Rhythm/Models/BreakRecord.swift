import Foundation

/// 记录每次休息的详细信息，持久化到本地 JSON 文件
struct BreakRecord: Codable, Identifiable {
    var id: UUID
    var timestamp: Date       // 休息开始的时间
    var scheduledDuration: Int // 计划休息时长（秒）
    var actualDuration: Int    // 实际休息时长（秒）
    var wasSkipped: Bool       // 是否按 ESC 跳过
    var skipTime: Int?         // 跳过时距离开始已过的秒数（未跳过则为 nil）

    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        scheduledDuration: Int,
        actualDuration: Int,
        wasSkipped: Bool,
        skipTime: Int? = nil
    ) {
        self.id                = id
        self.timestamp         = timestamp
        self.scheduledDuration = scheduledDuration
        self.actualDuration    = actualDuration
        self.wasSkipped        = wasSkipped
        self.skipTime          = skipTime
    }
}
