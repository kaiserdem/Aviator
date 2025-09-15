import SwiftUI
import ComposableArchitecture

struct Tab3View: View {
    let store: StoreOf<Tab3Feature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationStack {
                VStack(spacing: 20) {
                    Image(systemName: "airplane")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                    
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
    Tab3View(
        store: Store(initialState: Tab3Feature.State()) {
            Tab3Feature()
        }
    )
}
