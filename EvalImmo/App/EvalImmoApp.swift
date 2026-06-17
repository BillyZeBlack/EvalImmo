//
//  EvalImmoApp.swift
//  EvalImmo
//

import SwiftUI

@main
struct EvalImmoApp: App {
    @StateObject private var appState = AppState()
    @State private var isShowingLaunchSplash = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                RootView()
                    .environmentObject(appState)

                if isShowingLaunchSplash {
                    LaunchSplashView {
                        isShowingLaunchSplash = false
                    }
                    .transition(.opacity)
                }
            }
        }
    }
}
