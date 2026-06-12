//
//  EvalImmoApp.swift
//  EvalImmo
//

import SwiftUI

@main
struct EvalImmoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
        }
    }
}
