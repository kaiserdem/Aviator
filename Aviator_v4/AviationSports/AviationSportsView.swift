import SwiftUI
import ComposableArchitecture

struct AviationSportsView: View {
    let store: StoreOf<AviationSportsFeature>
    let appStore: StoreOf<AppFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            WithViewStore(self.appStore, observe: { $0 }) { appViewStore in
                let _ = print("🛩️ AviationSportsView: Current favorites: \(viewStore.favoriteSports)")
                let _ = print("🛩️ AviationSportsView: AppStore favorites: \(appViewStore.favoriteSports)")
            NavigationStack {
                ZStack {
                    AviationGradientBackground()
                    
                    VStack(spacing: 16) {
                        VStack(spacing: 12) {
                            HStack {
                                Picker("Category", selection: viewStore.binding(get: \.selectedCategory, send: { .categoryChanged($0) })) {
                                    ForEach(SportCategory.allCases, id: \.self) { category in
                                        HStack {
                                            Image(systemName: categoryIcon(for: category))
                                                .foregroundColor(categoryColor(for: category))
                                            Text(category.rawValue)
                                        }.tag(category)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                
                                Spacer()
                                
                                Picker("Location", selection: viewStore.binding(get: \.selectedLocation, send: { .locationChanged($0) })) {
                                    HStack {
                                        Image(systemName: "globe")
                                            .foregroundColor(.blue)
                                        Text("Global")
                                    }.tag("Global")
                                    HStack {
                                        Image(systemName: "flag")
                                            .foregroundColor(.red)
                                        Text("United States")
                                    }.tag("United States")
                                    HStack {
                                        Image(systemName: "flag")
                                            .foregroundColor(.blue)
                                        Text("Europe")
                                    }.tag("Europe")
                                    HStack {
                                        Image(systemName: "flag")
                                            .foregroundColor(.green)
                                        Text("Australia")
                                    }.tag("Australia")
                                    HStack {
                                        Image(systemName: "flag")
                                            .foregroundColor(.orange)
                                        Text("Asia")
                                    }.tag("Asia")
                                }
                                .pickerStyle(MenuPickerStyle())
                            }
                            
                        }
                        .padding()
                        
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
                                NavigationLink(destination: AviationSportDetailView(sport: sport, store: self.store, appStore: self.appStore)) {
                                    AviationSportRowView(sport: sport)
                                }
                                .onAppear {
                                    
                                    if sport.imageURL == nil {
                                        viewStore.send(.loadSportImage(sport.id.uuidString, sport.name))
                                    }
                                }
                                .id(sport.id) 
                            }
                            .listStyle(PlainListStyle()) 
                            .scrollContentBackground(.hidden) 
                            .listRowSeparator(.hidden) 
                            .listRowBackground(Color.clear) 
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
    
    private func categoryIcon(for category: SportCategory) -> String {
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
    
    private func categoryColor(for category: SportCategory) -> Color {
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

struct AviationSportRowView: View {
    let sport: AviationSport
    
    var body: some View {
        HStack(spacing: 12) {
            
            VStack {
                Image(getSportImageName(for: sport.name))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .background(sportColor(for: sport.category).opacity(0.1))
                    .cornerRadius(12)
                    .clipped()
            }
            
            
            VStack(alignment: .leading, spacing: 12) {
                
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
                    }
                }
            
            
            Text(sport.description)
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(3)
            
            
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
            
            }

        }
        .padding(.vertical, 8)
        .id(sport.id) 
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
        },
        appStore: Store(initialState: AppFeature.State()) {
            AppFeature()
        }
    )
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
