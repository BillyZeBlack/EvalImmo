//
//  ProjectRepository.swift
//  EvalImmo
//

import Foundation

protocol ProjectRepository {
    var projects: [InvestmentProjectSnapshot] { get }

    func save(_ project: InvestmentProjectSnapshot) throws
    func deleteProject(with id: InvestmentProjectSnapshot.ID) throws
}

final class InMemoryProjectRepository: ProjectRepository {
    private(set) var projects: [InvestmentProjectSnapshot] = []

    func save(_ project: InvestmentProjectSnapshot) throws {
        projects.append(project)
    }

    func deleteProject(with id: InvestmentProjectSnapshot.ID) throws {
        projects.removeAll { $0.id == id }
    }
}
