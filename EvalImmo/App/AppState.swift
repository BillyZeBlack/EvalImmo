//
//  AppState.swift
//  EvalImmo
//

import Foundation

final class AppState: ObservableObject {
    enum Route: Hashable {
        case newProject
        case editProject(UUID, ProjectFormMode = .update)
        case duplicateProject(UUID)
        case compareProjects([UUID])
        case projectDetail(UUID)
    }

    @Published var path: [Route]

    init(path: [Route] = []) {
        self.path = path
    }

    @MainActor
    func showNewProject() {
        path.append(.newProject)
    }

    @MainActor
    func editProject(id: UUID, mode: ProjectFormMode = .update) {
        path.append(.editProject(id, mode))
    }

    @MainActor
    func duplicateProject(id: UUID) {
        path.append(.duplicateProject(id))
    }

    @MainActor
    func compareProjects(ids: [UUID]) {
        path.append(.compareProjects(ids))
    }

    @MainActor
    func showProject(id: UUID) {
        path = [.projectDetail(id)]
    }
}
