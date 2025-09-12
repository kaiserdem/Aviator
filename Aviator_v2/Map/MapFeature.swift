import ComposableArchitecture
import Foundation
import MapKit
import CoreLocation

struct MapFeature: Reducer {
    struct State: Equatable {
        var isLoading = false
        var aircraft: [AircraftPosition] = []
        var selectedAircraft: AircraftPosition?
        var userLocation: LocationCoordinate?
        var region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 50.0, longitude: 10.0),
            span: MKCoordinateSpan(latitudeDelta: 50.0, longitudeDelta: 50.0)
        )
        var locationPermissionStatus: LocationPermissionStatus = .notDetermined
        
        static func == (lhs: State, rhs: State) -> Bool {
            return lhs.isLoading == rhs.isLoading &&
                   lhs.aircraft == rhs.aircraft &&
                   lhs.selectedAircraft == rhs.selectedAircraft &&
                   lhs.locationPermissionStatus == rhs.locationPermissionStatus &&
                   lhs.userLocation == rhs.userLocation &&
                   lhs.region.center.latitude == rhs.region.center.latitude &&
                   lhs.region.center.longitude == rhs.region.center.longitude &&
                   lhs.region.span.latitudeDelta == rhs.region.span.latitudeDelta &&
                   lhs.region.span.longitudeDelta == rhs.region.span.longitudeDelta
        }
    }

    enum Action: Equatable {
        case onAppear
        case _aircraftResponse([AircraftPosition])
        case selectAircraft(AircraftPosition?)
        case requestLocationPermission
        case locationPermissionChanged(LocationPermissionStatus)
        case userLocationUpdated(LocationCoordinate)
        case zoomIn
        case zoomOut
        case centerOnUserLocation
    }

    @Dependency(\.aircraftClient) var aircraftClient

    @Dependency(\.locationManager) var locationManager

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                return .run { send in
                    await send(.requestLocationPermission)
                    let aircraft = await aircraftClient.fetchAircraftPositions()
                    await send(._aircraftResponse(aircraft))
                }
                
            case let ._aircraftResponse(aircraft):
                state.isLoading = false
                state.aircraft = aircraft
                return .none
                
            case let .selectAircraft(aircraft):
                state.selectedAircraft = aircraft
                return .none
                
            case .requestLocationPermission:
                return .run { send in
                    let status = await locationManager.requestPermission()
                    await send(.locationPermissionChanged(status))
                }
                
            case let .locationPermissionChanged(status):
                state.locationPermissionStatus = status
                if status == .authorized {
                    return .run { send in
                        if let location = await locationManager.getCurrentLocation() {
                            await send(.userLocationUpdated(LocationCoordinate(location)))
                        }
                    }
                }
                return .none
                
            case let .userLocationUpdated(coordinate):
                state.userLocation = coordinate
                state.region = MKCoordinateRegion(
                    center: coordinate.clLocationCoordinate,
                    span: MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0)
                )
                return .none
                
            case .zoomIn:
                let newSpan = MKCoordinateSpan(
                    latitudeDelta: state.region.span.latitudeDelta * 0.5,
                    longitudeDelta: state.region.span.longitudeDelta * 0.5
                )
                state.region = MKCoordinateRegion(center: state.region.center, span: newSpan)
                return .none
                
            case .zoomOut:
                let newSpan = MKCoordinateSpan(
                    latitudeDelta: state.region.span.latitudeDelta * 2.0,
                    longitudeDelta: state.region.span.longitudeDelta * 2.0
                )
                state.region = MKCoordinateRegion(center: state.region.center, span: newSpan)
                return .none
                
            case .centerOnUserLocation:
                if let userLocation = state.userLocation {
                    state.region = MKCoordinateRegion(
                        center: userLocation.clLocationCoordinate,
                        span: MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0)
                    )
                }
                return .none
            }
        }
    }
}

// MARK: - Models

enum LocationPermissionStatus: Equatable {
    case notDetermined
    case denied
    case authorized
    case restricted
}

struct LocationCoordinate: Equatable {
    let latitude: Double
    let longitude: Double
    
    init(_ coordinate: CLLocationCoordinate2D) {
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }
    
    var clLocationCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

struct AircraftPosition: Identifiable, Equatable, Hashable {
    let id: UUID = UUID()
    let icao24: String?
    let callsign: String?
    let originCountry: String?
    let longitude: Double?
    let latitude: Double?
    let altitude: Double?
    let velocity: Double?
    let heading: Double?
    let aircraftType: String?
    let aircraftImageURL: URL?
}
