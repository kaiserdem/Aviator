import Foundation
import ComposableArchitecture

struct NewsPost: Identifiable, Equatable, Hashable {
    let id: String
    let title: String
    let url: URL?
    let author: String
    let createdAt: Date
}

struct NewsClient {
    var fetchTop: @Sendable (_ limit: Int) async -> [NewsPost]
}

extension DependencyValues {
    var newsClient: NewsClient {
        get { self[NewsClientKey.self] }
        set { self[NewsClientKey.self] = newValue }
    }
}

enum NewsClientKey: DependencyKey {
    static let liveValue: NewsClient = .init(fetchTop: { limit in
        let url = URL(string: "https://www.reddit.com/r/aviation/top.json?limit=\(max(1, min(limit, 100)))")!
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { return mock }
            struct Envelope: Decodable {
                struct Listing: Decodable { let data: DataNode }
                struct DataNode: Decodable { let children: [Child] }
                struct Child: Decodable { let data: Post }
                struct Post: Decodable {
                    let id: String
                    let title: String
                    let url: String?
                    let author: String
                    let created_utc: Double
                }
                let data: DataNode
            }
            let env = try JSONDecoder().decode(Envelope.self, from: data)
            let posts = env.data.children.map { child -> NewsPost in
                let p = child.data
                let url = URL(string: p.url ?? "")
                return NewsPost(
                    id: p.id,
                    title: p.title,
                    url: url,
                    author: p.author,
                    createdAt: Date(timeIntervalSince1970: p.created_utc)
                )
            }
            return posts
        } catch { return mock }
    })

    static let testValue: NewsClient = .init(fetchTop: { _ in mock })
}

private let mock: [NewsPost] = [
    NewsPost(id: "m1", title: "Airline announces new A321neo routes", url: URL(string: "https://example.com/a321"), author: "avgeek", createdAt: Date().addingTimeInterval(-3600)),
    NewsPost(id: "m2", title: "737 MAX makes record-breaking flight", url: URL(string: "https://example.com/737"), author: "pilot123", createdAt: Date().addingTimeInterval(-7200))
]


