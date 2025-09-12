import SwiftUI
import ComposableArchitecture
import MapKit

struct RoutesView: View {
    let store: StoreOf<RoutesFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationStack {
                ZStack {
                    // Background gradient
                    Theme.Gradient.background
                        .ignoresSafeArea()
                    
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

                        
                        // Routes List
                        if viewStore.isLoading {
                            ProgressView("Loading routes...")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            List(filteredRoutes(viewStore.routes, region: viewStore.selectedRegion)) { route in
                                RouteRowView(route: route)
                                    .onTapGesture {
                                        viewStore.send(.selectRoute(route))
                                    }
                            }
                            .listStyle(PlainListStyle())
                            .scrollContentBackground(.hidden) // Приховуємо фон List для прозорого навігаційного бару
                        }
                    }
                }
                .navigationTitle("Routes")
                .navigationBarTitleDisplayMode(.large)
                .onAppear {
                    viewStore.send(.onAppear)
                }
                .navigationDestination(item: viewStore.binding(get: \.selectedRoute, send: { .selectRoute($0) })) { route in
                    RouteDetailView(route: route)
                }
            }
        }
    }
    
    private func filteredRoutes(_ routes: [FlightRoute], region: Region) -> [FlightRoute] {
        if region == .all {
            return routes.sorted { $0.popularity > $1.popularity }
        }
        return routes.filter { $0.region == region }.sorted { $0.popularity > $1.popularity }
    }
}

// RegionButton is already defined in AirlinesView.swift

struct RouteRowView: View {
    let route: FlightRoute
    
    var body: some View {
        HStack(spacing: 12) {
            // Route Icon
            Image(systemName: "airplane.departure")
                .foregroundColor(Theme.Palette.primaryRed)
                .frame(width: 40, height: 40)
                .background(Theme.Gradient.surface)
                .cornerRadius(8)
                .shadow(color: Theme.Palette.primaryRed.opacity(0.2), radius: 2)
            
            // Route Info
            VStack(alignment: .leading, spacing: 4) {
                Text("\(route.from) → \(route.to)")
                    .font(.headline)
                    .foregroundColor(Theme.Palette.textPrimary)
                
                HStack(spacing: 8) {
                    Text("\(Int(route.distance)) km")
                    Text("•")
                    Text("\(String(format: "%.1f", route.flightTime))h")
                }
                .font(.caption)
                .foregroundColor(Theme.Palette.textSecondary)
            }
            
            Spacer()
            
            // Popularity Badge
            VStack(spacing: 2) {
                HStack {
                    Spacer()
                    
                    Text(route.region.emoji)
                        .font(.title2)
                }
                .padding(.bottom, 10)
                
                HStack(spacing: 1) {
                    Spacer() // Вирівнюємо по правому краю
                    ForEach(0..<route.popularity, id: \.self) { _ in
                        
                        Image(systemName: "star.fill")
                            .font(.system(size: 6)) // Ще менші зірочки
                            .foregroundColor(Theme.Palette.primaryRed)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct RouteDetailView: View {
    let route: FlightRoute
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "airplane.departure")
                        .font(.system(size: 60))
                        .foregroundColor(Theme.Palette.primaryRed)
                    
                    Text("\(route.from) → \(route.to)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Theme.Palette.textPrimary)
                        .multilineTextAlignment(.center)
                    
                    HStack(spacing: 8) {
                        Text(route.region.emoji)
                            .font(.title2)
                        Text(route.region.rawValue)
                            .font(.subheadline)
                            .foregroundColor(Theme.Palette.textSecondary)
                    }
                }
                .frame(maxWidth: .infinity)
                
                // Route Statistics
                VStack(alignment: .leading, spacing: 16) {
                    Text("Route Information")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Theme.Palette.textPrimary)
                    
                    StatCard(title: "Distance", value: "\(Int(route.distance)) km", icon: "ruler")
                    StatCard(title: "Flight Time", value: "\(String(format: "%.1f", route.flightTime)) hours", icon: "clock")
                    StatCard(title: "Popularity", value: "\(route.popularity)/10", icon: "star.fill")
                    
                    // Popularity Stars
                    HStack(spacing: 4) {
                        Text("Popularity:")
                            .font(.caption)
                            .foregroundColor(Theme.Palette.textSecondary)
                        
                        ForEach(0..<10, id: \.self) { index in
                            Image(systemName: index < route.popularity ? "star.fill" : "star")
                                .font(.caption)
                                .foregroundColor(Theme.Palette.primaryRed)
                        }
                    }
                    .padding()
                    .background(Theme.Gradient.surface)
                    .cornerRadius(12)
                    .shadow(color: Theme.Palette.primaryRed.opacity(0.2), radius: 2)
                }
                
                // Map View
                VStack(alignment: .leading, spacing: 12) {
                    Text("Route Map")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Theme.Palette.textPrimary)
                    
                    RouteMapView(route: route)
                        .frame(height: 300)
                        .cornerRadius(12)
                        .shadow(color: Theme.Palette.primaryRed.opacity(0.2), radius: 2)
                }
            }
            .padding()
        }
        .navigationTitle("Route Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// StatCard is already defined in AirlinesView.swift

struct RouteMapView: View {
    let route: FlightRoute
    
    var body: some View {
        Map(coordinateRegion: .constant(MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: (route.fromCoordinates.latitude + route.toCoordinates.latitude) / 2,
                longitude: (route.fromCoordinates.longitude + route.toCoordinates.longitude) / 2
            ),
            span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
        )), annotationItems: [
            MapAnnotationItem(
                coordinate: CLLocationCoordinate2D(
                    latitude: route.fromCoordinates.latitude,
                    longitude: route.fromCoordinates.longitude
                ),
                view: AnyView(
                    VStack {
                        Image(systemName: "airplane.arrival")
                            .foregroundColor(.green)
                            .font(.title2)
                        Text(route.from)
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(4)
                            .background(Color.green)
                            .cornerRadius(4)
                    }
                )
            ),
            MapAnnotationItem(
                coordinate: CLLocationCoordinate2D(
                    latitude: route.toCoordinates.latitude,
                    longitude: route.toCoordinates.longitude
                ),
                view: AnyView(
                    VStack {
                        Image(systemName: "airplane.departure")
                            .foregroundColor(.red)
                            .font(.title2)
                        Text(route.to)
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(4)
                            .background(Color.red)
                            .cornerRadius(4)
                    }
                )
            )
        ]) { annotation in
            MapAnnotation(coordinate: annotation.coordinate) {
                annotation.view
            }
        }
    }
}

// MapAnnotationItem is already defined in MapView.swift

#Preview {
    RoutesView(
        store: Store(initialState: RoutesFeature.State()) {
            RoutesFeature()
        }
    )
}
