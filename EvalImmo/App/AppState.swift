//
//  AppState.swift
//  EvalImmo
//

import Foundation

final class AppState: ObservableObject {
    enum Route: Hashable {
        case newProject
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
    func showProject(id: UUID) {
        path = [.projectDetail(id)]
    }
}
