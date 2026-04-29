import Foundation

struct SearchEntry: Identifiable, Codable {
    let id: UUID
    let query: String
    let answer: String
    let source: String
    let timestamp: Date

    init(query: String, answer: String, source: String) {
        self.id = UUID()
        self.query = query
        self.answer = answer
        self.source = source
        self.timestamp = Date()
    }
}

@MainActor
final class SearchHistory: ObservableObject {
    @Published private(set) var entries: [SearchEntry] = []
    private let key = "rokid_search_history_v1"
    private let maxEntries = 50

    init() { load() }

    func add(_ entry: SearchEntry) {
        entries.insert(entry, at: 0)
        if entries.count > maxEntries { entries = Array(entries.prefix(maxEntries)) }
        save()
    }

    func clear() {
        entries.removeAll()
        save()
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([SearchEntry].self, from: data) else { return }
        entries = decoded
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}
