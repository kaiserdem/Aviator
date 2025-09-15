import Foundation
import ComposableArchitecture

struct HotelsClient {
    var searchHotels: (String) async -> [Hotel]
}

extension HotelsClient: DependencyKey {
    static let liveValue = Self(
        searchHotels: { cityCode in
            await HotelsService.shared.searchHotels(cityCode: cityCode)
        }
    )
}

extension DependencyValues {
    var hotelsClient: HotelsClient {
        get { self[HotelsClient.self] }
        set { self[HotelsClient.self] = newValue }
    }
}

// MARK: - Hotels Service

final class HotelsService {
    static let shared = HotelsService()
    
    private init() {}
    
    func searchHotels(cityCode: String) async -> [Hotel] {
        do {
            let token = try await APIConfig.getAccessToken()
            let url = URL(string: "\(APIConfig.baseURL)/v1/reference-data/locations/hotels/by-city?cityCode=\(cityCode)")!
            
            var request = URLRequest(url: url)
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                print("❌ Hotels API error: \(response)")
                return []
            }
            
            let hotelsResponse = try JSONDecoder().decode(HotelsAPIResponse.self, from: data)
            return hotelsResponse.data.map { hotelData in
                Hotel(
                    name: hotelData.name,
                    address: hotelData.address?.streetAddress ?? "Address not available",
                    rating: hotelData.rating ?? 0.0,
                    price: Double.random(in: 100...500), // Amadeus doesn't provide prices in this endpoint
                    currency: "USD",
                    amenities: hotelData.amenities ?? [],
                    imageURL: hotelData.images?.first?.url
                )
            }
        } catch {
            print("❌ Hotels API error: \(error)")
            return []
        }
    }
}

// MARK: - API Response Models

struct HotelsAPIResponse: Codable {
    let data: [HotelData]
}

struct HotelData: Codable {
    let name: String
    let address: HotelAddress?
    let rating: Double?
    let amenities: [String]?
    let images: [HotelImage]?
}

struct HotelAddress: Codable {
    let streetAddress: String
    let cityName: String
    let countryCode: String
}

struct HotelImage: Codable {
    let url: String
}
