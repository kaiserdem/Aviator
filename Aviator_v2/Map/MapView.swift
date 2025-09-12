import SwiftUI
import ComposableArchitecture
import MapKit

struct MapAnnotationItem: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let view: AnyView
}

struct MapView: View {
    let store: StoreOf<MapFeature>
    
    private func allAnnotations(_ viewStore: ViewStoreOf<MapFeature>) -> [MapAnnotationItem] {
        var annotations: [MapAnnotationItem] = []
        
        // Add aircraft annotations
        for aircraft in viewStore.aircraft {
            if let latitude = aircraft.latitude, let longitude = aircraft.longitude {
                annotations.append(MapAnnotationItem(
                    coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                    view: AnyView(
                        AircraftAnnotationView(aircraft: aircraft)
                            .onTapGesture {
                                viewStore.send(.selectAircraft(aircraft))
                            }
                    )
                ))
            }
        }
        
        // Add user location annotation
        if let userLocation = viewStore.userLocation {
            annotations.append(MapAnnotationItem(
                coordinate: userLocation.clLocationCoordinate,
                view: AnyView(UserLocationAnnotationView())
            ))
        }
        
        return annotations
    }
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationStack {
                ZStack {
                    // Background gradient
                    Theme.Gradient.background
                        .ignoresSafeArea()
                    // Map
                    Map(coordinateRegion: viewStore.binding(get: \.region, send: { _ in .zoomIn }), annotationItems: allAnnotations(viewStore)) { annotation in
                        MapAnnotation(coordinate: annotation.coordinate) {
                            annotation.view
                        }
                    }
                    
                    // Map Controls
                    VStack {
                        HStack {
                            Spacer()
                            VStack(spacing: 8) {
                                // Location Button
                                Button(action: {
                                    viewStore.send(.centerOnUserLocation)
                                }) {
                                    Image(systemName: "location.fill")
                                        .foregroundColor(.white)
                                        .font(.title2)
                                        .frame(width: 44, height: 44)
                                        .background(Theme.Gradient.button)
                                        .cornerRadius(22)
                                        .shadow(color: Theme.Palette.primaryRed.opacity(0.3), radius: 4)
                                }
                                
                                // Zoom In Button
                                Button(action: {
                                    viewStore.send(.zoomIn)
                                }) {
                                    Image(systemName: "plus")
                                        .foregroundColor(.white)
                                        .font(.title2)
                                        .frame(width: 44, height: 44)
                                        .background(Theme.Gradient.button)
                                        .cornerRadius(22)
                                        .shadow(color: Theme.Palette.primaryRed.opacity(0.3), radius: 4)
                                }
                                
                                // Zoom Out Button
                                Button(action: {
                                    viewStore.send(.zoomOut)
                                }) {
                                    Image(systemName: "minus")
                                        .foregroundColor(.white)
                                        .font(.title2)
                                        .frame(width: 44, height: 44)
                                        .background(Theme.Gradient.button)
                                        .cornerRadius(22)
                                        .shadow(color: Theme.Palette.primaryRed.opacity(0.3), radius: 4)
                                }
                            }
                            .padding(.trailing, 16)
                        }
                        .padding(.top, 16)
                        
                        Spacer()
                        
                        // Aircraft List
                        AircraftListView(aircraft: viewStore.aircraft)
                            .background(Theme.Gradient.surface)
                            .cornerRadius(16)
                            .padding()
                    }
                }
                .navigationTitle("Live Aircraft Map")
                .onAppear {
                    viewStore.send(.onAppear)
                }
                .sheet(item: viewStore.binding(get: \.selectedAircraft, send: { .selectAircraft($0) })) { aircraft in
                    AircraftDetailView(aircraft: aircraft)
                }
            }
        }
    }
}

struct AircraftAnnotationView: View {
    let aircraft: AircraftPosition
    
    var body: some View {
        VStack {
            Image(systemName: "airplane")
                .foregroundColor(Theme.Palette.primaryRed)
                .font(.title2)
            Text(aircraft.callsign ?? "Unknown")
                .font(.caption)
                .foregroundColor(Theme.Palette.textPrimary)
        }
        .padding(8)
        .background(Theme.Gradient.surface)
        .cornerRadius(8)
        .shadow(color: Theme.Palette.primaryRed.opacity(0.3), radius: 4)
    }
}

struct UserLocationAnnotationView: View {
    var body: some View {
        VStack {
            Image(systemName: "location.circle.fill")
                .foregroundColor(Theme.Palette.accent)
                .font(.title)
                .background(Color.white)
                .clipShape(Circle())
        }
        .shadow(color: Theme.Palette.accent.opacity(0.5), radius: 4)
    }
}

struct AircraftListView: View {
    let aircraft: [AircraftPosition]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Active Aircraft")
                .font(.headline)
                .foregroundColor(Theme.Palette.textPrimary)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(aircraft.prefix(10)) { aircraft in
                        AircraftCardView(aircraft: aircraft)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
    }
}

struct AircraftCardView: View {
    let aircraft: AircraftPosition
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(aircraft.callsign ?? "Unknown")
                .font(.headline)
                .foregroundColor(Theme.Palette.textPrimary)
            
            Text(aircraft.originCountry ?? "Unknown")
                .font(.caption)
                .foregroundColor(Theme.Palette.textSecondary)
            
            if let velocity = aircraft.velocity {
                Text("\(Int(velocity)) km/h")
                    .font(.caption)
                    .foregroundColor(Theme.Palette.accent)
            }
        }
        .padding(12)
        .frame(width: 120)
        .background(Theme.Gradient.surface)
        .cornerRadius(12)
        .shadow(color: Theme.Palette.primaryRed.opacity(0.2), radius: 2)
    }
}

struct AircraftDetailView: View {
    let aircraft: AircraftPosition
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                // Aircraft Image
                if let imageURL = aircraft.aircraftImageURL {
                    AsyncImage(url: imageURL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        Image(systemName: "airplane")
                            .font(.system(size: 60))
                            .foregroundColor(Theme.Palette.primaryRed)
                    }
                    .frame(height: 200)
                    .cornerRadius(12)
                }
                
                // Aircraft Info
                VStack(alignment: .leading, spacing: 12) {
                    Text("Flight Information")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Theme.Palette.textPrimary)
                    
                    InfoRow(title: "Callsign", value: aircraft.callsign ?? "Unknown")
                    InfoRow(title: "Country", value: aircraft.originCountry ?? "Unknown")
                    InfoRow(title: "Aircraft Type", value: aircraft.aircraftType ?? "Unknown")
                    
                    if let altitude = aircraft.altitude {
                        InfoRow(title: "Altitude", value: "\(Int(altitude)) ft")
                    }
                    
                    if let velocity = aircraft.velocity {
                        InfoRow(title: "Speed", value: "\(Int(velocity)) km/h")
                    }
                    
                    if let heading = aircraft.heading {
                        InfoRow(title: "Heading", value: "\(Int(heading))°")
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Aircraft Details")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(Theme.Palette.textSecondary)
            Spacer()
            Text(value)
                .foregroundColor(Theme.Palette.textPrimary)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    MapView(
        store: Store(initialState: MapFeature.State()) {
            MapFeature()
        }
    )
}
