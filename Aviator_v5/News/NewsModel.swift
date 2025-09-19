import Foundation

struct NewsModel: Codable {
    let status: String
    let totalResults: Int
    let articles: [Article]
}

struct Article: Codable {
    let source: Source
    let author: String?
    let title: String
    let description: String?
    let url: String
    let urlToImage: String?
    let publishedAt: Date
    let content: String
}

struct Source: Codable {
    let id: ID?
    let name: String
}

enum ID: String, Codable {
    case businessInsider = "business-insider"
    case cbsNews = "cbs-news"
    case theVerge = "the-verge"
    case wired = "wired"
}
