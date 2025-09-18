import SwiftUI
import ComposableArchitecture

struct Tab2View: View {
    let store: StoreOf<Tab2Feature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationStack {
                ZStack {
                    LinearGradient(
                        colors: [.orange.opacity(0.8), .red.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        Image(systemName: "star")
                            .font(.system(size: 80))
                            .foregroundColor(.white.opacity(0.7))
                        
                        Text("Tab 2")
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
