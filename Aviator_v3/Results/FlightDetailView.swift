import SwiftUI
import ComposableArchitecture
import WebKit

struct FlightDetailView: View {
    let flightOffer: FlightOffer
    @Dependency(\.databaseClient) var databaseClient
    @Environment(\.dismiss) private var dismiss
    @State private var isSaved = false
    @State private var isLoading = false
    @State private var showNotesAlert = false
    @State private var notes = ""
    @State private var webURL: URL?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header Card
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(flightOffer.origin) → \(flightOffer.destination)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(Theme.Palette.textPrimary)
                            
                            Text(flightOffer.airline)
                                .font(.subheadline)
                                .foregroundColor(Theme.Palette.textSecondary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("\(flightOffer.price) \(flightOffer.currency)")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(Theme.Palette.primaryRed)
                            
                            Text("per person")
                                .font(.caption)
                                .foregroundColor(Theme.Palette.textTertiary)
                        }
                    }
                    
                    // Save Button
                    Button(action: {
                        if isSaved {
                            // Unsave flight
                            Task {
                                await unsaveFlight()
                            }
                        } else {
                            // Show notes alert for saving
                            showNotesAlert = true
                        }
                    }) {
                        HStack {
                            Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                                .foregroundColor(isSaved ? Theme.Palette.primaryRed : Theme.Palette.textSecondary)
                            Text(isSaved ? "Saved" : "Save Flight")
                                .font(.headline)
                                .foregroundColor(isSaved ? Theme.Palette.primaryRed : Theme.Palette.textPrimary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(isSaved ? Theme.Palette.surface : Theme.Palette.primaryRed.opacity(0.1))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(isSaved ? Theme.Palette.primaryRed : Theme.Palette.textTertiary, lineWidth: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Book Now Button
                    Button(action: {
                        openBookingWebsite()
                    }) {
                        HStack {
                            Image(systemName: "safari")
                                .foregroundColor(.white)
                            Text("Book Now")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Theme.Gradient.navigationBar)
                        .cornerRadius(8)
                        .shadow(color: Theme.Shadow.red, radius: 4)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding()
                .background(Theme.Gradient.surface)
                .cornerRadius(12)
                .shadow(color: Theme.Shadow.red, radius: 4)
                
                // Flight Details
                VStack(spacing: 16) {
                    Text("Flight Details")
                        .font(.headline)
                        .foregroundColor(Theme.Palette.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Departure
                    FlightDetailRow(
                        title: "Departure",
                        subtitle: flightOffer.departureDate,
                        icon: "airplane.departure",
                        color: Theme.Palette.primaryRed
                    )
                    
                    // Arrival
                    FlightDetailRow(
                        title: "Arrival",
                        subtitle: flightOffer.returnDate,
                        icon: "airplane.arrival",
                        color: Theme.Palette.green
                    )
                    
                    // Duration
                    FlightDetailRow(
                        title: "Duration",
                        subtitle: flightOffer.duration,
                        icon: "clock",
                        color: Theme.Palette.blue
                    )
                    
                    // Stops
                    FlightDetailRow(
                        title: "Stops",
                        subtitle: stopsText,
                        icon: "airplane",
                        color: Theme.Palette.gold
                    )
                }
                .padding()
                .background(Theme.Gradient.surface)
                .cornerRadius(12)
                .shadow(color: Theme.Shadow.red, radius: 4)
                
                // Flight Information
                VStack(spacing: 16) {
                    Text("Flight Information")
                        .font(.headline)
                        .foregroundColor(Theme.Palette.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    InfoRow(title: "Flight Number", value: flightOffer.flightNumber)
                    InfoRow(title: "Airline", value: flightOffer.airline)
                    InfoRow(title: "Route", value: "\(flightOffer.origin) → \(flightOffer.destination)")
                    InfoRow(title: "Price", value: "\(flightOffer.price) \(flightOffer.currency)")
                }
                .padding()
                .background(Theme.Gradient.surface)
                .cornerRadius(12)
                .shadow(color: Theme.Shadow.red, radius: 4)
            }
            .padding()
        }
        .background(Theme.Gradient.background)
        .navigationTitle("Flight Details")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(Theme.Gradient.navigationBar, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    HStack(spacing: 6) {
                        
                        Text(" Back ")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Theme.Palette.cardBackground)
                    .cornerRadius(12)
                    .shadow(color: Theme.Palette.primaryRed.opacity(0.4), radius: 4, x: 0, y: 2)
                    .offset(x: -45)
                    Spacer()
                    Spacer()
                }
            }
        }
        .onAppear {
            Task {
                await checkIfSaved()
            }
        }
        .alert("Add Notes", isPresented: $showNotesAlert) {
            TextField("Optional notes...", text: $notes)
            Button("Save") {
                Task {
                    await saveFlight()
                }
            }
            Button("Cancel", role: .cancel) {
                notes = ""
            }
        } message: {
            Text("Add optional notes for this flight")
        }
        .navigationDestination(item: $webURL) { url in
            BookingWebScreen(title: "Book Flight", url: url)
                .toolbarColorScheme(.dark, for: .navigationBar)
                .toolbarBackground(Theme.Palette.surface, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .scrollContentBackground(.hidden)
                .background(Theme.Gradient.background)
        }
    }
    
    private var stopsText: String {
        switch flightOffer.stops {
        case 0:
            return "Direct flight"
        case 1:
            return "1 stop"
        default:
            return "\(flightOffer.stops) stops"
        }
    }
    
    private func checkIfSaved() async {
        do {
            isSaved = try await databaseClient.isFlightSaved(flightOffer)
        } catch {
            print("❌ Error checking if flight is saved: \(error)")
        }
    }
    
    private func saveFlight() async {
        isLoading = true
        do {
            try await databaseClient.saveFlight(flightOffer, notes.isEmpty ? nil : notes)
            isSaved = true
            notes = ""
            print("✅ Flight saved successfully")
        } catch {
            print("❌ Error saving flight: \(error)")
        }
        isLoading = false
    }
    
    private func unsaveFlight() async {
        isLoading = true
        do {
            let savedFlights = try await databaseClient.getSavedFlights()
            if let savedFlight = savedFlights.first(where: { savedFlight in
                savedFlight.flightOffer.origin == flightOffer.origin &&
                savedFlight.flightOffer.destination == flightOffer.destination &&
                savedFlight.flightOffer.departureDate == flightOffer.departureDate &&
                savedFlight.flightOffer.returnDate == flightOffer.returnDate &&
                savedFlight.flightOffer.airline == flightOffer.airline &&
                savedFlight.flightOffer.flightNumber == flightOffer.flightNumber &&
                savedFlight.flightOffer.price == flightOffer.price
            }) {
                try await databaseClient.deleteSavedFlight(savedFlight)
                isSaved = false
                print("✅ Flight unsaved successfully")
            }
        } catch {
            print("❌ Error unsaving flight: \(error)")
        }
        isLoading = false
    }
    
    private func openBookingWebsite() {
        // Створюємо URL для пошуку рейсу на популярних сайтах бронювання
        let origin = flightOffer.origin
        let destination = flightOffer.destination
        let departureDate = flightOffer.departureDate.prefix(10) // Беремо тільки дату без часу
        
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
                    .foregroundColor(Theme.Palette.textSecondary)
                
                Text(subtitle)
                    .font(.headline)
                    .foregroundColor(Theme.Palette.textPrimary)
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
                .foregroundColor(Theme.Palette.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .foregroundColor(Theme.Palette.textPrimary)
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
            .background(Theme.Gradient.background)
    }
}

#Preview {
    NavigationStack {
        FlightDetailView(
            flightOffer: FlightOffer(
                price: "299",
                currency: "USD",
                origin: "NYC",
                destination: "LAX",
                departureDate: "2024-01-15T10:30:00",
                returnDate: "2024-01-15T14:45:00",
                airline: "American Airlines",
                flightNumber: "AA123",
                duration: "PT5H15M",
                stops: 0
            )
        )
    }
}
