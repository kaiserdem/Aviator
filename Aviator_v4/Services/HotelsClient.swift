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
                    country: hotelData.address?.countryCode ?? "Unknown",
                    city: hotelData.address?.cityName ?? extractCityFromAddress(hotelData.address?.lines?.first),
                    region: hotelData.address?.stateCode ?? "Unknown",
                    rating: Double.random(in: 3.0...5.0), // Random rating since API doesn't provide it
                    price: Double.random(in: 50...150), // Lower prices as requested
                    currency: "USD",
                    amenities: generateRandomAmenities(), // Different amenities for each hotel
                    imageURL: getHotelImage(hotelName: hotelData.name, city: hotelData.address?.cityName ?? "hotel"), // Generate hotel-specific image
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
                country: "United States",
                city: "New York",
                region: "NY",
                rating: 4.5,
                price: 89.0,
                currency: "USD",
                amenities: ["WiFi", "Parking", "Restaurant", "Gym", "Pool"],
                imageURL: getHotelImage(hotelName: "Grand Hotel NYC", city: "New York"),
                latitude: 40.7589,
                longitude: -73.9851
            ),
            Hotel(
                name: "Manhattan Plaza Hotel",
                address: "456 7th Avenue, New York, NY 10018",
                country: "United States",
                city: "New York",
                region: "NY",
                rating: 4.2,
                price: 75.0,
                currency: "USD",
                amenities: ["WiFi", "Restaurant"],
                imageURL: getHotelImage(hotelName: "Manhattan Plaza Hotel", city: "New York"),
                latitude: 40.7505,
                longitude: -73.9934
            ),
            Hotel(
                name: "Central Park Hotel",
                address: "789 Central Park West, New York, NY 10023",
                country: "United States",
                city: "New York",
                region: "NY",
                rating: 4.8,
                price: 120.0,
                currency: "USD",
                amenities: ["WiFi", "Parking", "Restaurant", "Gym", "Pool", "Spa"],
                imageURL: getHotelImage(hotelName: "Central Park Hotel", city: "New York"),
                latitude: 40.7829,
                longitude: -73.9654
            )
        ]
    }
    
    // MARK: - Helper Functions
    
    private func extractCityFromAddress(_ address: String?) -> String {
        guard let address = address else { return "Unknown" }
        
        // Спробуємо витягнути місто з адреси
        let commonCities = ["New York", "Paris", "London", "Tokyo", "Berlin", "Rome", "Madrid", "Amsterdam", "Vienna", "Prague"]
        
        for city in commonCities {
            if address.contains(city) {
                return city
            }
        }
        
        // Якщо не знайшли відоме місто, спробуємо витягнути перше слово після коми
        let components = address.components(separatedBy: ",")
        if components.count > 1 {
            let cityPart = components[1].trimmingCharacters(in: .whitespaces)
            let cityWords = cityPart.components(separatedBy: " ")
            if let firstWord = cityWords.first, !firstWord.isEmpty {
                return firstWord
            }
        }
        
        return "Unknown"
    }
    
    private func generateRandomAmenities() -> [String] {
        let allAmenities = [
            "WiFi",           // Завжди є
            "Parking",        // 30-50% ймовірність
            "Restaurant",     // 30-50% ймовірність  
            "Gym",           // Меншість (20-30%)
            "Pool",          // Рідко (10-20%)
            "Spa",           // Рідко (10-20%)
            "Room Service",  // Рідко (10-20%)
            "Bar",           // Рідко (10-20%)
            "Concierge",     // Рідко (10-20%)
            "Business Center" // Рідко (10-20%)
        ]
        
        var amenities: [String] = ["WiFi"] // WiFi завжди є
        
        // Додаємо Parking (30-50% ймовірність)
        if Int.random(in: 1...100) <= 40 {
            amenities.append("Parking")
        }
        
        // Додаємо Restaurant (30-50% ймовірність)
        if Int.random(in: 1...100) <= 40 {
            amenities.append("Restaurant")
        }
        
        // Додаємо Gym (20-30% ймовірність)
        if Int.random(in: 1...100) <= 25 {
            amenities.append("Gym")
        }
        
        // Додаємо інші зручності (10-20% ймовірність кожна)
        let rareAmenities = ["Pool", "Spa", "Room Service", "Bar", "Concierge", "Business Center"]
        for amenity in rareAmenities {
            if Int.random(in: 1...100) <= 15 {
                amenities.append(amenity)
            }
        }
        
        return amenities
    }
    
    // MARK: - Free Image Sources
    
    private func getHotelImage(hotelName: String, city: String) -> String {
        // Використовуємо локальні картинки hotel_1 до hotel_40
        // З 40 картинками повторення значно зменшується
        let hotelHash = abs(hotelName.hashValue)
        let imageNumber = (hotelHash % 40) + 1 // Генеруємо число від 1 до 40
        
        return "hotel_\(imageNumber)"
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
