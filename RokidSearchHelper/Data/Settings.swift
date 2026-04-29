import Foundation

struct Settings: Codable {
    var openAiApiKey: String = ""
    var openAiBaseUrl: String = "https://api.openai.com/v1"
    var openAiModel: String = "gpt-4o-mini"
    var useAiFallback: Bool = true
    var displayFontSize: Double = 22
    var highContrast: Bool = true
}

@MainActor
final class SettingsStore: ObservableObject {
    @Published var settings: Settings = Settings() {
        didSet { save() }
    }

    private let key = "rokid_search_settings_v1"

    init() { load() }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode(Settings.self, from: data) else { return }
        settings = decoded
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(settings) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}
