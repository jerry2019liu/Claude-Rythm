import Foundation

/// 将休息记录持久化到 ~/Library/Application Support/Rhythm/break_records.json
final class DataStore {
    static let shared = DataStore()

    private(set) var records: [BreakRecord] = []

    private var fileURL: URL {
        let appSupport = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let dir = appSupport.appendingPathComponent("Rhythm", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent("break_records.json")
    }

    private init() { load() }

    // MARK: - Public

    func save(record: BreakRecord) {
        records.append(record)
        persist()
    }

    func todayRecords() -> [BreakRecord] {
        records.filter { Calendar.current.isDateInToday($0.timestamp) }
    }

    func allRecords() -> [BreakRecord] { records }

    // MARK: - Private

    private func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([BreakRecord].self, from: data)
        else { return }
        records = decoded
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(records) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
