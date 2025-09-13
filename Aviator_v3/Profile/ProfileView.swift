import SwiftUI
import ComposableArchitecture

extension Notification.Name {
    static let userDidLogin = Notification.Name("userDidLogin")
}

struct ProfileView: View {
    let store: StoreOf<ProfileFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            Group {
                if viewStore.user != nil {
                    // User is logged in - show profile
                    NavigationView {
                ScrollView {
                    VStack(spacing: 24) {
                        // Profile Header
                        VStack(spacing: 16) {
                            // Avatar
                            Circle()
                                .fill(Theme.Gradient.button)
                                .frame(width: 100, height: 100)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(.white)
                                )
                            
                            // User Info
                            VStack(spacing: 4) {
                                Text("\(viewStore.user?.firstName ?? "") \(viewStore.user?.lastName ?? "")")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                
                                Text(viewStore.user?.email ?? "")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.top, 20)
                        
                        // Profile Sections
                        VStack(spacing: 16) {
                            // Personal Information
                            ProfileSectionView(
                                title: "Personal Information",
                                icon: "person.circle",
                                content: {
                                    VStack(spacing: 12) {
                                        ProfileRowView(
                                            icon: "envelope",
                                            title: "Email",
                                            value: viewStore.user?.email ?? ""
                                        )
                                        
                                        ProfileRowView(
                                            icon: "phone",
                                            title: "Phone",
                                            value: viewStore.user?.phoneNumber ?? "Not provided"
                                        )
                                    }
                                }
                            )
                            
                            // Travel Preferences
                            ProfileSectionView(
                                title: "Travel Preferences",
                                icon: "airplane",
                                content: {
                                    VStack(spacing: 12) {
                                        ProfileRowView(
                                            icon: "airplane.circle",
                                            title: "Preferred Airline",
                                            value: viewStore.user?.preferences?.preferredAirline ?? "Not set"
                                        )
                                        
                                        ProfileRowView(
                                            icon: "seat.2",
                                            title: "Preferred Seat",
                                            value: viewStore.user?.preferences?.preferredSeat ?? "Not set"
                                        )
                                        
                                        ProfileRowView(
                                            icon: "fork.knife",
                                            title: "Preferred Meal",
                                            value: viewStore.user?.preferences?.preferredMeal ?? "Not set"
                                        )
                                    }
                                }
                            )
                            
                            // Settings
                            ProfileSectionView(
                                title: "Settings",
                                icon: "gear",
                                content: {
                                    VStack(spacing: 12) {
                                        HStack {
                                            Image(systemName: "bell")
                                                .foregroundColor(Theme.Palette.primaryRed)
                                                .frame(width: 24)
                                            
                                            Text("Notifications")
                                                .foregroundColor(.white)
                                            
                                            Spacer()
                                            
                                            Toggle("", isOn: .constant(viewStore.user?.preferences?.notificationsEnabled ?? false))
                                                .toggleStyle(SwitchToggleStyle(tint: Theme.Palette.primaryRed))
                                        }
                                        .padding(.vertical, 8)
                                    }
                                }
                            )
                        }
                        .padding(.horizontal, 20)
                        
                        // Logout Button
                        Button(action: {
                            viewStore.send(.logout)
                        }) {
                            HStack {
                                Image(systemName: "arrow.right.square")
                                Text("Sign Out")
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.red.opacity(0.2))
                            .foregroundColor(.red)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.red.opacity(0.5), lineWidth: 1)
                            )
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                }
                .background(Theme.Gradient.background)
                .navigationTitle("Profile")
                .navigationBarTitleDisplayMode(.inline)
                .toolbarColorScheme(.dark, for: .navigationBar)
                .toolbarBackground(Theme.Palette.surface, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                    }
                } else {
                    // User is not logged in - show auth screen
                    AuthView(store: Store(initialState: AuthFeature.State()) {
                        AuthFeature()
                    })
                }
            }
            .onAppear {
                viewStore.send(.loadUser)
            }
            .onReceive(NotificationCenter.default.publisher(for: .userDidLogin)) { _ in
                viewStore.send(.loadUser)
            }
        }
    }
}

struct ProfileSectionView<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(Theme.Palette.primaryRed)
                    .frame(width: 24)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            content
        }
        .padding(20)
        .background(Theme.Palette.surface)
        .cornerRadius(12)
        .shadow(color: Theme.Shadow.red, radius: 4)
    }
}

struct ProfileRowView: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.gray)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text(value)
                    .font(.subheadline)
                    .foregroundColor(.white)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}


#Preview {
    ProfileView(store: Store(initialState: ProfileFeature.State()) {
        ProfileFeature()
    })
}