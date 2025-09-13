import Foundation
import ComposableArchitecture

// MARK: - Database Client

struct DatabaseClient {
    var saveFlight: @Sendable (FlightOffer, String?) async throws -> Void
    var getSavedFlights: @Sendable () async throws -> [SavedFlight]
    var deleteSavedFlight: @Sendable (SavedFlight) async throws -> Void
    var isFlightSaved: @Sendable (FlightOffer) async throws -> Bool
}

extension DatabaseClient: DependencyKey {
    static let liveValue = DatabaseClient(
        saveFlight: { flight, notes in
            try await InMemoryDatabaseService.shared.saveFlight(flight, notes: notes)
        },
        getSavedFlights: {
            try await InMemoryDatabaseService.shared.getSavedFlights()
        },
        deleteSavedFlight: { flight in
            try await InMemoryDatabaseService.shared.deleteSavedFlight(flight)
        },
        isFlightSaved: { flight in
            try await InMemoryDatabaseService.shared.isFlightSaved(flight)
        }
    )
}

extension DependencyValues {
    var databaseClient: DatabaseClient {
        get { self[DatabaseClient.self] }
        set { self[DatabaseClient.self] = newValue }
    }
}
