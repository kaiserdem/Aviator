import SwiftUI
import ComposableArchitecture

struct AviationSportsView: View {
    let store: StoreOf<AviationSportsFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationStack {
                ZStack {
                    // Градієнтний фон
                    AviationGradientBackground()
                    
                    VStack(spacing: 16) {
                        // Filter Section
                        VStack(spacing: 12) {
                            HStack {
                                Text("Category:")
                                    .foregroundColor(.white)
                                    .fontWeight(.medium)
                                Picker("Category", selection: viewStore.binding(get: \.selectedCategory, send: { .categoryChanged($0) })) {
                                    ForEach(SportCategory.allCases, id: \.self) { category in
                                        Text(category.rawValue).tag(category)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                
                                Spacer()
                                
                                Text("Location:")
                                    .foregroundColor(.white)
                                    .fontWeight(.medium)
                                Picker("Location", selection: viewStore.binding(get: \.selectedLocation, send: { .locationChanged($0) })) {
                                    Text("Global").tag("Global")
                                    Text("United States").tag("United States")
                                    Text("Europe").tag("Europe")
                                    Text("Australia").tag("Australia")
                                    Text("Asia").tag("Asia")
                                }
                                .pickerStyle(MenuPickerStyle())
                            }
                            
                            Button("Refresh Sports") {
                                viewStore.send(.loadSports)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.white)
                            .foregroundColor(.buttonTextColor)
                        }
                        .padding()
                        
                        // Content
                        if viewStore.isLoading {
                            ProgressView("Loading aviation sports...")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else if let errorMessage = viewStore.errorMessage {
                            VStack {
                                Image(systemName: "exclamationmark.triangle")
                                    .font(.largeTitle)
                                    .foregroundColor(.red)
                                Text("Error: \(errorMessage)")
                                    .foregroundColor(.red)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else if viewStore.sports.isEmpty {
                            VStack {
                                Image(systemName: "airplane.circle")
                                    .font(.largeTitle)
                                    .foregroundColor(.gray)
                                Text("No sports found")
                                    .foregroundColor(.white)
                                Text("Try adjusting your filters")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            List(viewStore.sports) { sport in
                                NavigationLink(destination: AviationSportDetailView(sport: sport, store: self.store)) {
                                    AviationSportRowView(sport: sport)
                                }
                                .onAppear {
                                    // Завантажуємо зображення тільки один раз
                                    if sport.imageURL == nil {
                                        viewStore.send(.loadSportImage(sport.id.uuidString, sport.name))
                                    }
                                }
                                .id(sport.id) // Стабільний ID для кожного елемента
                            }
                            .listStyle(PlainListStyle()) // Використовуємо PlainListStyle для стабільності
                            .scrollContentBackground(.hidden) // Приховуємо фон для градієнта
                            .listRowSeparator(.hidden) // Приховуємо роздільники рядків
                            .listRowBackground(Color.clear) // Прозорий фон для рядків
                        }
                    }
                    .navigationTitle("Aviation Sports")
                    .navigationBarTitleDisplayMode(.large)
                    .toolbarColorScheme(.dark, for: .navigationBar)
                    .onAppear {
                        viewStore.send(.onAppear)
                    }
                }
            }
            .id("aviationSportsNavigation")
        }
    }
}

struct AviationSportRowView: View {
    let sport: AviationSport
    
    var body: some View {
        HStack(spacing: 12) {
            // Sport Image
            VStack {
                if let imageURL = sport.imageURL, let url = URL(string: imageURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 60, height: 60)
                                .background(sportColor(for: sport.category).opacity(0.1))
                                .cornerRadius(12)
                                .clipped()
                        case .failure(_):
                            Image(systemName: sportIcon(for: sport.category))
                                .font(.system(size: 30))
                                .foregroundColor(sportColor(for: sport.category))
                                .frame(width: 60, height: 60)
                                .background(sportColor(for: sport.category).opacity(0.1))
                                .cornerRadius(12)
                        case .empty:
                            Image(systemName: sportIcon(for: sport.category))
                                .font(.system(size: 30))
                                .foregroundColor(sportColor(for: sport.category))
                                .frame(width: 60, height: 60)
                                .background(sportColor(for: sport.category).opacity(0.1))
                                .cornerRadius(12)
                        @unknown default:
                            Image(systemName: sportIcon(for: sport.category))
                                .font(.system(size: 30))
                                .foregroundColor(sportColor(for: sport.category))
                                .frame(width: 60, height: 60)
                                .background(sportColor(for: sport.category).opacity(0.1))
                                .cornerRadius(12)
                        }
                    }
                } else {
                    Image(systemName: sportIcon(for: sport.category))
                        .font(.system(size: 40))
                        .foregroundColor(sportColor(for: sport.category))
                        .frame(width: 60, height: 60)
                        .background(sportColor(for: sport.category).opacity(0.1))
                        .cornerRadius(12)
                }
            }
            
            // Content
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(sport.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text(sport.category.rawValue)
                            .font(.caption)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(4)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(sport.difficulty.rawValue)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(sport.difficulty.color)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(sport.difficulty.color.opacity(0.1))
                            .cornerRadius(4)
                        
                        Text("\(sport.competitions.count) competitions")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            
            // Description
            Text(sport.description)
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(3)
            
            // Equipment
            if !sport.equipment.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Equipment:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 6) {
                        ForEach(sport.equipment, id: \.self) { equipment in
                            Text(equipment)
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.gray.opacity(0.1))
                                .foregroundColor(.gray)
                                .cornerRadius(4)
                        }
                    }
                    .padding(.horizontal, 1)
                }
            }
            
            // Locations
            if !sport.locations.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Popular Locations:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(sport.locations.joined(separator: ", "))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Competitions Preview
            if !sport.competitions.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Upcoming Competitions:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    ForEach(sport.competitions.prefix(2)) { competition in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(competition.name)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                
                                Text("\(competition.date) • \(competition.location)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Text(competition.type.rawValue)
                                .font(.caption2)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    if sport.competitions.count > 2 {
                        Text("+ \(sport.competitions.count - 2) more competitions")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            }

        }
        .padding(.vertical, 8)
        .id(sport.id) // Стабільний ID для кожного рядка
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

#Preview {
    AviationSportsView(
        store: Store(initialState: AviationSportsFeature.State()) {
            AviationSportsFeature()
        }
    )
}
