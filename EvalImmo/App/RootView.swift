//
//  RootView.swift
//  EvalImmo
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var premiumAccess: PremiumAccess
    @StateObject private var projectStore = ProjectStore(repository: FileProjectRepository())
    @State private var hasPresentedInitialProjectForm = false
    @State private var premiumFeature: PremiumFeature?

    var body: some View {
        NavigationStack(path: $appState.path) {
            ProjectListView(
                store: projectStore,
                access: featureAccess,
                onAddProject: addProject,
                onDuplicateProject: duplicateProject,
                onCompareProjects: compareProjects,
                onRequestPremium: showPremiumOffer
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
                    ProjectComparisonView(
                        projects: projects,
                        canShareComparison: featureAccess.canSharePDF,
                        onRequestPremium: { showPremiumOffer(for: .comparisonPDFShare) }
                    )
                case .projectDetail(let id):
                    if let project = projectStore.project(with: id) {
                        ProjectDetailView(
                            project: project,
                            canShareProject: featureAccess.canSharePDF,
                            onEditProject: {
                                appState.editProject(id: project.id)
                            },
                            onRequestPremium: { showPremiumOffer(for: .projectPDFShare) }
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
        .sheet(item: $premiumFeature) { feature in
            PremiumOfferView(
                feature: feature,
                premiumAccess: premiumAccess,
                onPremiumUnlocked: {
                    premiumFeature = nil
                }
            )
        }
    }

    private var featureAccess: FeatureAccess {
        premiumAccess.access(projectCount: projectStore.projects.count)
    }

    private func presentInitialProjectFormIfNeeded() {
        guard !hasPresentedInitialProjectForm else { return }
        guard projectStore.projects.isEmpty else { return }
        guard appState.path.isEmpty else { return }

        hasPresentedInitialProjectForm = true
        appState.showNewProject()
    }

    @MainActor
    private func addProject() {
        if featureAccess.canCreateProject {
            appState.showNewProject()
        } else {
            showPremiumOffer(for: .additionalProject)
        }
    }

    @MainActor
    private func duplicateProject(_ project: InvestmentProjectSnapshot) {
        if featureAccess.canDuplicateProject {
            appState.duplicateProject(id: project.id)
        } else {
            showPremiumOffer(for: .duplication)
        }
    }

    @MainActor
    private func compareProjects(ids: [UUID]) {
        if featureAccess.canCompareProjects {
            appState.compareProjects(ids: ids)
        } else {
            showPremiumOffer(for: .comparison)
        }
    }

    @MainActor
    private func showPremiumOffer(for feature: PremiumFeature) {
        premiumFeature = feature
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
