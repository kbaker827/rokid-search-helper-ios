import Foundation

enum SearchState {
    case idle
    case searching
    case result(query: String, answer: String, source: String)
    case error(String)
}

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var query: String = ""
    @Published private(set) var state: SearchState = .idle

    let settingsStore: SettingsStore
    let history: SearchHistory
    let glassesServer: GlassesDisplayServer

    private let ddg = DuckDuckGoService()
    private let ai = OpenAiSearchService()

    init(settingsStore: SettingsStore, history: SearchHistory, glassesServer: GlassesDisplayServer) {
        self.settingsStore = settingsStore
        self.history = history
        self.glassesServer = glassesServer
    }

    func search() {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return }
        state = .searching

        Task {
            // 1. Try DuckDuckGo instant answers (free, no key)
            if let result = await ddg.instantAnswer(for: q) {
                finish(query: q, answer: result.answer, source: result.source)
                return
            }

            // 2. Try AI fallback if configured
            let s = settingsStore.settings
            if s.useAiFallback && !s.openAiApiKey.isEmpty {
                if let answer = await ai.answer(query: q, apiKey: s.openAiApiKey,
                                                baseUrl: s.openAiBaseUrl, model: s.openAiModel) {
                    finish(query: q, answer: answer, source: "AI (\(s.openAiModel))")
                    return
                }
            }

            // 3. No result
            state = .error("No answer found for "\(q)". Try rephrasing or add an AI API key in Settings.")
            glassesServer.sendClear()
        }
    }

    func clear() {
        state = .idle
        query = ""
        glassesServer.sendClear()
    }

    private func finish(query: String, answer: String, source: String) {
        let entry = SearchEntry(query: query, answer: answer, source: source)
        history.add(entry)
        state = .result(query: query, answer: answer, source: source)
        glassesServer.sendResult(query: query, answer: answer, source: source)
    }
}
