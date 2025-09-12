import SwiftUI
import ComposableArchitecture

struct StatsView: View {
    let store: StoreOf<StatsFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationStack {
                ZStack {
                    // Background gradient
                    Theme.Gradient.background
                        .ignoresSafeArea()
                    
                    VStack(spacing: 0) {
                        // Category Filter
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(StatCategory.allCases, id: \.self) { category in
                                    CategoryButton(
                                        category: category,
                                        isSelected: viewStore.selectedCategory == category
                                    ) {
                                        viewStore.send(.selectCategory(category))
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical, 8)
                        .background(Theme.Gradient.tabBar)
                        
                        // Stats Content
                        if viewStore.isLoading {
                            ProgressView("Calculating stats...")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            ScrollView {
                                LazyVStack(spacing: 16) {
                                    switch viewStore.selectedCategory {
                                    case .live:
                                        LiveStatsView(stats: viewStore.stats)
                                    case .regional:
                                        RegionalStatsView(stats: viewStore.stats)
                                    case .aircraft:
                                        AircraftTypeStatsView(stats: viewStore.stats)
                                    }
                                }
                                .padding()
                            }
                            .scrollContentBackground(.hidden)
                        }
                    }
                }
                .navigationTitle("Flight Stats")
                .navigationBarTitleDisplayMode(.large)
                .onAppear {
                    viewStore.send(.onAppear)
                }
            }
        }
    }
}

struct CategoryButton: View {
    let category: StatCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: category.icon)
                    .font(.caption)
                Text(category.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Theme.Gradient.button : Theme.Gradient.surface)
            .foregroundColor(isSelected ? .white : Theme.Palette.textPrimary)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Theme.Palette.black : Color.clear, lineWidth: 2)
            )
            .shadow(color: isSelected ? Theme.Palette.primaryRed.opacity(0.3) : .clear, radius: 4)
        }
    }
}

struct LiveStatsView: View {
    let stats: FlightStats
    
    var body: some View {
        VStack(spacing: 16) {
            // Total Aircraft
            StatCard(
                title: "Total Aircraft",
                value: "\(stats.totalAircraft)",
                icon: "airplane",
                color: Theme.Palette.primaryRed
            )
            
            // Fastest Aircraft
            StatCard(
                title: "Fastest Aircraft",
                value: "\(String(format: "%.0f", stats.fastestAircraft.value)) \(stats.fastestAircraft.unit)",
                icon: "speedometer",
                color: Theme.Palette.primaryRed,
                subtitle: "\(stats.fastestAircraft.callsign) (\(stats.fastestAircraft.country))"
            )
            
            // Highest Aircraft
            StatCard(
                title: "Highest Aircraft",
                value: "\(String(format: "%.0f", stats.highestAircraft.value)) \(stats.highestAircraft.unit)",
                icon: "arrow.up.circle",
                color: Theme.Palette.primaryRed,
                subtitle: "\(stats.highestAircraft.callsign) (\(stats.highestAircraft.country))"
            )
            
            // Lowest Aircraft
            StatCard(
                title: "Lowest Aircraft",
                value: "\(String(format: "%.0f", stats.lowestAircraft.value)) \(stats.lowestAircraft.unit)",
                icon: "arrow.down.circle",
                color: Theme.Palette.primaryRed,
                subtitle: "\(stats.lowestAircraft.callsign) (\(stats.lowestAircraft.country))"
            )
            
            // Last Updated
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(Theme.Palette.textSecondary)
                Text("Last updated: \(stats.lastUpdated, style: .relative)")
                    .font(.caption)
                    .foregroundColor(Theme.Palette.textSecondary)
            }
            .padding()
            .background(Theme.Gradient.surface)
            .cornerRadius(12)
        }
    }
}

struct RegionalStatsView: View {
    let stats: FlightStats
    
    var body: some View {
        VStack(spacing: 16) {
            ForEach(stats.regionalStats, id: \.region) { regionStat in
                RegionalStatCard(regionStat: regionStat)
            }
        }
    }
}

struct RegionalStatCard: View {
    let regionStat: RegionStat
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(regionStat.region.emoji)
                    .font(.title2)
                Text(regionStat.region.rawValue)
                    .font(.headline)
                    .foregroundColor(Theme.Palette.textPrimary)
                Spacer()
                Text("\(regionStat.aircraftCount) aircraft")
                    .font(.subheadline)
                    .foregroundColor(Theme.Palette.textSecondary)
            }
            
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Avg Speed")
                        .font(.caption)
                        .foregroundColor(Theme.Palette.textSecondary)
                    Text("\(String(format: "%.0f", regionStat.averageSpeed)) km/h")
                        .font(.subheadline)
                        .foregroundColor(Theme.Palette.textPrimary)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Avg Altitude")
                        .font(.caption)
                        .foregroundColor(Theme.Palette.textSecondary)
                    Text("\(String(format: "%.0f", regionStat.averageAltitude)) m")
                        .font(.subheadline)
                        .foregroundColor(Theme.Palette.textPrimary)
                }
                
                Spacer()
            }
        }
        .padding()
        .background(Theme.Gradient.surface)
        .cornerRadius(12)
        .shadow(color: Theme.Palette.primaryRed.opacity(0.2), radius: 2)
    }
}

struct AircraftTypeStatsView: View {
    let stats: FlightStats
    
    var body: some View {
        VStack(spacing: 16) {
            ForEach(stats.aircraftTypeStats, id: \.type) { typeStat in
                AircraftTypeStatCard(typeStat: typeStat)
            }
        }
    }
}

struct AircraftTypeStatCard: View {
    let typeStat: AircraftTypeStat
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "airplane")
                    .foregroundColor(Theme.Palette.primaryRed)
                    .font(.title2)
                Text(typeStat.type)
                    .font(.headline)
                    .foregroundColor(Theme.Palette.textPrimary)
                Spacer()
                Text("\(typeStat.count) aircraft")
                    .font(.subheadline)
                    .foregroundColor(Theme.Palette.textSecondary)
            }
            
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Avg Speed")
                        .font(.caption)
                        .foregroundColor(Theme.Palette.textSecondary)
                    Text("\(String(format: "%.0f", typeStat.averageSpeed)) km/h")
                        .font(.subheadline)
                        .foregroundColor(Theme.Palette.textPrimary)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Avg Altitude")
                        .font(.caption)
                        .foregroundColor(Theme.Palette.textSecondary)
                    Text("\(String(format: "%.0f", typeStat.averageAltitude)) m")
                        .font(.subheadline)
                        .foregroundColor(Theme.Palette.textPrimary)
                }
                
                Spacer()
            }
        }
        .padding()
        .background(Theme.Gradient.surface)
        .cornerRadius(12)
        .shadow(color: Theme.Palette.primaryRed.opacity(0.2), radius: 2)
    }
}

// StatCard is already defined in AirlinesView.swift

#Preview {
    StatsView(
        store: Store(initialState: StatsFeature.State()) {
            StatsFeature()
        }
    )
}
