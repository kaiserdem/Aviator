import SwiftUI

struct NewsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Авіа-новини") {
                    Text("Приклади новин з Reddit r/aviation будуть тут")
                }
            }
            .navigationTitle("Новини")
        }
    }
}

#Preview {
    NewsView()
}


