import SwiftUI
import ComposableArchitecture

struct Tab2View: View {
    let store: StoreOf<Tab2Feature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationStack {
                ZStack {
                    Theme.Gradients.card
                        .ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        Image(systemName: "star")
                            .font(.system(size: 80))
                            .foregroundColor(Theme.Palette.white.opacity(Theme.Opacity.textSecondary))
                        
                        Text("Tab 2")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(Theme.Palette.white)
                        
                        Text("This tab is currently a placeholder")
                            .font(.subheadline)
                            .foregroundColor(Theme.Palette.white.opacity(Theme.Opacity.textSecondary))
                            .multilineTextAlignment(.center)
                        
                        Text("Functionality will be added here")
                            .font(.caption)
                            .foregroundColor(Theme.Palette.white.opacity(Theme.Opacity.textTertiary))
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .navigationTitle("Tab 2")
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

#Preview {
    Tab2View(
        store: Store(initialState: Tab2Feature.State()) {
            Tab2Feature()
        }
    )
}
