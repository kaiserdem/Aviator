//
//  ContentView.swift
//  Aviator
//
//  Created by Yaroslav Golinskiy on 09/09/2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            FlightsView()
                .tabItem {
                    Label("Рейси", systemImage: "airplane")
                }
            NewsView()
                .tabItem {
                    Label("Новини", systemImage: "newspaper")
                }
            AirportsView()
                .tabItem {
                    Label("Аеропорти", systemImage: "building.2")
                }
            AircraftView()
                .tabItem {
                    Label("Літаки", systemImage: "airplane.circle")
                }
        }
    }
}

#Preview {
    ContentView()
}
