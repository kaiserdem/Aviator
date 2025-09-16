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
                    address: hotelData.address?.lines?.first ?? "Address not available",
                    rating: Double.random(in: 3.0...5.0), // Random rating since API doesn't provide it
                    price: Double.random(in: 100...500), // Random price since API doesn't provide it
                    currency: "USD",
                    amenities: ["WiFi", "Parking", "Restaurant", "Gym"], // Default amenities
                    imageURL: getFreeHotelImage(seed: hotelData.name), // Generate free image
                    latitude: hotelData.geoCode?.latitude,
                    longitude: hotelData.geoCode?.longitude
                )
            }
        } catch {
            print("❌ Hotels API error: \(error)")
            // Return mock data if API fails
            return generateMockHotels()
        }
    }
    
    private func generateMockHotels() -> [Hotel] {
        return [
            Hotel(
                name: "Grand Hotel NYC",
                address: "123 Broadway, New York, NY 10001",
                rating: 4.5,
                price: 299.0,
                currency: "USD",
                amenities: ["WiFi", "Parking", "Restaurant", "Gym", "Pool"],
                imageURL: getFreeHotelImage(seed: "Grand Hotel NYC"),
                latitude: 40.7589,
                longitude: -73.9851
            ),
            Hotel(
                name: "Manhattan Plaza Hotel",
                address: "456 7th Avenue, New York, NY 10018",
                rating: 4.2,
                price: 199.0,
                currency: "USD",
                amenities: ["WiFi", "Restaurant", "Gym"],
                imageURL: getFreeHotelImage(seed: "Manhattan Plaza Hotel"),
                latitude: 40.7505,
                longitude: -73.9934
            ),
            Hotel(
                name: "Central Park Hotel",
                address: "789 Central Park West, New York, NY 10023",
                rating: 4.8,
                price: 399.0,
                currency: "USD",
                amenities: ["WiFi", "Parking", "Restaurant", "Gym", "Pool", "Spa"],
                imageURL: getFreeHotelImage(seed: "Central Park Hotel"),
                latitude: 40.7829,
                longitude: -73.9654
            )
        ]
    }
    
    // MARK: - Free Image Sources
    
    private func getFreeHotelImage(seed: String) -> String {
        // Варіант 1: Lorem Picsum з seed (стабільне фото для того ж готелю)
        let seedHash = abs(seed.hashValue)
        return "https://picsum.photos/seed/\(seedHash)/400/300"
        
        // Варіант 2: Unsplash Source (без API ключа)
        // return "https://source.unsplash.com/400x300/?hotel"
        
        // Варіант 3: Випадкове фото з Lorem Picsum
        // return "https://picsum.photos/400/300"
    }
}

// MARK: - API Response Models

struct HotelsAPIResponse: Codable {
    let data: [HotelData]
    let meta: HotelsMeta
}

struct HotelsMeta: Codable {
    let count: Int
    let links: HotelsLinks
}

struct HotelsLinks: Codable {
    let selfLink: String
    
    enum CodingKeys: String, CodingKey {
        case selfLink = "self"
    }
}

struct HotelData: Codable {
    let chainCode: String?
    let iataCode: String
    let dupeId: Int
    let name: String
    let hotelId: String
    let geoCode: HotelGeoCode?
    let address: HotelAddress?
    let masterChainCode: String?
    let lastUpdate: String
}

struct HotelGeoCode: Codable {
    let latitude: Double
    let longitude: Double
}

struct HotelAddress: Codable {
    let countryCode: String?
    let postalCode: String?
    let stateCode: String?
    let cityName: String?
    let lines: [String]?
}
