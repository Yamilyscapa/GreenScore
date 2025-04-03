//
//  GreenScoreApp.swift
//  GreenScore
//
//  Created by Yamil Yscapa on 01/04/25.
//

import SwiftUI
import SwiftData

@main
struct GreenScoreApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Streak.self, Footprint.self], inMemory: true)
    }
}
