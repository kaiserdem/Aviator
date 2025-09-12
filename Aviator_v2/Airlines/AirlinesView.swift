import SwiftUI
import ComposableArchitecture
import WebKit

struct AirlinesView: View {
    let store: StoreOf<AirlinesFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationStack {
                ZStack {
                    // Background gradient
//                    Theme.Gradient.navigationBar
//                        .ignoresSafeArea()
                    
                    VStack(spacing: 0) {
                    // Region Filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(Region.allCases, id: \.self) { region in
                                RegionButton(
                                    region: region,
                                    isSelected: viewStore.selectedRegion == region
                                ) {
                                    viewStore.send(.selectRegion(region))
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 8)
                  
                    .background(Theme.Gradient.tabBar)
                    // Airlines List
                    if viewStore.isLoading {
                        ProgressView("Loading airlines...")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        List(filteredAirlines(viewStore.airlines, region: viewStore.selectedRegion)) { airline in
                            AirlineRowView(airline: airline)
                                .onTapGesture {
                                    viewStore.send(.selectAirline(airline))
                                }
                        }
                        .listStyle(PlainListStyle())
                        .scrollContentBackground(.hidden) // Приховуємо фон List для прозорого навігаційного бару
                        
                    }
                    }
                }
                .navigationTitle("Airlines")
                .navigationBarTitleDisplayMode(.large)
                .onAppear {
                    viewStore.send(.onAppear)
                }
                .navigationDestination(item: viewStore.binding(get: \.selectedAirline, send: { .selectAirline($0) })) { airline in
                    AirlineDetailView(airline: airline)
                }
            }
        }
    }
    
    private func filteredAirlines(_ airlines: [Airline], region: Region) -> [Airline] {
        if region == .all {
            return airlines
        }
        return airlines.filter { $0.region == region }
    }
}

struct RegionButton: View {
    let region: Region
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(region.emoji)
                Text(region.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
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

struct AirlineRowView: View {
    let airline: Airline
    
    var body: some View {
        HStack(spacing: 12) {
            // Logo
            AsyncImage(url: airline.logoURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                Image(systemName: "airplane")
                    .foregroundColor(Theme.Palette.primaryRed)
            }
            .frame(width: 40, height: 40)
            .background(Theme.Gradient.surface)
            .cornerRadius(8)
            .shadow(color: Theme.Palette.primaryRed.opacity(0.2), radius: 2)
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(airline.name)
                    .font(.headline)
                    .foregroundColor(Theme.Palette.textPrimary)
                
                Text("\(airline.region.rawValue) • \(airline.activeFlights) flights")
                    .font(.caption)
                    .foregroundColor(Theme.Palette.textSecondary)
            }
            
            Spacer()
            
            // Region Badge
            Text(airline.region.emoji)
                .font(.title2)
        }
        .padding(.vertical, 4)
    }
}

struct AirlineDetailView: View {
    let airline: Airline
    @State private var webURL: URL?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(spacing: 12) {
                    // Logo
                    AsyncImage(url: airline.logoURL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        Image(systemName: "airplane")
                            .font(.system(size: 60))
                            .foregroundColor(Theme.Palette.primaryRed)
                    }
                    .frame(height: 80)
                    
                    Text(airline.name)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Theme.Palette.textPrimary)
                        .multilineTextAlignment(.center)
                    
                    HStack(spacing: 8) {
                        Text(airline.countryFlag)
                            .font(.title2)
                        Text(airline.country)
                            .font(.subheadline)
                            .foregroundColor(Theme.Palette.textSecondary)
                    }
                }
                .frame(maxWidth: .infinity)
                
                // Stats
                VStack(alignment: .leading, spacing: 16) {
                    Text("Statistics")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Theme.Palette.textPrimary)
                    
                    StatCard(title: "Active Flights", value: "\(airline.activeFlights)", icon: "airplane")
                    StatCard(title: "Region", value: airline.region.rawValue, icon: "globe")
                    StatCard(title: "Callsign", value: airline.callsign, icon: "radio")
                    
                    if let foundedYear = airline.foundedYear {
                        StatCard(title: "Founded", value: "\(foundedYear)", icon: "calendar")
                    }
                    
                    if let fleetSize = airline.fleetSize {
                        StatCard(title: "Fleet Size", value: "\(fleetSize)", icon: "airplane.circle")
                    }
                    
                    if let headquarters = airline.headquarters {
                        StatCard(title: "Headquarters", value: headquarters, icon: "building.2")
                    }
                }
                
                // Links
                if let website = airline.website {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Links")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Theme.Palette.textPrimary)
                        
                        Button {
                            webURL = website
                        } label: {
                            HStack {
                                Image(systemName: "safari")
                                Text("Official Website")
                                Spacer()
                                Image(systemName: "arrow.up.right")
                            }
                            .padding()
                            .background(Theme.Gradient.surface)
                            .cornerRadius(12)
                            .shadow(color: Theme.Palette.primaryRed.opacity(0.2), radius: 2)
                        }
                        .foregroundColor(Theme.Palette.primaryRed)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Airline Details")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $webURL) { url in
            AirlineWebScreen(title: airline.name, url: url)
                .scrollContentBackground(.hidden)
                .background(Theme.Gradient.background)
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let subtitle: String?
    
    init(title: String, value: String, icon: String, color: Color = Theme.Palette.primaryRed, subtitle: String? = nil) {
        self.title = title
        self.value = value
        self.icon = icon
        self.color = color
        self.subtitle = subtitle
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(Theme.Palette.textSecondary)
                
                Text(value)
                    .font(.headline)
                    .foregroundColor(Theme.Palette.textPrimary)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundColor(Theme.Palette.textSecondary)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Theme.Gradient.surface)
        .cornerRadius(12)
        .shadow(color: color.opacity(0.2), radius: 2)
    }
}

// Simple WKWebView wrapper for SwiftUI (без індикатора)
private struct WebView: UIViewRepresentable {
    let url: URL
    func makeUIView(context: Context) -> WKWebView {
        let view = WKWebView()
        view.isOpaque = false
        view.backgroundColor = .black
        view.scrollView.backgroundColor = .black
        view.load(URLRequest(url: url))
        return view
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {
        if uiView.url != url {
            uiView.load(URLRequest(url: url))
        }
    }
}

// Full screen in-app web screen with title
private struct AirlineWebScreen: View, Identifiable {
    let id = UUID()
    let title: String
    let url: URL
    var body: some View {
        WebContentView(title: title, url: url)
    }
}

private struct WebContentView: View {
    let title: String
    let url: URL
    var body: some View {
        WebView(url: url)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .background(Theme.Gradient.background)
    }
}

#Preview {
    AirlinesView(
        store: Store(initialState: AirlinesFeature.State()) {
            AirlinesFeature()
        }
    )
}
