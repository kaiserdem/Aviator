import Foundation
import ComposableArchitecture

@DependencyClient
struct WikipediaImageClient {
    var fetchPilotImage: @Sendable (String) async throws -> URL?
}

extension WikipediaImageClient: DependencyKey {
    static let liveValue = Self(
        fetchPilotImage: { pilotName in
            // Створюємо URL для Wikipedia API
            let encodedName = pilotName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? pilotName
            let urlString = "https://en.wikipedia.org/api/rest_v1/page/summary/\(encodedName)"
            
            guard let url = URL(string: urlString) else {
                throw WikipediaImageError.invalidURL
            }
            
            var request = URLRequest(url: url)
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw WikipediaImageError.invalidResponse
            }
            
            guard httpResponse.statusCode == 200 else {
                throw WikipediaImageError.httpError(httpResponse.statusCode)
            }
            
            // Декодуємо відповідь
            let decoder = JSONDecoder()
            let pageSummary = try decoder.decode(WikipediaPageSummary.self, from: data)
            
            // Повертаємо URL зображення, якщо воно є
            guard let source = pageSummary.thumbnail?.source,
                  let imageURL = URL(string: source) else {
                return nil
            }
            return imageURL
        }
    )
}

extension DependencyValues {
    var wikipediaImageClient: WikipediaImageClient {
        get { self[WikipediaImageClient.self] }
        set { self[WikipediaImageClient.self] = newValue }
    }
}

// MARK: - Models

struct WikipediaPageSummary: Codable {
    let title: String
    let extract: String?
    let thumbnail: WikipediaThumbnail?
    let contentUrls: WikipediaContentUrls?
    
    enum CodingKeys: String, CodingKey {
        case title, extract, thumbnail
        case contentUrls = "content_urls"
    }
}

struct WikipediaThumbnail: Codable {
    let source: String
    let width: Int?
    let height: Int?
}

struct WikipediaContentUrls: Codable {
    let desktop: WikipediaDesktop?
    let mobile: WikipediaMobile?
}

struct WikipediaDesktop: Codable {
    let page: String
}

struct WikipediaMobile: Codable {
    let page: String
}

// MARK: - Errors

enum WikipediaImageError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case decodingError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid server response"
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .decodingError:
            return "Data decoding error"
        }
    }
}
