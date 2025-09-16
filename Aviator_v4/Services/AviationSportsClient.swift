import Foundation
import ComposableArchitecture
import SwiftUI

struct AviationSportsClient {
    var getSports: (SportCategory, String) async -> [AviationSport]
    var getSportImage: (String) async -> String?
    var getSportDescription: (String) async -> String?
}

extension AviationSportsClient: DependencyKey {
    static let liveValue = Self(
        getSports: { category, location in
            await AviationSportsService.shared.getSports(category: category, location: location)
        },
        getSportImage: { sportName in
            await AviationSportsService.shared.getSportImage(sportName: sportName)
        },
        getSportDescription: { sportName in
            await AviationSportsService.shared.getSportDescription(sportName: sportName)
        }
    )
}

extension DependencyValues {
    var aviationSportsClient: AviationSportsClient {
        get { self[AviationSportsClient.self] }
        set { self[AviationSportsClient.self] = newValue }
    }
}

// MARK: - Aviation Sports Service

final class AviationSportsService {
    static let shared = AviationSportsService()
    
    private init() {}
    
    func getSportImage(sportName: String) async -> String? {
        // For demo purposes, return mock images
        // In production, replace with real Unsplash API call
        return getMockImageURL(for: sportName)
        
        // Uncomment this when you have a real Unsplash API key:
        // @Dependency(\.unsplashClient) var unsplashClient
        // return await unsplashClient.searchImage(sportName)
    }
    
    func getSportDescription(sportName: String) async -> String? {
        @Dependency(\.wikipediaClient) var wikipediaClient
        return await wikipediaClient.getSportDescription(sportName)
    }
    
    private func getMockImageURL(for sportName: String) -> String? {
        // Тимчасове рішення - використовуємо одне зображення з Pexels для всіх спорту
        return "https://images.pexels.com/photos/19571069/pexels-photo-19571069.jpeg"
    }
    
    func getSports(category: SportCategory, location: String) async -> [AviationSport] {
        // Simulate API call delay
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        let allSports = generateAviationSports()
        
        var filteredSports = allSports
        
        // Filter by category
        if category != .all {
            filteredSports = filteredSports.filter { $0.category == category }
        }
        
        // Filter by location
        if location != "Global" {
            filteredSports = filteredSports.filter { sport in
                sport.locations.contains { $0.lowercased().contains(location.lowercased()) }
            }
        }
        
        return filteredSports
    }
    
