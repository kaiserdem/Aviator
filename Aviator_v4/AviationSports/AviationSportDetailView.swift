import SwiftUI
import ComposableArchitecture

struct AviationSportDetailView: View {
    let sport: AviationSport
    let store: StoreOf<AviationSportsFeature>
    
    var body: some View {
        ZStack {
            // Градієнтний фон
            AviationGradientBackground()
            
            ScrollView {
            VStack(spacing: 20) {
                // Header Section
                VStack(spacing: 16) {
                    // Sport Image
                    if let imageURL = sport.imageURL, let url = URL(string: imageURL) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Image(systemName: sportIcon(for: sport.category))
                                .font(.system(size: 80))
                                .foregroundColor(sportColor(for: sport.category))
                        }
                        .frame(height: 200)
                        .clipped()
                        .cornerRadius(16)
                    } else {
                        Image(systemName: sportIcon(for: sport.category))
                            .font(.system(size: 80))
                            .foregroundColor(sportColor(for: sport.category))
                            .frame(height: 200)
                            .frame(maxWidth: .infinity)
                            .background(sportColor(for: sport.category).opacity(0.1))
                            .cornerRadius(16)
                    }
                    
                    // Title and Category
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
                        
                        // Difficulty Badge
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
                
                // Description Section
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: "Description", icon: "text.alignleft")
                    
                    Text(sport.description)
                        .font(.body)
                        .foregroundColor(.white)
                        .lineSpacing(4)
                }
                .padding(.horizontal)
                
                // Equipment Section
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
                
                // Locations Section
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
                
                // Rules Section
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: "Rules & Requirements", icon: "list.bullet.clipboard")
                    
                    VStack(spacing: 8) {
                        ForEach(Array(sport.rules.enumerated()), id: \.offset) { index, rule in
                            RuleRow(number: index + 1, rule: rule)
                        }
                    }
                }
                .padding(.horizontal)
                
                // Competitions Section
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: "Upcoming Competitions", icon: "trophy")
                    
                    VStack(spacing: 12) {
                        ForEach(sport.competitions) { competition in
                            CompetitionCard(competition: competition)
                        }
                    }
                }
                .padding(.horizontal)
                
                // Bottom Spacing
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
                    WithViewStore(self.store, observe: { $0 }) { viewStore in
                        Button(action: {
                            viewStore.send(.toggleFavorite(sport.id.uuidString))
                        }) {
                            Image(systemName: viewStore.favoriteSports.contains(sport.id.uuidString) ? "heart.fill" : "heart")
                                .foregroundColor(viewStore.favoriteSports.contains(sport.id.uuidString) ? .red : .gray)
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

struct CompetitionCard: View {
    let competition: Competition
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(competition.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(competition.type.rawValue)
                        .font(.caption)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(4)
                }
                
                Spacer()
                
                if let prize = competition.prize {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Prize")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Text(prize)
                            .font(.headline)
                            .foregroundColor(.green)
                    }
                }
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                        Text("Date")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.7))
                        
                        Text(competition.date)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Location")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text(competition.location)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
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
                ],
                competitions: [
                    Competition(name: "World Aerobatic Championship", date: "2024-08-15", location: "France", type: .worldChampionship, prize: "$50,000"),
                    Competition(name: "US National Aerobatic Championship", date: "2024-07-20", location: "Denver, CO", type: .nationalChampionship, prize: "$25,000")
                ]
            ),
            store: Store(initialState: AviationSportsFeature.State()) {
                AviationSportsFeature()
            }
        )
    }
}
