import Foundation
import Observation

/// The only owner of task data (design §10). Saves to `UserDefaults` after every mutation.
@MainActor @Observable final class TaskStore {
    /// Newest first.
    private(set) var tasks: [TaskItem]

    var completedCount: Int { tasks.filter(\.isComplete).count }
    var progress: Double { tasks.isEmpty ? 0 : Double(completedCount) / Double(tasks.count) }

    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private let key: String

    init(defaults: UserDefaults = .standard, key: String = "tasks") {
        self.defaults = defaults
        self.key = key
        guard let data = defaults.data(forKey: key) else {
            tasks = []
            return
        }
        do {
            tasks = try JSONDecoder().decode([TaskItem].self, from: data)
        } catch {
            // Keep the only copy before the next save overwrites it (design §13).
            defaults.set(data, forKey: "\(key).corrupt")
            tasks = []
        }
    }

    func add(title: String, category: TaskCategory) {
        let title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { return }
        tasks.insert(TaskItem(title: title, category: category), at: 0)
        save()
    }

    func toggle(_ id: TaskItem.ID) {
        guard let index = tasks.firstIndex(where: { $0.id == id }) else { return }
        tasks[index].isComplete.toggle()
        save()
    }

    func remove(_ id: TaskItem.ID) {
        tasks.removeAll { $0.id == id }
        save()
    }

    func clearCompleted() {
        tasks.removeAll { $0.isComplete }
        save()
    }

    private func save() {
        // Encoding plain value types cannot fail in practice; skip the write rather than crash.
        guard let data = try? JSONEncoder().encode(tasks) else { return }
        defaults.set(data, forKey: key)
    }
}
