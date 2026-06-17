//
//  AppState.swift
//  EvalImmo
//

import Foundation

final class AppState: ObservableObject {
    enum Route: Hashable {
        case newProject
        case editProject(UUID)
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
    func editProject(id: UUID) {
        path.append(.editProject(id))
    }

    @MainActor
    func showProject(id: UUID) {
        path = [.projectDetail(id)]
    }
}
