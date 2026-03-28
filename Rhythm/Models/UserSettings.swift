import Foundation
import Combine

class UserSettings: ObservableObject {
    @Published var workDuration: Int {
        didSet { UserDefaults.standard.set(workDuration, forKey: Keys.workDuration) }
    }
    @Published var breakDuration: Int {
        didSet { UserDefaults.standard.set(breakDuration, forKey: Keys.breakDuration) }
    }
    @Published var resetOnLock: Bool {
        didSet { UserDefaults.standard.set(resetOnLock, forKey: Keys.resetOnLock) }
    }

    private enum Keys {
        static let workDuration  = "workDuration"
        static let breakDuration = "breakDuration"
        static let resetOnLock   = "resetOnLock"
    }

    init() {
        let d = UserDefaults.standard
        self.workDuration  = d.integer(forKey: Keys.workDuration)  > 0 ? d.integer(forKey: Keys.workDuration)  : 25
        self.breakDuration = d.integer(forKey: Keys.breakDuration) > 0 ? d.integer(forKey: Keys.breakDuration) : 5
        self.resetOnLock   = d.object(forKey: Keys.resetOnLock) as? Bool ?? true
    }
}
