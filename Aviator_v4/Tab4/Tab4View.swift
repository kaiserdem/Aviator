import SwiftUI
import ComposableArchitecture

struct Tab4View: View {
    let store: StoreOf<Tab4Feature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationStack {
                VStack(spacing: 20) {
                    Image(systemName: "map")
                        .font(.system(size: 80))
                        .foregroundColor(.green)
                    
                    Text(viewStore.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text(viewStore.message)
                        .font(.title2)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Text("This feature will be implemented soon")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .navigationTitle(viewStore.title)
                .onAppear {
                    viewStore.send(.onAppear)
                }
            }
        }
    }
}

#Preview {
    Tab4View(
        store: Store(initialState: Tab4Feature.State()) {
            Tab4Feature()
        }
    )
}
