import Foundation
import ComposableArchitecture

struct AviationSportsClient {
    var getSports: (SportCategory, String) async -> [AviationSport]
}

extension AviationSportsClient: DependencyKey {
    static let liveValue = Self(
        getSports: { category, location in
            await AviationSportsService.shared.getSports(category: category, location: location)
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
            )
        ]
    }
}
