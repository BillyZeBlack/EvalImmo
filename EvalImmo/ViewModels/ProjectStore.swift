//
//  ProjectStore.swift
//  EvalImmo
//

import Foundation

@MainActor
final class ProjectStore: ObservableObject {
    @Published private(set) var projects: [InvestmentProjectSnapshot]

    private let repository: ProjectRepository

    init(repository: ProjectRepository = InMemoryProjectRepository()) {
        self.repository = repository
        self.projects = repository.projects
    }

    func save(_ project: InvestmentProjectSnapshot) {
        do {
            try repository.save(project)
            projects = repository.projects
        } catch {
            // Persistence errors are still surfaced by the form ViewModel.
        }
    }

    func deleteProject(with id: InvestmentProjectSnapshot.ID) {
        do {
            try repository.deleteProject(with: id)
            projects = repository.projects
        } catch {
            // In-memory deletion cannot currently fail.
        }
    }

    func project(with id: InvestmentProjectSnapshot.ID) -> InvestmentProjectSnapshot? {
        projects.first { $0.id == id }
    }
}
