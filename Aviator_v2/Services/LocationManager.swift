import Foundation
import CoreLocation
import ComposableArchitecture

struct LocationManager {
    var requestPermission: () async -> LocationPermissionStatus
    var getCurrentLocation: () async -> CLLocationCoordinate2D?
}

extension LocationManager: DependencyKey {
    static let liveValue = Self(
        requestPermission: {
            await LocationService.shared.requestPermission()
        },
        getCurrentLocation: {
            await LocationService.shared.getCurrentLocation()
        }
    )
    
    static let testValue = Self(
        requestPermission: {
            .authorized
        },
        getCurrentLocation: {
            CLLocationCoordinate2D(latitude: 50.0, longitude: 10.0)
        }
    )
}

extension DependencyValues {
    var locationManager: LocationManager {
        get { self[LocationManager.self] }
        set { self[LocationManager.self] = newValue }
    }
}

// MARK: - Location Service

@MainActor
final class LocationService: NSObject, ObservableObject {
    static let shared = LocationService()
    
    private let locationManager = CLLocationManager()
    private var continuation: CheckedContinuation<LocationPermissionStatus, Never>?
    private var locationContinuation: CheckedContinuation<CLLocationCoordinate2D?, Never>?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestPermission() async -> LocationPermissionStatus {
        return await withCheckedContinuation { continuation in
            self.continuation = continuation
            
            switch locationManager.authorizationStatus {
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            case .denied, .restricted:
                continuation.resume(returning: .denied)
            case .authorizedWhenInUse, .authorizedAlways:
                continuation.resume(returning: .authorized)
            @unknown default:
                continuation.resume(returning: .denied)
            }
        }
    }
    
    func getCurrentLocation() async -> CLLocationCoordinate2D? {
        guard locationManager.authorizationStatus == .authorizedWhenInUse || 
              locationManager.authorizationStatus == .authorizedAlways else {
            return nil
        }
        
        return await withCheckedContinuation { continuation in
            self.locationContinuation = continuation
            locationManager.requestLocation()
        }
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        locationContinuation?.resume(returning: location.coordinate)
        locationContinuation = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationContinuation?.resume(returning: nil)
        locationContinuation = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard let continuation = continuation else { return }
        
        switch status {
        case .notDetermined:
            continuation.resume(returning: .notDetermined)
        case .denied, .restricted:
            continuation.resume(returning: .denied)
        case .authorizedWhenInUse, .authorizedAlways:
            continuation.resume(returning: .authorized)
        @unknown default:
            continuation.resume(returning: .denied)
        }
        
        self.continuation = nil
    }
}
