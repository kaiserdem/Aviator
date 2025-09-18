import SwiftUI
import ComposableArchitecture

struct AviationView: View {
    let store: StoreOf<AviationFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationStack {
                ZStack {
                    Theme.Gradients.primary
                        .ignoresSafeArea()
                    
                    VStack {
                        if viewStore.isLoading {
                            VStack {
                                ProgressView()
                                    .scaleEffect(1.5)
                                    .tint(Theme.Palette.white)
                                Text("Loading...")
                                    .foregroundColor(Theme.Palette.white)
                                    .font(.headline)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else if let errorMessage = viewStore.errorMessage {
                            VStack(spacing: 16) {
                                Image(systemName: "exclamationmark.triangle")
                                    .font(.system(size: 60))
                                    .foregroundColor(Theme.Palette.brightOrangeRed)
                                Text("Error")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(Theme.Palette.white)
                                Text(errorMessage)
                                    .foregroundColor(Theme.Palette.white.opacity(Theme.Opacity.textSecondary))
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else if viewStore.aviationData.isEmpty {
                            VStack(spacing: 20) {
                                Image(systemName: "airplane")
                                    .font(.system(size: 80))
                                    .foregroundColor(Theme.Palette.white.opacity(Theme.Opacity.textSecondary))
                                Text("Aviation")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(Theme.Palette.white)
                                Text("Aviation information will appear here")
                                    .font(.subheadline)
                                    .foregroundColor(Theme.Palette.white.opacity(Theme.Opacity.textSecondary))
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            List(viewStore.aviationData) { item in
                                AviationRowView(item: item)
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                            }
                            .listStyle(PlainListStyle())
                            .scrollContentBackground(.hidden)
                        }
                    }
                    .navigationTitle("Aviation")
                    .navigationBarTitleDisplayMode(.large)
                    .toolbarColorScheme(.dark, for: .navigationBar)
                }
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
}

struct AviationRowView: View {
    let item: AviationItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(.headline)
                        .foregroundColor(Theme.Palette.white)
                    
                    Text(item.category)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Theme.Gradients.vibrant)
                        .foregroundColor(Theme.Palette.white)
                        .cornerRadius(4)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(Theme.Palette.white.opacity(Theme.Opacity.textTertiary))
                    .font(.caption)
            }
            
            Text(item.description)
                .font(.subheadline)
                .foregroundColor(Theme.Palette.white.opacity(Theme.Opacity.textSecondary))
                .lineLimit(2)
        }
        .padding()
        .background(Theme.Palette.white.opacity(Theme.Opacity.cardBackground))
        .cornerRadius(12)
        .shadow(color: Theme.Shadows.medium, radius: 4)
    }
}

#Preview {
    AviationView(
        store: Store(initialState: AviationFeature.State()) {
            AviationFeature()
        }
    )
}
