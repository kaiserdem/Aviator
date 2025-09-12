import ComposableArchitecture
import Foundation

struct RoutesFeature: Reducer {
    struct State: Equatable {
        var isLoading = false
        var routes: [FlightRoute] = []
        var selectedRoute: FlightRoute?
        var selectedRegion: Region = .all
        
        static func == (lhs: State, rhs: State) -> Bool {
            lhs.isLoading == rhs.isLoading &&
            lhs.routes == rhs.routes &&
            lhs.selectedRoute == rhs.selectedRoute &&
            lhs.selectedRegion == rhs.selectedRegion
        }
    }

    enum Action: Equatable {
        case onAppear
        case _routesResponse([FlightRoute])
        case selectRoute(FlightRoute?)
        case selectRegion(Region)
    }

    @Dependency(\.routesClient) var routesClient

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                return .run { send in
                    let routes = await routesClient.fetchRoutes()
                    await send(._routesResponse(routes))
                }
                
            case let ._routesResponse(routes):
                state.isLoading = false
                state.routes = routes
                return .none
                
            case let .selectRoute(route):
                state.selectedRoute = route
                return .none
                
            case let .selectRegion(region):
                state.selectedRegion = region
                return .none
            }
        }
    }
}

// MARK: - Models

struct FlightRoute: Identifiable, Equatable, Hashable {
    let id: UUID = UUID()
    let from: String
    let to: String
    let fromCoordinates: (latitude: Double, longitude: Double)
    let toCoordinates: (latitude: Double, longitude: Double)
    let distance: Double // in kilometers
    let flightTime: Double // in hours
    let region: Region
    let popularity: Int // 1-10 scale
    
    static func == (lhs: FlightRoute, rhs: FlightRoute) -> Bool {
        lhs.id == rhs.id &&
        lhs.from == rhs.from &&
        lhs.to == rhs.to &&
        lhs.fromCoordinates == rhs.fromCoordinates &&
        lhs.toCoordinates == rhs.toCoordinates &&
        lhs.distance == rhs.distance &&
        lhs.flightTime == rhs.flightTime &&
        lhs.region == rhs.region &&
        lhs.popularity == rhs.popularity
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(from)
        hasher.combine(to)
        hasher.combine(fromCoordinates.0)
        hasher.combine(fromCoordinates.1)
        hasher.combine(toCoordinates.0)
        hasher.combine(toCoordinates.1)
        hasher.combine(distance)
        hasher.combine(flightTime)
        hasher.combine(region)
        hasher.combine(popularity)
    }
}
