//
//  Aviator_v3App.swift
//  Aviator_v3
//
//  Created by Yaroslav Golinskiy on 12/09/2025.
//

import SwiftUI
import ComposableArchitecture

@main
struct Aviator_v3App: App {
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
