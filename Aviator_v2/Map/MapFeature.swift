import ComposableArchitecture
import Foundation
import MapKit
import CoreLocation

struct MapRegion: Equatable {
    let center: CLLocationCoordinate2D
    let span: MKCoordinateSpan
    
    init(_ region: MKCoordinateRegion) {
        self.center = region.center
        self.span = region.span
    }
    
    var mkCoordinateRegion: MKCoordinateRegion {
        MKCoordinateRegion(center: center, span: span)
    }
    
    static func == (lhs: MapRegion, rhs: MapRegion) -> Bool {
        return lhs.center.latitude == rhs.center.latitude &&
               lhs.center.longitude == rhs.center.longitude &&
               lhs.span.latitudeDelta == rhs.span.latitudeDelta &&
               lhs.span.longitudeDelta == rhs.span.longitudeDelta
    }
}

struct MapFeature: Reducer {
    struct State: Equatable {
        var isLoading = false
        var aircraft: [AircraftPosition] = []
        var selectedAircraft: AircraftPosition?
        var userLocation: LocationCoordinate?
        var region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 50.0, longitude: 10.0),
            span: MKCoordinateSpan(latitudeDelta: 20.0, longitudeDelta: 20.0)
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
        case regionChanged(MapRegion)
    }

    @Dependency(\.aircraftClient) var aircraftClient

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                return .run { send in
                    // Simulate loading delay
                    try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                    
                    // Use test data for now to avoid network issues
                    let aircraft = [
                        AircraftPosition(
                            icao24: "abc123",
                            callsign: "PS101",
                            originCountry: "Ukraine",
                            longitude: 30.5234,
                            latitude: 50.4501,
                            altitude: 2000,
                            velocity: 220.0,
                            heading: 140,
                            aircraftType: "Boeing 737",
                            aircraftImageURL: nil
                        ),
                        AircraftPosition(
                            icao24: "def456",
                            callsign: "BA238",
                            originCountry: "United Kingdom",
                            longitude: 25.0,
                            latitude: 52.0,
                            altitude: 1500,
                            velocity: 190.0,
                            heading: 280,
                            aircraftType: "Airbus A320",
                            aircraftImageURL: nil
                        ),
                        AircraftPosition(
                            icao24: "ghi789",
                            callsign: "LH445",
                            originCountry: "Germany",
                            longitude: 35.0,
                            latitude: 48.0,
                            altitude: 3000,
                            velocity: 250.0,
                            heading: 90,
                            aircraftType: "Boeing 777",
                            aircraftImageURL: nil
                        ),
                        AircraftPosition(
                            icao24: "jkl012",
                            callsign: "AF123",
                            originCountry: "France",
                            longitude: 20.0,
                            latitude: 55.0,
                            altitude: 2500,
                            velocity: 200.0,
                            heading: 45,
                            aircraftType: "Airbus A330",
                            aircraftImageURL: nil
                        ),
                        AircraftPosition(
                            icao24: "mno345",
                            callsign: "KL456",
                            originCountry: "Netherlands",
                            longitude: 15.0,
                            latitude: 50.0,
                            altitude: 1800,
                            velocity: 180.0,
                            heading: 320,
                            aircraftType: "Boeing 737",
                            aircraftImageURL: nil
                        )
                    ]
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
                // This will be handled by the view
                return .none
                
            case let .locationPermissionChanged(status):
                state.locationPermissionStatus = status
                return .none
                
            case let .userLocationUpdated(coordinate):
                state.userLocation = coordinate
                state.region = MKCoordinateRegion(
                    center: coordinate.clLocationCoordinate,
                    span: MKCoordinateSpan(latitudeDelta: 5.0, longitudeDelta: 5.0)
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
                        span: MKCoordinateSpan(latitudeDelta: 5.0, longitudeDelta: 5.0)
                    )
                }
                return .none
                
            case let .regionChanged(newRegion):
                state.region = newRegion.mkCoordinateRegion
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
