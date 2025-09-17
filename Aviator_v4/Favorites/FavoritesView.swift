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
                    // Градієнтний фон
                    AviationGradientBackground()
                    
                    VStack(spacing: 16) {
                        // Header
                        VStack(spacing: 8) {
                            Image(systemName: "heart.fill")
                                .font(.largeTitle)
                                .foregroundColor(.red)
                            
                            Text("My Favorite Sports")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Sports you've marked as favorites")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(.top)
                        
                        // Content
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
                                    // Переходимо на вкладку Aviation Sports
                                    // Це можна реалізувати через AppFeature
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
                                .foregroundColor(.red)
                            }
                        }
                    }
                    .onAppear {
                        viewStore.send(.onAppear)
                    }
                    .onChange(of: viewStore.favoriteSports) { _ in
                        // Автоматично оновлюємо список при зміні улюблених спорту
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
            // Sport Icon
            VStack {
                Image(systemName: sportIcon(for: sport.category))
                    .font(.system(size: 30))
                    .foregroundColor(sportColor(for: sport.category))
                    .frame(width: 60, height: 60)
                    .background(sportColor(for: sport.category).opacity(0.1))
                    .cornerRadius(12)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                Text(sport.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(sport.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            // Remove Button
            Button(action: {
                onRemove(sport.id.uuidString)
            }) {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
                    .font(.title2)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
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
