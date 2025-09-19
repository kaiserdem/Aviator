import Foundation

struct AviationEvent: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let location: String
    let country: String
    let startDate: Date
    let endDate: Date
    let eventType: EventType
    let sport: Sport
    let discipline: String
    let classification: EventClassification
    let organizer: String
    let websiteURL: String?
    let faiMiniSiteURL: String?
    let description: String?
    let documents: [String]?
    let contactPerson: String?
    let contactEmail: String?
    let contactPhone: String?
    let alternateDates: String?
    
    var dateRange: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM"
        return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate)) \(Calendar.current.component(.year, from: startDate))"
    }
    
    var isCurrentEvent: Bool {
        let now = Date()
        return startDate <= now && endDate >= now
    }
    
    var isUpcomingEvent: Bool {
        return startDate > Date()
    }
    
    static func == (lhs: AviationEvent, rhs: AviationEvent) -> Bool {
        return lhs.id == rhs.id &&
               lhs.title == rhs.title &&
               lhs.location == rhs.location &&
               lhs.country == rhs.country &&
               lhs.startDate.timeIntervalSince1970 == rhs.startDate.timeIntervalSince1970 &&
               lhs.endDate.timeIntervalSince1970 == rhs.endDate.timeIntervalSince1970 &&
               lhs.eventType == rhs.eventType &&
               lhs.sport == rhs.sport &&
               lhs.discipline == rhs.discipline &&
               lhs.classification == rhs.classification &&
               lhs.organizer == rhs.organizer &&
               lhs.websiteURL == rhs.websiteURL &&
               lhs.faiMiniSiteURL == rhs.faiMiniSiteURL &&
               lhs.description == rhs.description &&
               lhs.documents == rhs.documents &&
               lhs.contactPerson == rhs.contactPerson &&
               lhs.contactEmail == rhs.contactEmail &&
               lhs.contactPhone == rhs.contactPhone &&
               lhs.alternateDates == rhs.alternateDates
    }
}

enum EventType: String, CaseIterable, Codable, Equatable {
    case worldChampionship = "World Championship"
    case continentalChampionship = "Continental Championship"
    case nationalChampionship = "National Championship"
    case secondCategory = "Second Category Event"
    case other = "Other"
    
    var displayName: String {
        switch self {
        case .worldChampionship:
            return "World Championship"
        case .continentalChampionship:
            return "Continental Championship"
        case .nationalChampionship:
            return "National Championship"
        case .secondCategory:
            return "Second Category Event"
        case .other:
            return "Other"
        }
    }
}

enum Sport: String, CaseIterable, Codable, Equatable {
    case aerobatics = "Aerobatics"
    case paragliding = "Paragliding"
    case gliding = "Gliding"
    case hangGliding = "Hang Gliding"
    case ballooning = "Ballooning"
    case skydiving = "Parachuting"
    case microlights = "Microlights"
    case drones = "Drones"
    case generalAviation = "General Aviation"
    case aeromodelling = "Aeromodelling"
    
    var displayName: String {
        switch self {
        case .skydiving:
            return "Parachuting"
        default:
            return self.rawValue
        }
    }
    
    var icon: String {
        switch self {
        case .aerobatics:
            return "airplane.circle.fill"
        case .paragliding:
            return "paraglider.fill"
        case .gliding:
            return "glider.fill"
        case .hangGliding:
            return "hangglider.fill"
        case .ballooning:
            return "balloon.fill"
        case .skydiving:
            return "person.parachute.fill"
        case .microlights:
            return "airplane.departure"
        case .drones:
            return "drone.fill"
        case .generalAviation:
            return "airplane"
        case .aeromodelling:
            return "airplane.circle"
        }
    }
}

enum EventClassification: String, CaseIterable, Codable, Equatable {
    case cat1 = "FAI World and continental championships (CAT.1)"
    case cat2 = "Other upcoming FAI-Sanctioned events (CAT.2)"
    case cat3 = "Other events (CAT.3)"
    
    var displayName: String {
        switch self {
        case .cat1:
            return "FAI World & Continental Championships"
        case .cat2:
            return "FAI-Sanctioned Events"
        case .cat3:
            return "Other Events"
        }
    }
    
    var shortName: String {
        switch self {
        case .cat1:
            return "CAT.1"
        case .cat2:
            return "CAT.2"
        case .cat3:
            return "CAT.3"
        }
    }
}
