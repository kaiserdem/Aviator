import Foundation

struct Pilot: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let fullName: String
    let nationality: String
    let birthDate: String
    let deathDate: String?
    let achievements: [String]
    let biography: String
    let imageName: String
    let imageURL: URL?
    let era: PilotEra
    let category: PilotCategory
}

enum PilotEra: String, CaseIterable {
    case pioneers = "Pioneers"
    case worldWar = "World War Era"
    case modern = "Modern Era"
    case space = "Space Era"
}

enum PilotCategory: String, CaseIterable {
    case military = "Military"
    case commercial = "Commercial"
    case test = "Test Pilot"
    case astronaut = "Astronaut"
    case recordBreaker = "Record Breaker"
}
