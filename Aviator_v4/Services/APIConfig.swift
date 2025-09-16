import Foundation

struct APIConfig {
    static let amadeusAPIKey = "eJgrtNELJeHuwATUSGsGZKbRcJnZ3C1y"
    static let amadeusAPISecret = "jnjmOFAwYBzBfsUa"
    static let baseURL = "https://test.api.amadeus.com"
    
    // Unsplash API
    static let unsplashAPIKey = "YOUR_UNSPLASH_ACCESS_KEY" // Replace with your Unsplash access key
    static let unsplashBaseURL = "https://api.unsplash.com"
    
    static var accessToken: String?
    
    static func getAccessToken() async throws -> String {
        if let token = accessToken {
            return token
        }
        
        let url = URL(string: "\(baseURL)/v1/security/oauth2/token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let body = "grant_type=client_credentials&client_id=\(amadeusAPIKey)&client_secret=\(amadeusAPISecret)"
        request.httpBody = body.data(using: .utf8)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.authenticationFailed
        }
        
        let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
        accessToken = tokenResponse.accessToken
        return tokenResponse.accessToken
    }
}

struct TokenResponse: Codable {
    let accessToken: String
    let tokenType: String
    let expiresIn: Int
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
    }
}

enum APIError: Error, LocalizedError {
    case authenticationFailed
    case invalidResponse
    case networkError(String)
    
    var errorDescription: String? {
        switch self {
        case .authenticationFailed:
            return "Failed to authenticate with Amadeus API"
        case .invalidResponse:
            return "Invalid response from API"
        case .networkError(let message):
            return "Network error: \(message)"
        }
    }
}