    private func generateAviationSports() -> [AviationSport] {
        return [
            AviationSport(
                name: "Aerobatic Flying",
                category: .aerobatics,
                description: "High-performance flying involving complex maneuvers and stunts in the air. Pilots perform loops, rolls, spins, and other precision maneuvers.",
                difficulty: .expert,
                equipment: ["Aerobatic Aircraft", "G-Suit", "Parachute", "Helmet"],
                locations: ["United States", "France", "Russia", "Germany"],
                imageURL: nil,
                rules: [
                    "Minimum 200 hours flight experience required",
                    "Aerobatic rating certification mandatory",
                    "Annual medical examination required",
                    "Aircraft must be certified for aerobatic flight"
                ],
                competitions: [
                    Competition(name: "World Aerobatic Championship", date: "2024-08-15", location: "France", type: .worldChampionship, prize: "$50,000"),
                    Competition(name: "US National Aerobatic Championship", date: "2024-07-20", location: "Denver, CO", type: .nationalChampionship, prize: "$25,000")
                ]
            ),
            
            AviationSport(
                name: "Glider Racing",
                category: .gliding,
                description: "Competitive soaring using unpowered aircraft. Pilots use thermal currents and other atmospheric phenomena to stay aloft and complete courses.",
                difficulty: .advanced,
                equipment: ["Glider", "Parachute", "Radio", "GPS Navigation"],
                locations: ["Germany", "Australia", "South Africa", "Poland"],
                imageURL: nil,
                rules: [
                    "Glider pilot license required",
                    "Minimum 100 hours glider experience",
                    "Weather briefing mandatory before each flight",
                    "Radio communication required"
                ],
                competitions: [
                    Competition(name: "World Gliding Championship", date: "2024-09-10", location: "Germany", type: .worldChampionship, prize: "$30,000"),
                    Competition(name: "Australian Gliding Nationals", date: "2024-06-15", location: "Narromine, NSW", type: .nationalChampionship, prize: "$15,000")
                ]
            ),
            
            AviationSport(
                name: "Skydiving Formation",
                category: .parachuting,
                description: "Team-based skydiving where groups of jumpers create geometric formations in freefall. Requires precise timing and coordination.",
                difficulty: .intermediate,
                equipment: ["Parachute System", "Altimeter", "Helmet", "Goggles", "Jump Suit"],
                locations: ["United States", "Spain", "Brazil", "Thailand"],
                imageURL: nil,
                rules: [
                    "Minimum 200 jumps required",
                    "Formation skydiving rating",
                    "Team coordination training mandatory",
                    "Safety equipment inspection required"
                ],
                competitions: [
                    Competition(name: "World Formation Skydiving Championship", date: "2024-10-05", location: "Spain", type: .worldChampionship, prize: "$40,000"),
                    Competition(name: "USPA National Championships", date: "2024-08-25", location: "Arizona", type: .nationalChampionship, prize: "$20,000")
                ]
            ),
            
            AviationSport(
                name: "Hot Air Balloon Racing",
                category: .ballooning,
                description: "Competitive ballooning where pilots navigate to specific targets using only wind currents and altitude changes.",
                difficulty: .intermediate,
                equipment: ["Hot Air Balloon", "Basket", "Burner", "GPS", "Radio"],
                locations: ["United States", "France", "Switzerland", "Japan"],
                imageURL: nil,
                rules: [
                    "Balloon pilot license required",
                    "Weather assessment mandatory",
                    "Radio communication with ground crew",
                    "Minimum 50 hours balloon experience"
                ],
                competitions: [
                    Competition(name: "World Hot Air Balloon Championship", date: "2024-11-12", location: "Switzerland", type: .worldChampionship, prize: "$35,000"),
                    Competition(name: "Albuquerque International Balloon Fiesta", date: "2024-10-01", location: "New Mexico", type: .exhibition, prize: "$10,000")
                ]
            ),
            
            AviationSport(
                name: "Air Racing",
                category: .airRacing,
                description: "High-speed racing around pylons at low altitude. Pilots compete in modified aircraft for speed and precision.",
                difficulty: .expert,
                equipment: ["Racing Aircraft", "Safety Equipment", "Radio", "GPS"],
                locations: ["United States", "United Kingdom", "Australia"],
                imageURL: nil,
                rules: [
                    "Commercial pilot license required",
                    "Minimum 500 hours flight time",
                    "Aircraft modification certification",
                    "Annual safety inspection mandatory"
                ],
                competitions: [
                    Competition(name: "Reno Air Races", date: "2024-09-15", location: "Reno, NV", type: .worldChampionship, prize: "$100,000"),
                    Competition(name: "Red Bull Air Race", date: "2024-07-30", location: "UK", type: .worldChampionship, prize: "$75,000")
                ]
            ),
            
            AviationSport(
                name: "Formation Flying",
                category: .formationFlying,
                description: "Precision flying in close formation with other aircraft. Requires exceptional skill and coordination between pilots.",
                difficulty: .advanced,
                equipment: ["Formation Aircraft", "Radio", "Formation Lights", "Safety Equipment"],
                locations: ["United States", "Canada", "United Kingdom", "France"],
                imageURL: nil,
                rules: [
                    "Formation flying certification required",
                    "Minimum 300 hours flight time",
                    "Team training mandatory",
                    "Safety briefing before each flight"
                ],
                competitions: [
                    Competition(name: "World Formation Flying Championship", date: "2024-08-20", location: "France", type: .worldChampionship, prize: "$45,000"),
                    Competition(name: "Canadian Formation Flying Nationals", date: "2024-07-10", location: "Ontario", type: .nationalChampionship, prize: "$18,000")
                ]
            ),
            
            AviationSport(
                name: "Precision Landing",
                category: .precisionFlying,
                description: "Competition focused on landing accuracy and precision. Pilots must land as close as possible to a designated target.",
                difficulty: .beginner,
                equipment: ["Training Aircraft", "Landing Gear", "GPS", "Measuring Equipment"],
                locations: ["United States", "Germany", "Australia", "Canada"],
                imageURL: nil,
                rules: [
                    "Private pilot license required",
                    "Minimum 50 hours flight time",
                    "Precision landing training",
                    "Aircraft weight and balance check"
                ],
                competitions: [
                    Competition(name: "World Precision Landing Championship", date: "2024-09-05", location: "Germany", type: .worldChampionship, prize: "$25,000"),
                    Competition(name: "EAA AirVenture Landing Contest", date: "2024-07-25", location: "Oshkosh, WI", type: .exhibition, prize: "$5,000")
                ]
            ),
            
            AviationSport(
                name: "Wing Walking",
                category: .aerobatics,
                description: "Extreme sport where performers walk on the wings of an aircraft while it's in flight. Requires exceptional balance and courage.",
                difficulty: .expert,
                equipment: ["Biplane", "Safety Harness", "Helmet", "Specialized Boots"],
                locations: ["United States", "United Kingdom", "Australia"],
                imageURL: nil,
                rules: [
                    "Minimum 500 hours flight experience",
                    "Specialized wing walking certification",
                    "Annual medical examination",
                    "Safety harness mandatory at all times"
                ],
                competitions: [
                    Competition(name: "World Wing Walking Championship", date: "2024-08-30", location: "UK", type: .worldChampionship, prize: "$60,000"),
                    Competition(name: "US Wing Walking Nationals", date: "2024-07-15", location: "California", type: .nationalChampionship, prize: "$30,000")
                ]
            ),
            
            AviationSport(
                name: "Helicopter Precision",
                category: .precisionFlying,
                description: "Competitive helicopter flying focusing on precision maneuvers, hovering accuracy, and obstacle navigation.",
                difficulty: .advanced,
                equipment: ["Helicopter", "GPS", "Radio", "Safety Equipment"],
                locations: ["United States", "France", "Japan", "Canada"],
                imageURL: nil,
                rules: [
                    "Commercial helicopter license required",
                    "Minimum 200 hours helicopter time",
                    "Precision flying certification",
                    "Weather assessment mandatory"
                ],
                competitions: [
                    Competition(name: "World Helicopter Precision Championship", date: "2024-10-20", location: "France", type: .worldChampionship, prize: "$45,000"),
                    Competition(name: "Heli-Expo Precision Contest", date: "2024-03-15", location: "Las Vegas", type: .exhibition, prize: "$15,000")
                ]
            ),
            
            AviationSport(
                name: "Ultralight Racing",
                category: .airRacing,
                description: "High-speed racing with ultralight aircraft around pylons at low altitude. Requires exceptional piloting skills.",
                difficulty: .advanced,
                equipment: ["Ultralight Aircraft", "Safety Gear", "Radio", "GPS"],
                locations: ["United States", "Australia", "New Zealand"],
                imageURL: nil,
                rules: [
                    "Ultralight pilot license required",
                    "Minimum 100 hours ultralight experience",
                    "Aircraft modification certification",
                    "Annual safety inspection"
                ],
                competitions: [
                    Competition(name: "World Ultralight Championship", date: "2024-09-25", location: "Australia", type: .worldChampionship, prize: "$35,000"),
                    Competition(name: "US Ultralight Nationals", date: "2024-08-10", location: "Texas", type: .nationalChampionship, prize: "$18,000")
                ]
            ),
            
            AviationSport(
                name: "Aerobatic Helicopter",
                category: .aerobatics,
                description: "Advanced helicopter aerobatics including loops, rolls, and inverted flight. Extremely challenging and dangerous.",
                difficulty: .expert,
                equipment: ["Aerobatic Helicopter", "G-Suit", "Parachute", "Helmet"],
                locations: ["Russia", "United States", "France"],
                imageURL: nil,
                rules: [
                    "Commercial helicopter license required",
                    "Minimum 500 hours helicopter time",
                    "Aerobatic helicopter rating",
                    "Annual medical examination"
                ],
                competitions: [
                    Competition(name: "World Helicopter Aerobatic Championship", date: "2024-11-05", location: "Russia", type: .worldChampionship, prize: "$80,000"),
                    Competition(name: "Heli-Expo Aerobatic Contest", date: "2024-03-20", location: "Las Vegas", type: .exhibition, prize: "$25,000")
                ]
            ),
            
            AviationSport(
                name: "Paragliding Cross Country",
                category: .gliding,
                description: "Long-distance paragliding competitions where pilots fly cross-country routes using thermal currents.",
                difficulty: .advanced,
                equipment: ["Paraglider", "Harness", "Reserve Parachute", "GPS", "Radio"],
                locations: ["France", "Spain", "Austria", "Chile"],
                imageURL: nil,
                rules: [
                    "Paragliding license required",
                    "Minimum 200 hours paragliding experience",
                    "Cross-country certification",
                    "Weather briefing mandatory"
                ],
                competitions: [
                    Competition(name: "World Paragliding Championship", date: "2024-07-30", location: "Spain", type: .worldChampionship, prize: "$40,000"),
                    Competition(name: "European Paragliding Cup", date: "2024-06-20", location: "France", type: .regionalChampionship, prize: "$20,000")
                ]
            ),
            
            AviationSport(
                name: "Base Jumping",
                category: .parachuting,
                description: "Extreme sport involving jumping from fixed objects using parachutes. Requires exceptional skill and courage.",
                difficulty: .expert,
                equipment: ["Base Parachute", "Helmet", "Goggles", "Jump Suit"],
                locations: ["United States", "Norway", "Switzerland", "Italy"],
                imageURL: nil,
                rules: [
                    "Minimum 200 skydiving jumps required",
                    "Base jumping certification",
                    "Site-specific training mandatory",
                    "Safety equipment inspection"
                ],
                competitions: [
                    Competition(name: "World Base Jumping Championship", date: "2024-09-15", location: "Norway", type: .worldChampionship, prize: "$50,000"),
                    Competition(name: "European Base Jumping Cup", date: "2024-08-05", location: "Switzerland", type: .regionalChampionship, prize: "$25,000")
                ]
            ),
            
            AviationSport(
                name: "Aerobatic Glider",
                category: .aerobatics,
                description: "Aerobatic maneuvers performed in gliders, including loops, rolls, and spins. Requires exceptional skill.",
                difficulty: .expert,
                equipment: ["Aerobatic Glider", "Parachute", "Helmet", "G-Suit"],
                locations: ["Germany", "France", "United States"],
                imageURL: nil,
                rules: [
                    "Glider pilot license required",
                    "Minimum 300 hours glider experience",
                    "Aerobatic glider rating",
                    "Annual medical examination"
                ],
                competitions: [
                    Competition(name: "World Aerobatic Glider Championship", date: "2024-08-25", location: "Germany", type: .worldChampionship, prize: "$55,000"),
                    Competition(name: "US Aerobatic Glider Nationals", date: "2024-07-10", location: "Colorado", type: .nationalChampionship, prize: "$28,000")
                ]
            ),
            
            AviationSport(
                name: "Hang Gliding Racing",
                category: .gliding,
                description: "Competitive hang gliding around courses using thermal currents and ridge lift for speed and distance.",
                difficulty: .advanced,
                equipment: ["Hang Glider", "Harness", "Reserve Parachute", "GPS", "Radio"],
                locations: ["United States", "Australia", "Brazil", "France"],
                imageURL: nil,
                rules: [
                    "Hang gliding license required",
                    "Minimum 150 hours hang gliding experience",
                    "Racing certification",
                    "Weather assessment mandatory"
                ],
                competitions: [
                    Competition(name: "World Hang Gliding Championship", date: "2024-10-10", location: "Brazil", type: .worldChampionship, prize: "$45,000"),
                    Competition(name: "US Hang Gliding Nationals", date: "2024-09-05", location: "Utah", type: .nationalChampionship, prize: "$22,000")
                ]
            ),
            
            AviationSport(
                name: "Aerobatic Formation",
                category: .formationFlying,
                description: "Precision aerobatic maneuvers performed in close formation with other aircraft. Extremely challenging and dangerous.",
                difficulty: .expert,
                equipment: ["Aerobatic Aircraft", "Formation Lights", "Radio", "Safety Equipment"],
                locations: ["United States", "France", "United Kingdom"],
                imageURL: nil,
                rules: [
                    "Commercial pilot license required",
                    "Minimum 500 hours flight time",
                    "Formation aerobatic certification",
                    "Team training mandatory"
                ],
                competitions: [
                    Competition(name: "World Aerobatic Formation Championship", date: "2024-09-20", location: "France", type: .worldChampionship, prize: "$70,000"),
                    Competition(name: "EAA AirVenture Formation Contest", date: "2024-07-30", location: "Oshkosh", type: .exhibition, prize: "$20,000")
                ]
            ),
            
            AviationSport(
                name: "Helicopter Slalom",
                category: .precisionFlying,
                description: "Competitive helicopter flying through slalom courses with precision timing and accuracy.",
                difficulty: .intermediate,
                equipment: ["Helicopter", "GPS", "Radio", "Safety Equipment"],
                locations: ["United States", "Canada", "Germany"],
                imageURL: nil,
                rules: [
                    "Private helicopter license required",
                    "Minimum 100 hours helicopter time",
                    "Slalom flying certification",
                    "Safety briefing mandatory"
                ],
                competitions: [
                    Competition(name: "World Helicopter Slalom Championship", date: "2024-08-15", location: "Germany", type: .worldChampionship, prize: "$30,000"),
                    Competition(name: "Canadian Helicopter Slalom", date: "2024-07-25", location: "Ontario", type: .nationalChampionship, prize: "$15,000")
                ]
            ),
            
            AviationSport(
                name: "Aerobatic Solo",
                category: .aerobatics,
                description: "Individual aerobatic performances with complex sequences of maneuvers. Requires exceptional skill and precision.",
                difficulty: .expert,
                equipment: ["Aerobatic Aircraft", "G-Suit", "Parachute", "Helmet"],
                locations: ["United States", "France", "Germany", "Russia"],
                imageURL: nil,
                rules: [
                    "Commercial pilot license required",
                    "Minimum 400 hours flight time",
                    "Aerobatic solo rating",
                    "Annual medical examination"
                ],
                competitions: [
                    Competition(name: "World Aerobatic Solo Championship", date: "2024-10-05", location: "France", type: .worldChampionship, prize: "$65,000"),
                    Competition(name: "US Aerobatic Solo Nationals", date: "2024-08-20", location: "Denver", type: .nationalChampionship, prize: "$32,000")
                ]
            ),
            
            AviationSport(
                name: "Glider Aerobatics",
                category: .aerobatics,
                description: "Aerobatic maneuvers performed in gliders, including loops, rolls, and spins. Requires exceptional skill.",
                difficulty: .expert,
                equipment: ["Aerobatic Glider", "Parachute", "Helmet", "G-Suit"],
                locations: ["Germany", "France", "United States"],
                imageURL: nil,
                rules: [
                    "Glider pilot license required",
                    "Minimum 300 hours glider experience",
                    "Aerobatic glider rating",
                    "Annual medical examination"
                ],
                competitions: [
                    Competition(name: "World Glider Aerobatic Championship", date: "2024-08-25", location: "Germany", type: .worldChampionship, prize: "$55,000"),
                    Competition(name: "US Glider Aerobatic Nationals", date: "2024-07-10", location: "Colorado", type: .nationalChampionship, prize: "$28,000")
                ]
            ),
            
            AviationSport(
                name: "Aerobatic Team",
                category: .formationFlying,
                description: "Team-based aerobatic performances with multiple aircraft performing synchronized maneuvers in formation.",
                difficulty: .expert,
                equipment: ["Aerobatic Aircraft", "Formation Lights", "Radio", "Safety Equipment"],
                locations: ["United States", "France", "United Kingdom", "Russia"],
                imageURL: nil,
                rules: [
                    "Commercial pilot license required",
                    "Minimum 500 hours flight time",
                    "Formation aerobatic certification",
                    "Team coordination training mandatory"
                ],
                competitions: [
                    Competition(name: "World Aerobatic Team Championship", date: "2024-09-30", location: "France", type: .worldChampionship, prize: "$75,000"),
                    Competition(name: "US Aerobatic Team Nationals", date: "2024-08-25", location: "Denver", type: .nationalChampionship, prize: "$35,000")
                ]
            )
        ]
    }
}

