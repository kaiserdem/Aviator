import Foundation
import ComposableArchitecture

@DependencyClient
struct NewsClient {
    var fetchNews: @Sendable (String, String, String) async throws -> NewsModel
}

extension NewsClient: DependencyKey {
    static let liveValue = Self(
        fetchNews: { query, fromDate, apiKey in
            var components = URLComponents(string: "https://newsapi.org/v2/everything")!
            components.queryItems = [
                URLQueryItem(name: "q", value: query),
                URLQueryItem(name: "from", value: fromDate),
                URLQueryItem(name: "sortBy", value: "popularity"),
                URLQueryItem(name: "apiKey", value: apiKey)
            ]
            
            guard let url = components.url else {
                throw NewsError.invalidURL
            }
            
            var request = URLRequest(url: url)
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NewsError.invalidResponse
            }
            
            guard httpResponse.statusCode == 200 else {
                throw NewsError.httpError(httpResponse.statusCode)
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            return try decoder.decode(NewsModel.self, from: data)
        }
    )
}

enum NewsError: Error, LocalizedError {
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

extension DependencyValues {
    var newsClient: NewsClient {
        get { self[NewsClient.self] }
        set { self[NewsClient.self] = newValue }
    }
}
