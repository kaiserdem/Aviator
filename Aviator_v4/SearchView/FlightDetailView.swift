import SwiftUI
import ComposableArchitecture
import WebKit

struct FlightDetailView: View {
    let flight: Flight
    @Environment(\.dismiss) private var dismiss
    @State private var showNotesAlert = false
    @State private var notes = ""
    @State private var webURL: URL?
    
    var body: some View {
        ZStack {
            // Градієнтний фон
            AviationGradientBackground()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Header Section
                    VStack(spacing: 16) {
                        // Flight Image/Icon
                        Image(systemName: "airplane")
                            .font(.system(size: 80))
                            .foregroundColor(.white.opacity(0.7))
                            .frame(height: 200)
                            .frame(maxWidth: .infinity)
                            .background(.white.opacity(0.1))
                            .cornerRadius(16)
                        
                        // Title and Route
                        VStack(spacing: 8) {
                            Text("\(flight.origin) → \(flight.destination)")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                            
                            Text(flight.airline)
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(20)
                            
                            // Price Badge
                            Text("\(flight.price) \(flight.currency)")
                                .font(.headline)
                                .foregroundColor(.green)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(16)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Flight Details Section
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "Flight Details", icon: "airplane")
                        
                        VStack(spacing: 8) {
                            // Departure
                            FlightDetailRow(
                                title: "Departure",
                                subtitle: flight.formattedDepartureTime,
                                icon: "airplane.departure",
                                color: .red
                            )
                            
                            // Arrival
                            FlightDetailRow(
                                title: "Arrival",
                                subtitle: flight.formattedArrivalTime,
                                icon: "airplane.arrival",
                                color: .green
                            )
                            
                            // Duration
                            FlightDetailRow(
                                title: "Duration",
                                subtitle: flight.formattedDuration,
                                icon: "clock",
                                color: .blue
                            )
                            
                            // Stops
                            FlightDetailRow(
                                title: "Stops",
                                subtitle: stopsText,
                                icon: "airplane",
                                color: .orange
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    // Flight Information Section
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "Flight Information", icon: "info.circle")
                        
                        VStack(spacing: 8) {
                            InfoRow(title: "Flight Number", value: flight.flightNumber)
                            InfoRow(title: "Airline", value: flight.airline)
                            InfoRow(title: "Route", value: "\(flight.origin) → \(flight.destination)")
                            InfoRow(title: "Price", value: "\(flight.price) \(flight.currency)")
                        }
                    }
                    .padding(.horizontal)
                    
                    // Book Now Section
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "Booking", icon: "safari")
                        
                        Button(action: {
                            openBookingWebsite()
                        }) {
                            HStack {
                                Image(systemName: "safari")
                                    .foregroundColor(.buttonTextColor)
                                Text("Book Now")
                                    .font(.headline)
                                    .foregroundColor(.buttonTextColor)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(.white)
                            .cornerRadius(8)
                            .shadow(color: .black.opacity(0.2), radius: 4)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
        }
        .navigationTitle("Flight Details")
        .navigationBarTitleDisplayMode(.large)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(.white.opacity(0.2))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                }
            }
        }
        .navigationDestination(item: $webURL) { url in
            BookingWebScreen(title: "Book Flight", url: url)
                .toolbarColorScheme(.dark, for: .navigationBar)
                .toolbarBackground(.white.opacity(0.1), for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .scrollContentBackground(.hidden)
                .background(AviationGradientBackground())
        }
    }
    
    private var stopsText: String {
        switch flight.stops {
        case 0:
            return "Direct flight"
        case 1:
            return "1 stop"
        default:
            return "\(flight.stops) stops"
        }
    }
    
    private func openBookingWebsite() {
        // Створюємо URL для пошуку рейсу на популярних сайтах бронювання
        let origin = flight.origin
        let destination = flight.destination
        let departureDate = flight.departureTime.prefix(10) // Беремо тільки дату без часу
        
        // Використовуємо Google Flights як загальний пошук
        let searchQuery = "\(origin) to \(destination) \(departureDate)"
        let encodedQuery = searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let googleFlightsURL = "https://www.google.com/travel/flights?q=\(encodedQuery)"
        
        if let url = URL(string: googleFlightsURL) {
            webURL = url
            print("🌐 Opening booking website in-app: \(googleFlightsURL)")
        } else {
            print("❌ Error creating booking URL")
        }
    }
}

struct FlightDetailRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                
                Text(subtitle)
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .foregroundColor(.white)
        }
        .padding(.vertical, 4)
    }
}

// Simple WKWebView wrapper for SwiftUI
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

// Full screen in-app web screen for booking
private struct BookingWebScreen: View, Identifiable {
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
            .background(AviationGradientBackground())
    }
}
