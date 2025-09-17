import SwiftUI
import ComposableArchitecture

struct FavoritesView: View {
    let store: StoreOf<FavoritesFeature>
    let appStore: StoreOf<AppFeature>
    @State private var scrollViewId = UUID()
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            WithViewStore(self.appStore, observe: { $0 }) { appViewStore in
            NavigationStack {
                ZStack {
                    
                    AviationGradientBackground()
                    
                    VStack(spacing: 16) {
                        
                        VStack(spacing: 8) {
                           
                            
                            Text("Sports you've marked as favorites")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(.top)
                        
                        
                        if viewStore.isLoading {
                            ProgressView("Loading favorites...")
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
                        } else if viewStore.favoriteSports.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "heart")
                                    .font(.system(size: 60))
                                    .foregroundColor(.gray)
                                
                                Text("No favorites yet")
                                    .font(.title2)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                                
                                Text("Tap the heart icon on any sport to add it to your favorites")
                                    .font(.body)
                                    .foregroundColor(.white.opacity(0.7))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                                
                                Button("Browse Sports") {
                                    
                                    
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.white)
                                .foregroundColor(.buttonTextColor)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            ScrollView {
                                LazyVStack(spacing: 0) {
                                    ForEach(viewStore.favoriteSportsData) { sport in
                                        NavigationLink(destination: AviationSportDetailView(sport: sport, store: Store(initialState: AviationSportsFeature.State()) { AviationSportsFeature() }, appStore: self.appStore)) {
                                            FavoriteSportRowView(
                                                sport: sport,
                                                onRemove: { sportId in
                                                    print("🗑️ Removing favorite: \(sportId)")
                                                    appViewStore.send(.toggleFavorite(sportId))
                                                }
                                            )
                                        }
                                        .id(sport.id)
                                        .padding(.horizontal)
                                        .padding(.vertical, 4)
                                    }
                                }
                            }
                            .id(scrollViewId)
                        }
                    }
                    .navigationTitle("Favorites sports")
                    .navigationBarTitleDisplayMode(.large)
                    .toolbarColorScheme(.dark, for: .navigationBar)
                    .toolbar {
                        if !viewStore.favoriteSportsData.isEmpty {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("Clear All") {
                                    appViewStore.send(.clearAllFavorites)
                                }
                                .foregroundColor(.white)
                            }
                        }
                    }
                    .onAppear {
                        viewStore.send(.onAppear)
                    }
                    .onChange(of: viewStore.favoriteSports) { _ in
                        
                        viewStore.send(.loadFavorites)
                    }
                }
            }
            .id("favoritesNavigation")
        }
        }
    }
}

struct FavoriteSportRowView: View {
    let sport: AviationSport
    let onRemove: (String) -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            
            VStack {
                Image(getSportImageName(for: sport.name))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .background(sportColor(for: sport.category).opacity(0.2))
                    .cornerRadius(12)
                    .clipped()
            }
            
            
            VStack(alignment: .leading, spacing: 8) {
                Text(sport.name)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(sport.description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(2)
            }
            
            Spacer()
            
            
            Button(action: {
                onRemove(sport.id.uuidString)
            }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                    .font(.title2)
            }
        }
        .padding()
        .background(.white.opacity(0.1))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.2), radius: 4)
    }
    
    private func sportIcon(for category: SportCategory) -> String {
        switch category {
        case .all: return "airplane.circle"
        case .aerobatics: return "airplane.departure"
        case .gliding: return "airplane.arrival"
        case .parachuting: return "figure.fall"
        case .ballooning: return "balloon"
        case .airRacing: return "speedometer"
        case .formationFlying: return "airplane"
        case .precisionFlying: return "target"
        }
    }
    
    private func sportColor(for category: SportCategory) -> Color {
        switch category {
        case .all: return .blue
        case .aerobatics: return .red
        case .gliding: return .green
        case .parachuting: return .orange
        case .ballooning: return .purple
        case .airRacing: return .yellow
        case .formationFlying: return .cyan
        case .precisionFlying: return .pink
        }
    }
}

#Preview {
    FavoritesView(
        store: Store(initialState: FavoritesFeature.State()) {
            FavoritesFeature()
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
