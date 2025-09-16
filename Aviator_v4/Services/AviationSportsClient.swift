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
                id: UUID(uuidString: "52626D95-4C17-4EBB-9A47-F9AC1CB3074D") ?? UUID()
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
                id: UUID(uuidString: "439D3D90-7207-499B-A3E7-1B89B3F639AD") ?? UUID()
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
                id: UUID(uuidString: "7F8E9A2B-1C3D-4E5F-6A7B-8C9D0E1F2A3B") ?? UUID()
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
                id: UUID(uuidString: "A1B2C3D4-E5F6-7890-ABCD-EF1234567890") ?? UUID()
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
                id: UUID(uuidString: "B2C3D4E5-F6G7-8901-BCDE-F23456789012") ?? UUID()
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
                id: UUID(uuidString: "C3D4E5F6-G7H8-9012-CDEF-345678901234") ?? UUID()
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
                id: UUID(uuidString: "D4E5F6G7-H8I9-0123-DEFG-456789012345") ?? UUID()
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
                id: UUID(uuidString: "E5F6G7H8-I9J0-1234-EFGH-567890123456") ?? UUID()
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
                id: UUID(uuidString: "H8I9J0K1-L2M3-4567-HIJK-890123456789") ?? UUID()
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
    let id: UUID
    let name: String
    let category: SportCategory
    let description: String
    let difficulty: DifficultyLevel
    let equipment: [String]
    let locations: [String]
    let imageURL: String?
    let rules: [String]
    
    init(name: String, category: SportCategory, description: String, difficulty: DifficultyLevel, equipment: [String], locations: [String], imageURL: String? = nil, rules: [String], id: UUID = UUID()) {
        self.id = id
        self.name = name
        self.category = category
        self.description = description
        self.difficulty = difficulty
        self.equipment = equipment
        self.locations = locations
        self.imageURL = imageURL
        self.rules = rules
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
               lhs.rules == rhs.rules
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
