//
//  EvalImmoApp.swift
//  EvalImmo
//

import SwiftUI

@main
struct EvalImmoApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
        }
    }
}
