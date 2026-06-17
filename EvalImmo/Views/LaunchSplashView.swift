//
//  LaunchSplashView.swift
//  EvalImmo
//

import SwiftUI

struct LaunchSplashView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var buildingsOpacity = 0.0
    @State private var curveProgress = 0.0
    @State private var splashOpacity = 1.0

    let onCompletion: () -> Void

    var body: some View {
        ZStack {
            LaunchSplashPalette.background
                .ignoresSafeArea()

            GeometryReader { geometry in
                let logoSize = min(geometry.size.width * 0.72, geometry.size.height * 0.42, 340)

                ZStack {
                    Image(decorative: "valoria-logo-buildings")
                        .resizable()
                        .scaledToFit()
                        .opacity(buildingsOpacity)

                    Image(decorative: "valoria-logo-curve")
                        .resizable()
                        .scaledToFit()
                        .mask(alignment: .leading) {
                            Rectangle()
                                .frame(width: logoSize * curveProgress)
                        }
                }
                .frame(width: logoSize, height: logoSize)
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            }
        }
        .opacity(splashOpacity)
        .task {
            await runAnimation()
        }
        .accessibilityHidden(true)
    }

    @MainActor
    private func runAnimation() async {
        if reduceMotion {
            withAnimation(.easeOut(duration: 0.35)) {
                buildingsOpacity = 1
                curveProgress = 1
            }
            try? await Task.sleep(for: .milliseconds(600))
        } else {
            withAnimation(.easeOut(duration: 1.4)) {
                buildingsOpacity = 1
            }

            try? await Task.sleep(for: .milliseconds(1_500))

            withAnimation(.easeInOut(duration: 1.6)) {
                curveProgress = 1
            }

            try? await Task.sleep(for: .milliseconds(2_300))
        }

        withAnimation(.easeOut(duration: 0.3)) {
            splashOpacity = 0
        }

        try? await Task.sleep(for: .milliseconds(320))
        onCompletion()
    }
}

private enum LaunchSplashPalette {
    static let background = Color(red: 0.98, green: 0.96, blue: 0.92)
}

#Preview {
    LaunchSplashView {}
}
