
import SwiftUI
import ComposableArchitecture

@main
struct Aviator_v4App: App {
    var body: some Scene {
        WindowGroup {
            ContentView(
                store: Store(initialState: AppFeature.State()) {
                    AppFeature()
                }
            )
        }
    }
}
