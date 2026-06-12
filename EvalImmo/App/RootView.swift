//
//  RootView.swift
//  EvalImmo
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        TabView(selection: $appState.selectedSection) {
            ProjectListPlaceholderView()
                .tabItem {
                    Label("Projets", systemImage: "list.bullet")
                }
                .tag(AppState.MainSection.projects)

            ProjectFormView()
                .tabItem {
                    Label("Nouveau", systemImage: "plus.circle")
                }
                .tag(AppState.MainSection.newProject)
        }
    }
}

private struct ProjectListPlaceholderView: View {
    var body: some View {
        NavigationView {
            List {
                ContentUnavailableRow(
                    title: "Aucun projet",
                    subtitle: "Les projets sauvegardes apparaitront ici."
                )
            }
            .navigationTitle("Projets")
        }
    }
}

private struct ContentUnavailableRow: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
            .environmentObject(AppState())
    }
}
