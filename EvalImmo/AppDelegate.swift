//
//  AppDelegate.swift
//  EvalImmo
//
//  Created by williams saadi on 22/03/2021.
//

import UIKit
import Parse

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let parseConfig = ParseClientConfiguration {
              $0.applicationId = "afijus5pnJLRTNyVIcUWCAI5RS6wuVK81RlU4UXN"
              $0.clientKey = "lUoytpTX2L3XbULjgX53OFWosk6f9SVpycVjwTfn"
              $0.server = "https://parseapi.back4app.com"
          }
          Parse.initialize(with: parseConfig)
        return true
    }
}
