import SwiftUI
import ComposableArchitecture

struct AviationSportsView: View {
    let store: StoreOf<AviationSportsFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationStack {
                VStack(spacing: 16) {
                    // Filter Section
                    VStack(spacing: 12) {
                        HStack {
                            Text("Category:")
                            Picker("Category", selection: viewStore.binding(get: \.selectedCategory, send: { .categoryChanged($0) })) {
                                ForEach(SportCategory.allCases, id: \.self) { category in
                                    Text(category.rawValue).tag(category)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            
                            Spacer()
                            
                            Text("Location:")
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
                    }
                    .padding()
                    
                    // Content
                    if viewStore.isLoading {
                        ProgressView("Loading aviation sports...")
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
                                .foregroundColor(.gray)
                            Text("Try adjusting your filters")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        List(viewStore.sports) { sport in
                            AviationSportRowView(sport: sport)
                        }
                    }
                }
                .navigationTitle("Aviation Sports")
                .onAppear {
                    viewStore.send(.onAppear)
                }
            }
        }
    }
}

struct AviationSportRowView: View {
    let sport: AviationSport
    
    var body: some View {
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
                        .foregroundColor(Color(sport.difficulty.color))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color(sport.difficulty.color).opacity(0.1))
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
                    
                    ScrollView(.horizontal, showsIndicators: false) {
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
        .padding(.vertical, 8)
    }
}

#Preview {
    AviationSportsView(
        store: Store(initialState: AviationSportsFeature.State()) {
            AviationSportsFeature()
        }
    )
}
