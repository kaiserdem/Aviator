import SwiftUI
import ComposableArchitecture

struct AviationSportDetailView: View {
    let sport: AviationSport
    let store: StoreOf<AviationSportsFeature>
    let appStore: StoreOf<AppFeature>
    
    var body: some View {
        ZStack {
            
            AviationGradientBackground()
            
            ScrollView {
            VStack(spacing: 20) {
                
                VStack(spacing: 16) {
                    
                    Image(getSportImageName(for: sport.name))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .clipped()
                        .cornerRadius(16)
                    
                    
                    VStack(spacing: 8) {
                        Text(sport.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        Text(sport.category.rawValue)
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(20)
                        
                        
                        Text(sport.difficulty.rawValue)
                            .font(.headline)
                            .foregroundColor(sport.difficulty.color)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(sport.difficulty.color.opacity(0.1))
                            .cornerRadius(16)
                    }
                }
                .padding(.horizontal)
                
                
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: "Description", icon: "text.alignleft")
                    
                    Text(sport.description)
                        .font(.body)
                        .foregroundColor(.white)
                        .lineSpacing(4)
                }
                .padding(.horizontal)
                
                
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: "Required Equipment", icon: "gear")
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 8) {
                        ForEach(sport.equipment, id: \.self) { equipment in
                            EquipmentCard(equipment: equipment)
                        }
                    }
                }
                .padding(.horizontal)
                
                
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: "Popular Locations", icon: "location")
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(sport.locations, id: \.self) { location in
                                LocationCard(location: location)
                            }
                        }
                        .padding(.horizontal, 1)
                    }
                }
                .padding(.horizontal)
                
                
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: "Rules & Requirements", icon: "list.bullet.clipboard")
                    
                    VStack(spacing: 8) {
                        ForEach(Array(sport.rules.enumerated()), id: \.offset) { index, rule in
                            RuleRow(number: index + 1, rule: rule)
                        }
                    }
                }
                .padding(.horizontal)
                
                
                
                Spacer(minLength: 20)
            }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(sport.name)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    WithViewStore(self.appStore, observe: { $0 }) { appViewStore in
                        Button(action: {
                            print("💖 Button tapped for sport: \(sport.name) (\(sport.id.uuidString))")
                            print("💖 Current favorites: \(appViewStore.favoriteSports)")
                            appViewStore.send(.toggleFavorite(sport.id.uuidString))
                        }) {
                            Image(systemName: appViewStore.favoriteSports.contains(sport.id.uuidString) ? "heart.fill" : "heart")
                                .foregroundColor(appViewStore.favoriteSports.contains(sport.id.uuidString) ? .red : .gray)
                        }
                        .onAppear {
                            print("🔍 DetailView appeared for sport: \(sport.name) (\(sport.id.uuidString))")
                            print("🔍 Is favorite: \(appViewStore.favoriteSports.contains(sport.id.uuidString))")
                            print("🔍 All favorites: \(appViewStore.favoriteSports)")
                        }
                    }
                    
                    ShareLink(item: "\(sport.name) - \(sport.description)", subject: Text(sport.name)) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
        }
    }
    
    private func sportIcon(for category: SportCategory) -> String {
        switch category {
        case .all:
            return "airplane.circle"
        case .aerobatics:
            return "airplane.departure"
        case .gliding:
            return "airplane.arrival"
        case .parachuting:
            return "figure.fall"
        case .ballooning:
            return "balloon"
        case .airRacing:
            return "speedometer"
        case .formationFlying:
            return "airplane"
        case .precisionFlying:
            return "target"
        }
    }
    
    private func sportColor(for category: SportCategory) -> Color {
        switch category {
        case .all:
            return .blue
        case .aerobatics:
            return .red
        case .gliding:
            return .green
        case .parachuting:
            return .orange
        case .ballooning:
            return .purple
        case .airRacing:
            return .yellow
        case .formationFlying:
            return .cyan
        case .precisionFlying:
            return .pink
        }
    }
}

struct SectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.white)
                .font(.title3)
            
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
    }
}

struct EquipmentCard: View {
    let equipment: String
    
    var body: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.caption)
            
            Text(equipment)
                .font(.caption)
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct LocationCard: View {
    let location: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "location.fill")
                .foregroundColor(.red)
                .font(.caption)
            
            Text(location)
                .font(.caption)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.red.opacity(0.1))
        .cornerRadius(20)
    }
}

struct RuleRow: View {
    let number: Int
    let rule: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 20, height: 20)
                .background(Color.blue)
                .cornerRadius(10)
            
            Text(rule)
                .font(.body)
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}


#Preview {
    NavigationStack {
        AviationSportDetailView(
            sport: AviationSport(
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
                ]
            ),
            store: Store(initialState: AviationSportsFeature.State()) {
                AviationSportsFeature()
            },
            appStore: Store(initialState: AppFeature.State()) {
                AppFeature()
            }
        )
    }
}


private func getSportImageName(for sportName: String) -> String {
    
    let sportImageMapping: [String: String] = [
        "Aerobatic Flying": "Aerobatic Flying",
        "Glider Racing": "Glider Racing", 
        "Skydiving Formation": "Skydiving Formation",
        "Hot Air Balloon Racing": "Hot Air Balloon Racing",
        "Air Racing": "Air Racing",
        "Formation Flying": "Formation Flying",
        "Precision Landing": "Precision Landing",
        "Wing Walking": "Wing Walking",
        "Helicopter Precision": "Helicopter Precision",
        "Ultralight Racing": "Ultralight Racing",
        "Aerobatic Helicopter": "Aerobatic Helicopter",
        "Paragliding Cross Country": "Paragliding Cross Country",
        "Base Jumping": "Base Jumping",
        "Aerobatic Glider": "Aerobatic Glider",
        "Hang Gliding Racing": "Hang Gliding Racing",
        "Aerobatic Formation": "Aerobatic Formation",
        "Helicopter Slalom": "Helicopter Slalom",
        "Aerobatic Solo": "Aerobatic Solo",
        "Glider Aerobatics": "Glider Aerobatics",
        "Aerobatic Team": "Aerobatic Team"
    ]
    
    
    return sportImageMapping[sportName] ?? "Aerobatic Flying"
}
