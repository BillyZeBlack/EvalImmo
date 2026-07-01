//
//  EvalImmoApp.swift
//  EvalImmo
//

import SwiftUI

@main
struct EvalImmoApp: App {
    @AppStorage("hasAcceptedDisclaimer") private var hasAcceptedDisclaimer = false
    @StateObject private var appState = AppState()
    @StateObject private var premiumAccess = PremiumAccess()
    @State private var isShowingLaunchSplash = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                RootView()
                    .environmentObject(appState)
                    .environmentObject(premiumAccess)

                if isShowingLaunchSplash {
                    LaunchSplashView {
                        isShowingLaunchSplash = false
                    }
                    .transition(.opacity)
                }

                if !isShowingLaunchSplash && !hasAcceptedDisclaimer {
                    DisclaimerOverlayView {
                        hasAcceptedDisclaimer = true
                    }
                    .transition(.opacity)
                }
            }
            .preferredColorScheme(.light)
            .animation(.easeOut(duration: 0.25), value: isShowingLaunchSplash)
            .animation(.easeOut(duration: 0.25), value: hasAcceptedDisclaimer)
            .task {
                await premiumAccess.observeTransactionUpdates()
            }
        }
    }
}
