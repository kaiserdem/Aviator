import Foundation
import ComposableArchitecture

struct CarsClient {
    var searchCars: (String, Date, Date) async -> [Car]
}

extension CarsClient: DependencyKey {
    static let liveValue = Self(
        searchCars: { locationCode, pickupDate, dropoffDate in
            await CarsService.shared.searchCars(
                locationCode: locationCode,
                pickupDate: pickupDate,
                dropoffDate: dropoffDate
            )
        }
    )
}

extension DependencyValues {
    var carsClient: CarsClient {
        get { self[CarsClient.self] }
        set { self[CarsClient.self] = newValue }
    }
}

// MARK: - Cars Service

final class CarsService {
    static let shared = CarsService()
    
    private init() {}
    
    func searchCars(locationCode: String, pickupDate: Date, dropoffDate: Date) async -> [Car] {
        do {
            let token = try await APIConfig.getAccessToken()
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let pickupDateString = formatter.string(from: pickupDate)
            let dropoffDateString = formatter.string(from: dropoffDate)
            
            let url = URL(string: "\(APIConfig.baseURL)/v2/shopping/availability/car-rental?locationCode=\(locationCode)&pickUpDate=\(pickupDateString)&dropOffDate=\(dropoffDateString)")!
            
            var request = URLRequest(url: url)
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                print("❌ Cars API error: \(response)")
                return []
            }
            
            let carsResponse = try JSONDecoder().decode(CarsAPIResponse.self, from: data)
            return carsResponse.data.map { carData in
                Car(
                    make: carData.vehicleInfo?.make ?? "Unknown",
                    model: carData.vehicleInfo?.model ?? "Unknown",
                    category: carData.vehicleInfo?.category ?? "Standard",
                    pricePerDay: carData.totalPrice?.amount ?? 0.0,
                    currency: carData.totalPrice?.currency ?? "USD",
                    transmission: carData.vehicleInfo?.transmission ?? "Automatic",
                    fuelType: carData.vehicleInfo?.fuelType ?? "Gasoline",
                    seats: carData.vehicleInfo?.seats ?? 5,
                    imageURL: carData.vehicleInfo?.imageURL,
                    company: carData.provider?.name ?? "Unknown"
                )
            }
        } catch {
            print("❌ Cars API error: \(error)")
            // Return mock data if API fails
            return generateMockCars()
        }
    }
    
    private func generateMockCars() -> [Car] {
        return [
            Car(
                make: "Toyota",
                model: "Camry",
                category: "Standard",
                pricePerDay: 45.0,
                currency: "USD",
                transmission: "Automatic",
                fuelType: "Gasoline",
                seats: 5,
                imageURL: nil,
                company: "Hertz"
            ),
            Car(
                make: "BMW",
                model: "3 Series",
                category: "Luxury",
                pricePerDay: 85.0,
                currency: "USD",
                transmission: "Automatic",
                fuelType: "Gasoline",
                seats: 5,
                imageURL: nil,
                company: "Avis"
            ),
            Car(
                make: "Ford",
                model: "Explorer",
                category: "SUV",
                pricePerDay: 65.0,
                currency: "USD",
                transmission: "Automatic",
                fuelType: "Gasoline",
                seats: 7,
                imageURL: nil,
                company: "Enterprise"
            )
        ]
    }
}

// MARK: - API Response Models

struct CarsAPIResponse: Codable {
    let data: [CarData]
}

struct CarData: Codable {
    let vehicleInfo: VehicleInfo?
    let totalPrice: Price?
    let provider: Provider?
}

struct VehicleInfo: Codable {
    let make: String?
    let model: String?
    let category: String?
    let transmission: String?
    let fuelType: String?
    let seats: Int?
    let imageURL: String?
}

struct Price: Codable {
    let amount: Double?
    let currency: String?
}

struct Provider: Codable {
    let name: String?
}
