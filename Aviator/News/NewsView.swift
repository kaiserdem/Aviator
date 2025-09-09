import SwiftUI
import ComposableArchitecture

struct NewsView: View {
    let store: StoreOf<NewsFeature>
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { _ in
            NavigationStack {
                List {
                    Section("Aviation news") {
                        Text("Sample posts from Reddit r/aviation will be here")
                    }
                }
                .navigationTitle("News")
            }
        }
    }
}


