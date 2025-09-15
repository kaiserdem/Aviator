//
//  Aviator_v4App.swift
//  Aviator_v4
//
//  Created by Yaroslav Golinskiy on 14/09/2025.
//

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
