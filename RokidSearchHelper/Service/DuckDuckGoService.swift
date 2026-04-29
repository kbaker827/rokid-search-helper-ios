import Foundation

struct DuckDuckGoResult {
    let answer: String
    let source: String
}

final class DuckDuckGoService {
    private let session = URLSession.shared

    func instantAnswer(for query: String) async -> DuckDuckGoResult? {
        var comps = URLComponents(string: "https://api.duckduckgo.com/")!
        comps.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "no_redirect", value: "1"),
            URLQueryItem(name: "no_html", value: "1"),
            URLQueryItem(name: "skip_disambig", value: "1"),
        ]
        guard let url = comps.url,
              let data = try? await session.data(from: url).0,
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return nil }

        // Try AbstractText (Wikipedia summary)
        if let abstract = json["AbstractText"] as? String, !abstract.isEmpty {
            let source = json["AbstractSource"] as? String ?? "DuckDuckGo"
            return DuckDuckGoResult(answer: abstract, source: source)
        }

        // Try Answer (instant answer)
        if let answer = json["Answer"] as? String, !answer.isEmpty {
            return DuckDuckGoResult(answer: answer, source: "DuckDuckGo Instant")
        }

        // Try Definition
        if let def = json["Definition"] as? String, !def.isEmpty {
            let source = json["DefinitionSource"] as? String ?? "DuckDuckGo"
            return DuckDuckGoResult(answer: def, source: source)
        }

        // Try top RelatedTopic
        if let topics = json["RelatedTopics"] as? [[String: Any]],
           let first = topics.first,
           let text = first["Text"] as? String, !text.isEmpty {
            return DuckDuckGoResult(answer: text, source: "DuckDuckGo")
        }

        return nil
    }
}
