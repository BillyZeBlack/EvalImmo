//
//  EvalImmoApp.swift
//  EvalImmo
//

import SwiftUI

@main
struct EvalImmoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
