import SwiftUI
import ComposableArchitecture
import MapKit

struct HotelDetailView: View {
    let hotel: Hotel
    @State private var region: MKCoordinateRegion
    
    init(hotel: Hotel) {
        self.hotel = hotel
        if let lat = hotel.latitude, let lon = hotel.longitude {
            self._region = State(initialValue: MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ))
        } else {
            // Default to New York if no coordinates
            self._region = State(initialValue: MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 40.7589, longitude: -73.9851),
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ))
        }
    }
    
    var body: some View {
        ZStack {
            // Градієнтний фон
            AviationGradientBackground()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Header Section
                    VStack(spacing: 16) {
                        // Hotel Image
                        if let imageURL = hotel.imageURL, let url = URL(string: imageURL) {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Image(systemName: "bed.double")
                                    .font(.system(size: 80))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            .frame(height: 200)
                            .clipped()
                            .cornerRadius(12)
                        } else {
                            Image(systemName: "bed.double")
                                .font(.system(size: 80))
                                .foregroundColor(.white.opacity(0.7))
                                .frame(height: 200)
                                .frame(maxWidth: .infinity)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(12)
                        }
                        
                        // Hotel Name and Rating
                        VStack(spacing: 8) {
                            Text(hotel.name)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                            
                            HStack(spacing: 4) {
                                ForEach(0..<Int(hotel.rating), id: \.self) { _ in
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.yellow)
                                }
                                if hotel.rating.truncatingRemainder(dividingBy: 1) > 0 {
                                    Image(systemName: "star.leadinghalf.filled")
                                        .foregroundColor(.yellow)
                                }
                                Text(String(format: "%.1f", hotel.rating))
                                    .foregroundColor(.white)
                                    .fontWeight(.medium)
                            }
                        }
                    }
                    
                    // Price Section
                    VStack(spacing: 12) {
                        Text("Price")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack {
                            Text("\(hotel.currency) \(Int(hotel.price))")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                            
                            Text("per night")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                            
                            Spacer()
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Address Section
                    VStack(spacing: 12) {
                        Text("Location")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack {
                            Image(systemName: "location")
                                .foregroundColor(.blue)
                            Text(hotel.address)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)
                            Spacer()
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Map Section
                    if hotel.latitude != nil && hotel.longitude != nil {
                        VStack(spacing: 12) {
                            Text("Map")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Map(coordinateRegion: $region, annotationItems: [hotel]) { hotel in
                                MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: hotel.latitude!, longitude: hotel.longitude!)) {
                                    VStack {
                                        Image(systemName: "bed.double.fill")
                                            .foregroundColor(.red)
                                            .font(.title2)
                                            .background(Color.white)
                                            .clipShape(Circle())
                                            .shadow(radius: 3)
                                        
                                        Text(hotel.name)
                                            .font(.caption)
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.black.opacity(0.7))
                                            .cornerRadius(8)
                                    }
                                }
                            }
                            .frame(height: 200)
                            .cornerRadius(12)
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    // Amenities Section
                    if !hotel.amenities.isEmpty {
                        VStack(spacing: 12) {
                            Text("Amenities")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 12) {
                                ForEach(hotel.amenities, id: \.self) { amenity in
                                    HStack {
                                        Image(systemName: amenityIcon(for: amenity))
                                            .foregroundColor(.blue)
                                        Text(amenity)
                                            .foregroundColor(.white)
                                            .font(.subheadline)
                                        Spacer()
                                    }
                                    .padding()
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(8)
                                }
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    // Contact Section
                    VStack(spacing: 12) {
                        Text("Contact")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        VStack(spacing: 8) {
                            HStack {
                                Image(systemName: "phone")
                                    .foregroundColor(.green)
                                Text("+1 (555) 123-4567")
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            
                            HStack {
                                Image(systemName: "envelope")
                                    .foregroundColor(.blue)
                                Text("info@\(hotel.name.lowercased().replacingOccurrences(of: " ", with: ""))hotel.com")
                                    .foregroundColor(.white)
                                Spacer()
                            }
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                }
                .padding()
            }
        }
        .navigationTitle("Hotel Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
    
    private func amenityIcon(for amenity: String) -> String {
        switch amenity.lowercased() {
        case "wifi":
            return "wifi"
        case "parking":
            return "car"
        case "restaurant":
            return "fork.knife"
        case "gym":
            return "dumbbell"
        case "pool":
            return "figure.pool.swim"
        case "spa":
            return "leaf"
        case "bar":
            return "wineglass"
        case "room service":
            return "bell"
        case "concierge":
            return "person.badge.plus"
        case "business center":
            return "briefcase"
        default:
            return "checkmark.circle"
        }
    }
}

#Preview {
    NavigationStack {
        HotelDetailView(
            hotel: Hotel(
                name: "Grand Hotel Paris",
                address: "123 Champs-Élysées, Paris, France",
                rating: 4.5,
                price: 299.99,
                currency: "USD",
                amenities: ["WiFi", "Parking", "Restaurant", "Gym", "Pool", "Spa"],
                imageURL: nil,
                latitude: 48.8566,
                longitude: 2.3522
            )
        )
    }
}