// MARK: - Models

enum SportCategory: String, CaseIterable, Equatable {
    case all = "All"
    case aerobatics = "Aerobatics"
    case gliding = "Gliding"
    case parachuting = "Parachuting"
    case ballooning = "Ballooning"
    case airRacing = "Air Racing"
    case formationFlying = "Formation Flying"
    case precisionFlying = "Precision Flying"
}

struct AviationSport: Equatable, Identifiable {
    let id = UUID()
    let name: String
    let category: SportCategory
    let description: String
    let difficulty: DifficultyLevel
    let equipment: [String]
    let locations: [String]
    let imageURL: String?
    let rules: [String]
    let competitions: [Competition]
    
    init(name: String, category: SportCategory, description: String, difficulty: DifficultyLevel, equipment: [String], locations: [String], imageURL: String? = nil, rules: [String], competitions: [Competition]) {
        self.name = name
        self.category = category
        self.description = description
        self.difficulty = difficulty
        self.equipment = equipment
        self.locations = locations
        self.imageURL = imageURL
        self.rules = rules
        self.competitions = competitions
    }
    
    static func == (lhs: AviationSport, rhs: AviationSport) -> Bool {
        return lhs.id == rhs.id &&
               lhs.name == rhs.name &&
               lhs.category == rhs.category &&
               lhs.description == rhs.description &&
               lhs.difficulty == rhs.difficulty &&
               lhs.equipment == rhs.equipment &&
               lhs.locations == rhs.locations &&
               lhs.imageURL == rhs.imageURL &&
               lhs.rules == rhs.rules &&
               lhs.competitions == rhs.competitions
    }
}

enum DifficultyLevel: String, CaseIterable, Equatable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    case expert = "Expert"
    
    var color: Color {
        switch self {
        case .beginner: return .green
        case .intermediate: return .blue
        case .advanced: return .orange
        case .expert: return .red
        }
    }
}

struct Competition: Equatable, Identifiable {
    let id = UUID()
    let name: String
    let date: String
    let location: String
    let type: CompetitionType
    let prize: String?
    
    init(name: String, date: String, location: String, type: CompetitionType, prize: String? = nil) {
        self.name = name
        self.date = date
        self.location = location
        self.type = type
        self.prize = prize
    }
    
    static func == (lhs: Competition, rhs: Competition) -> Bool {
        return lhs.id == rhs.id &&
               lhs.name == rhs.name &&
               lhs.date == rhs.date &&
               lhs.location == rhs.location &&
               lhs.type == rhs.type &&
               lhs.prize == rhs.prize
    }
}

enum CompetitionType: String, CaseIterable, Equatable {
    case worldChampionship = "World Championship"
    case nationalChampionship = "National Championship"
    case regionalChampionship = "Regional Championship"
    case localCompetition = "Local Competition"
    case exhibition = "Exhibition"
}