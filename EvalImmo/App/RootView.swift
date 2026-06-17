//
//  RootView.swift
//  EvalImmo
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var projectStore = ProjectStore(repository: FileProjectRepository())
    @State private var hasPresentedInitialProjectForm = false

    var body: some View {
        NavigationStack(path: $appState.path) {
            ProjectListView(
                store: projectStore,
                onAddProject: appState.showNewProject
            )
            .onAppear(perform: presentInitialProjectFormIfNeeded)
            .navigationDestination(for: AppState.Route.self) { route in
                switch route {
                case .newProject:
                    ProjectFormView { project in
                        projectStore.save(project)
                        appState.showProject(id: project.id)
                    }
                case .editProject(let id):
                    if let project = projectStore.project(with: id) {
                        ProjectFormView(project: project) { updatedProject in
                            projectStore.save(updatedProject)
                            appState.showProject(id: updatedProject.id)
                        }
                    } else {
                        ContentUnavailableView(
                            "Projet introuvable",
                            systemImage: "exclamationmark.triangle",
                            description: Text("Ce projet n'est plus disponible.")
                        )
                    }
                case .projectDetail(let id):
                    if let project = projectStore.project(with: id) {
                        ProjectDetailView(
                            project: project,
                            onEditProject: {
                                appState.editProject(id: project.id)
                            }
                        )
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

    private func presentInitialProjectFormIfNeeded() {
        guard !hasPresentedInitialProjectForm else { return }
        guard projectStore.projects.isEmpty else { return }
        guard appState.path.isEmpty else { return }

        hasPresentedInitialProjectForm = true
        appState.showNewProject()
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
            .environmentObject(AppState())
    }
}
