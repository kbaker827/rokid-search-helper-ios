import Foundation

final class OpenAiSearchService {
    private let session = URLSession.shared

    func answer(query: String, apiKey: String, baseUrl: String, model: String) async -> String? {
        guard !apiKey.isEmpty else { return nil }
        let url = URL(string: "\(baseUrl.trimmingCharacters(in: .init(charactersIn: "/")))/chat/completions")!

        let body: [String: Any] = [
            "model": model,
            "max_tokens": 300,
            "messages": [
                ["role": "system", "content": "You are a concise search assistant. Answer the user's question in 1-3 sentences. Be direct and factual."],
                ["role": "user", "content": query],
            ],
        ]

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)
        req.timeoutInterval = 15

        guard let data = try? await session.data(for: req).0,
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let message = choices.first?["message"] as? [String: Any],
              let content = message["content"] as? String else { return nil }
        return content.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
