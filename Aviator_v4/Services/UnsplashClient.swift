import Foundation
import ComposableArchitecture

struct UnsplashClient {
    var searchImage: (String) async -> String?
}

extension UnsplashClient: DependencyKey {
    static let liveValue = Self(
        searchImage: { query in
            await UnsplashService.shared.searchImage(query: query)
        }
    )
}

extension DependencyValues {
    var unsplashClient: UnsplashClient {
        get { self[UnsplashClient.self] }
        set { self[UnsplashClient.self] = newValue }
    }
}


final class UnsplashService {
    static let shared = UnsplashService()
    
    private init() {}
    
    func searchImage(query: String) async -> String? {
        do {
            let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
            let url = URL(string: "\(APIConfig.unsplashBaseURL)/search/photos?query=\(encodedQuery)&per_page=1&orientation=landscape")!
            
            var request = URLRequest(url: url)
            request.setValue("Client-ID \(APIConfig.unsplashAPIKey)", forHTTPHeaderField: "Authorization")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                print("❌ Unsplash API error: \(response)")
                return nil
            }
            
            let unsplashResponse = try JSONDecoder().decode(UnsplashResponse.self, from: data)
            return unsplashResponse.results.first?.urls.regular
        } catch {
            print("❌ Unsplash API error: \(error)")
            return nil
        }
    }
}


struct UnsplashResponse: Codable {
    let results: [UnsplashPhoto]
}

struct UnsplashPhoto: Codable {
    let urls: UnsplashUrls
}

struct UnsplashUrls: Codable {
    let regular: String
    let small: String
    let thumb: String
}
