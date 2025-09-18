import SwiftUI
import ComposableArchitecture

struct Tab3View: View {
    let store: StoreOf<Tab3Feature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationStack {
                ZStack {
                    Theme.Gradients.soft
                        .ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        Image(systemName: "gear")
                            .font(.system(size: 80))
                            .foregroundColor(Theme.Palette.white.opacity(Theme.Opacity.textSecondary))
                        
                        Text("Tab 4")
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
                    .navigationTitle("Tab 4")
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
    Tab3View(
        store: Store(initialState: Tab3Feature.State()) {
            Tab3Feature()
        }
    )
}
