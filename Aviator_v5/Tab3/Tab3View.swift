import SwiftUI
import ComposableArchitecture

struct Tab3View: View {
    let store: StoreOf<Tab3Feature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationStack {
                ZStack {
                    LinearGradient(
                        colors: [.purple.opacity(0.8), .pink.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        Image(systemName: "gear")
                            .font(.system(size: 80))
                            .foregroundColor(.white.opacity(0.7))
                        
                        Text("Tab 4")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("This tab is currently a placeholder")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                        
                        Text("Functionality will be added here")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
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
