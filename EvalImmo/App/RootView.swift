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
                onAddProject: appState.showNewProject,
                onDuplicateProject: duplicateProject,
                onCompareProjects: { appState.compareProjects(ids: $0) }
            )
            .onAppear(perform: presentInitialProjectFormIfNeeded)
            .navigationDestination(for: AppState.Route.self) { route in
                switch route {
                case .newProject:
                    ProjectFormView { project in
                        projectStore.save(project)
                        appState.showProject(id: project.id)
                    }
                case .editProject(let id, let mode):
                    if let project = projectStore.project(with: id) {
                        ProjectFormView(project: project, mode: mode) { updatedProject in
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
                case .duplicateProject(let id):
                    if let project = projectStore.project(with: id) {
                        ProjectFormView(project: duplicatedProject(from: project), mode: .duplicate) { duplicatedProject in
                            projectStore.save(duplicatedProject)
                            appState.showProject(id: duplicatedProject.id)
                        }
                    } else {
                        ContentUnavailableView(
                            "Projet introuvable",
                            systemImage: "exclamationmark.triangle",
                            description: Text("Ce projet n'est plus disponible.")
                        )
                    }
                case .compareProjects(let ids):
                    let projects = ids.compactMap { projectStore.project(with: $0) }
                    ProjectComparisonView(projects: projects)
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

    @MainActor
    private func duplicateProject(_ project: InvestmentProjectSnapshot) {
        appState.duplicateProject(id: project.id)
    }

    private func duplicatedProject(from project: InvestmentProjectSnapshot) -> InvestmentProjectSnapshot {
        var draft = project.draft
        draft.name = duplicatedProjectName(from: project)

        return InvestmentProjectSnapshot(
            draft: draft,
            costs: project.costs,
            economicIndicators: project.economicIndicators,
            economicResult: project.economicResult,
            indicators: project.indicators,
            result: project.result
        )
    }

    private func duplicatedProjectName(from project: InvestmentProjectSnapshot) -> String {
        let name = project.draft.name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else {
            return "Projet du \(project.createdAt.formatted(date: .abbreviated, time: .omitted)) - scénario"
        }

        return "\(name) - scénario"
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
            .environmentObject(AppState())
    }
}
