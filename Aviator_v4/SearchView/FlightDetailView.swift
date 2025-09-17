import SwiftUI
import ComposableArchitecture

struct FlightDetailView: View {
    let flight: Flight
    @Environment(\.dismiss) private var dismiss
    
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
                    
                    // Hotel Booking Section
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "Hotel Booking", icon: "bed.double")
                        
                        VStack(spacing: 12) {
                            // Destination Info
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Destination: \(flight.destination)")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Text("Arrival: \(flight.formattedArrivalTime)")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(.white.opacity(0.1))
                            .cornerRadius(12)
                            
                            // Book Hotel Button
                            Button(action: {
                                // Navigate to Hotels tab
                                // This would need to be implemented with proper navigation
                                print("🏨 Navigate to Hotels tab for \(flight.destination)")
                            }) {
                                HStack {
                                    Image(systemName: "bed.double.fill")
                                        .foregroundColor(.buttonTextColor)
                                    Text("Find Hotels in \(flight.destination)")
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
