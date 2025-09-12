import SwiftUI
import ComposableArchitecture

struct ProfileView: View {
    let store: StoreOf<ProfileFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationStack {
                VStack {
                    if viewStore.isLoading {
                        ProgressView("Loading profile...")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if viewStore.isLoggedIn, let user = viewStore.user {
                        // User Profile
                        ScrollView {
                            VStack(spacing: 20) {
                                // Profile Header
                                VStack(spacing: 12) {
                                    Image(systemName: "person.circle.fill")
                                        .font(.system(size: 80))
                                        .foregroundColor(.blue)
                                    
                                    Text("\(user.firstName) \(user.lastName)")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
                                    
                                    Text(user.email)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                                
                                // User Details
                                VStack(alignment: .leading, spacing: 16) {
                                    Text("Personal Information")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    ProfileDetailRow(title: "First Name", value: user.firstName)
                                    ProfileDetailRow(title: "Last Name", value: user.lastName)
                                    ProfileDetailRow(title: "Email", value: user.email)
                                    
                                    if let phone = user.phoneNumber {
                                        ProfileDetailRow(title: "Phone", value: phone)
                                    }
                                }
                                .padding()
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(12)
                                
                                // Preferences
                                VStack(alignment: .leading, spacing: 16) {
                                    Text("Preferences")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    if let airline = user.preferences.preferredAirline {
                                        ProfileDetailRow(title: "Preferred Airline", value: airline)
                                    }
                                    
                                    if let seat = user.preferences.preferredSeat {
                                        ProfileDetailRow(title: "Preferred Seat", value: seat)
                                    }
                                    
                                    if let meal = user.preferences.preferredMeal {
                                        ProfileDetailRow(title: "Preferred Meal", value: meal)
                                    }
                                    
                                    ProfileDetailRow(title: "Notifications", value: user.preferences.notificationsEnabled ? "Enabled" : "Disabled")
                                }
                                .padding()
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(12)
                                
                                // Logout Button
                                Button(action: {
                                    viewStore.send(.logout)
                                }) {
                                    Text("Logout")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.red)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                                .padding()
                            }
                            .padding()
                        }
                    } else {
                        // Login Form
                        VStack(spacing: 20) {
                            Text("Welcome to Aviator")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text("Please log in to access your profile and preferences")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            
                            Button(action: {
                                viewStore.send(.login("user@example.com", "password"))
                            }) {
                                Text("Login")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .padding()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .navigationTitle("Profile")
                .onAppear {
                    viewStore.send(.onAppear)
                }
            }
        }
    }
}

struct ProfileDetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    ProfileView(
        store: Store(initialState: ProfileFeature.State()) {
            ProfileFeature()
        }
    )
}
