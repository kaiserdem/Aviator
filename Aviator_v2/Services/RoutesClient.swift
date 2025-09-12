import Foundation
import ComposableArchitecture

struct RoutesClient {
    var fetchRoutes: () async -> [FlightRoute]
}

extension RoutesClient: DependencyKey {
    static let liveValue = Self(
        fetchRoutes: {
            await RoutesService.shared.fetchRoutes()
        }
    )
}

extension DependencyValues {
    var routesClient: RoutesClient {
        get { self[RoutesClient.self] }
        set { self[RoutesClient.self] = newValue }
    }
}

// MARK: - Routes Service

final class RoutesService {
    static let shared = RoutesService()
    
    private init() {}
    
    func fetchRoutes() async -> [FlightRoute] {
        // Popular flight routes data
        let popularRoutes = [
            // European routes
            ("Frankfurt", "London", (50.0379, 8.5706), (51.4700, -0.4615), Region.europe, 9),
            ("Paris", "Amsterdam", (48.8566, 2.3522), (52.3105, 4.7639), Region.europe, 8),
            ("Madrid", "Rome", (40.4168, -3.7038), (41.9028, 12.4964), Region.europe, 7),
            ("Vienna", "Stockholm", (48.2082, 16.3738), (59.3293, 18.0686), Region.europe, 6),
            ("Helsinki", "Copenhagen", (60.1699, 24.9384), (55.6761, 12.5683), Region.europe, 5),
            ("Berlin", "Zurich", (52.5200, 13.4050), (47.3769, 8.5417), Region.europe, 7),
            ("Barcelona", "Milan", (41.3851, 2.1734), (45.4642, 9.1900), Region.europe, 6),
            ("Prague", "Warsaw", (50.0755, 14.4378), (52.2297, 21.0122), Region.europe, 5),
            ("Dublin", "Brussels", (53.3498, -6.2603), (50.8503, 4.3517), Region.europe, 4),
            ("Oslo", "Copenhagen", (59.9139, 10.7522), (55.6761, 12.5683), Region.europe, 6),
            
            // Transatlantic routes
            ("London", "New York", (51.4700, -0.4615), (40.7128, -74.0060), Region.america, 10),
            ("Frankfurt", "Chicago", (50.0379, 8.5706), (41.8781, -87.6298), Region.america, 8),
            ("Paris", "Los Angeles", (48.8566, 2.3522), (34.0522, -118.2437), Region.america, 7),
            ("Amsterdam", "New York", (52.3105, 4.7639), (40.7128, -74.0060), Region.america, 8),
            ("Madrid", "Miami", (40.4168, -3.7038), (25.7617, -80.1918), Region.america, 6),
            ("Rome", "Boston", (41.9028, 12.4964), (42.3601, -71.0589), Region.america, 5),
            ("Zurich", "San Francisco", (47.3769, 8.5417), (37.7749, -122.4194), Region.america, 6),
            
            // Asian routes
            ("Tokyo", "Seoul", (35.6762, 139.6503), (37.5665, 126.9780), Region.asia, 8),
            ("Singapore", "Hong Kong", (1.3521, 103.8198), (22.3193, 114.1694), Region.asia, 7),
            ("Dubai", "Mumbai", (25.2048, 55.2708), (19.0760, 72.8777), Region.asia, 6),
            ("Bangkok", "Tokyo", (13.7563, 100.5018), (35.6762, 139.6503), Region.asia, 7),
            ("Seoul", "Shanghai", (37.5665, 126.9780), (31.2304, 121.4737), Region.asia, 6),
            ("Hong Kong", "Taipei", (22.3193, 114.1694), (25.0330, 121.5654), Region.asia, 5),
            ("Mumbai", "Dubai", (19.0760, 72.8777), (25.2048, 55.2708), Region.asia, 6),
            ("Jakarta", "Singapore", (-6.2088, 106.8456), (1.3521, 103.8198), Region.asia, 5),
            ("Manila", "Hong Kong", (14.5995, 120.9842), (22.3193, 114.1694), Region.asia, 4),
            
            // Intercontinental routes
            ("Sydney", "Los Angeles", (-33.8688, 151.2093), (34.0522, -118.2437), Region.oceania, 6),
            ("Cape Town", "London", (-33.9249, 18.4241), (51.4700, -0.4615), Region.africa, 5),
            ("Melbourne", "Dubai", (-37.8136, 144.9631), (25.2048, 55.2708), Region.oceania, 5),
            ("Auckland", "Los Angeles", (-36.8485, 174.7633), (34.0522, -118.2437), Region.oceania, 4),
            ("Johannesburg", "Frankfurt", (-26.2041, 28.0473), (50.0379, 8.5706), Region.africa, 6),
            ("Cairo", "London", (30.0444, 31.2357), (51.4700, -0.4615), Region.africa, 5),
            ("Lagos", "Paris", (6.5244, 3.3792), (48.8566, 2.3522), Region.africa, 4)
        ]
        
        return popularRoutes.map { route in
            let distance = calculateDistance(
                from: route.2,
                to: route.3
            )
            let flightTime = calculateFlightTime(distance: distance)
            
            return FlightRoute(
                from: route.0,
                to: route.1,
                fromCoordinates: route.2,
                toCoordinates: route.3,
                distance: distance,
                flightTime: flightTime,
                region: route.4,
                popularity: route.5
            )
        }
    }
    
    private func calculateDistance(from: (Double, Double), to: (Double, Double)) -> Double {
        // Haversine formula for calculating distance between two points
        let earthRadius = 6371.0 // Earth's radius in kilometers
        
        let lat1Rad = from.0 * .pi / 180
        let lon1Rad = from.1 * .pi / 180
        let lat2Rad = to.0 * .pi / 180
        let lon2Rad = to.1 * .pi / 180
        
        let dLat = lat2Rad - lat1Rad
        let dLon = lon2Rad - lon1Rad
        
        let a = sin(dLat/2) * sin(dLat/2) + cos(lat1Rad) * cos(lat2Rad) * sin(dLon/2) * sin(dLon/2)
        let c = 2 * atan2(sqrt(a), sqrt(1-a))
        
        return earthRadius * c
    }
    
    private func calculateFlightTime(distance: Double) -> Double {
        // Average commercial aircraft speed: 800 km/h
        let averageSpeed = 800.0
        return distance / averageSpeed
    }
}
