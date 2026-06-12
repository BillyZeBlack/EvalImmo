//
//  RootView.swift
//  EvalImmo
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var projectStore = ProjectStore()

    var body: some View {
        NavigationStack(path: $appState.path) {
            ProjectListView(
                store: projectStore,
                onAddProject: appState.showNewProject
            )
            .navigationDestination(for: AppState.Route.self) { route in
                switch route {
                case .newProject:
                    ProjectFormView { project in
                        projectStore.save(project)
                        appState.showProject(id: project.id)
                    }
                case .projectDetail(let id):
                    if let project = projectStore.project(with: id) {
                        ProjectDetailView(project: project)
                    } else {
                        ContentUnavailableView(
                            "Projet introuvable",
                            systemImage: "exclamationmark.triangle",
                            description: Text("Ce projet n'est plus disponible.")
                        )
                    }
                }
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
            .environmentObject(AppState())
    }
}
