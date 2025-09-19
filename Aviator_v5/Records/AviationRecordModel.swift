import Foundation

struct AviationRecord: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let description: String
    let value: String
    let unit: String
    let category: RecordCategory
    let year: Int
    let pilot: String?
    let aircraft: String?
    let location: String?
    let imageURL: String?
    let isCurrentRecord: Bool
    let previousRecord: String?
    
    // Нові поля для FAI рекордів
    let faiClass: String?
    let faiSubClass: String?
    let recordType: String?
    let performance: String?
    let date: String?
    let claimant: String?
    let status: String?
    let region: String?
    let faiId: String?
    
    var displayValue: String {
        return "\(value) \(unit)"
    }
    
    var fullDescription: String {
        var desc = description
        if let pilot = pilot {
            desc += " by \(pilot)"
        }
        if let aircraft = aircraft {
            desc += " in \(aircraft)"
        }
        if let location = location {
            desc += " at \(location)"
        }
        return desc
    }
}

enum RecordCategory: String, CaseIterable, Codable, Equatable {
    case speed = "Speed"
    case altitude = "Altitude"
    case distance = "Distance"
    case endurance = "Endurance"
    case payload = "Payload"
    case historical = "Historical"
    case military = "Military"
    case commercial = "Commercial"
    case experimental = "Experimental"
    case parachuting = "Parachuting"
    case uav = "UAV/Drones"
    case hangGliding = "Hang Gliding"
    case gliding = "Gliding"
    case rotorcraft = "Rotorcraft"
    case aeromodelling = "Aeromodelling"
    case solarPowered = "Solar Powered"
    
    var displayName: String {
        return self.rawValue
    }
    
    var icon: String {
        switch self {
        case .speed:
            return "speedometer"
        case .altitude:
            return "arrow.up"
        case .distance:
            return "arrow.right"
        case .endurance:
            return "clock"
        case .payload:
            return "scalemass"
        case .historical:
            return "book"
        case .military:
            return "shield"
        case .commercial:
            return "airplane"
        case .experimental:
            return "flask"
        case .parachuting:
            return "figure.fall"
        case .uav:
            return "airplane.departure"
        case .hangGliding:
            return "figure.hang.gliding"
        case .gliding:
            return "airplane.circle"
        case .rotorcraft:
            return "helicopter"
        case .aeromodelling:
            return "airplane.circle.fill"
        case .solarPowered:
            return "sun.max"
        }
    }
    
    var color: String {
        switch self {
        case .speed:
            return "red"
        case .altitude:
            return "blue"
        case .distance:
            return "green"
        case .endurance:
            return "orange"
        case .payload:
            return "purple"
        case .historical:
            return "brown"
        case .military:
            return "gray"
        case .commercial:
            return "cyan"
        case .experimental:
            return "pink"
        case .parachuting:
            return "yellow"
        case .uav:
            return "mint"
        case .hangGliding:
            return "indigo"
        case .gliding:
            return "teal"
        case .rotorcraft:
            return "blue"
        case .aeromodelling:
            return "orange"
        case .solarPowered:
            return "yellow"
        }
    }
}
