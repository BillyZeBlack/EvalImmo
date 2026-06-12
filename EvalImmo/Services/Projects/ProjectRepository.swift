//
//  ProjectRepository.swift
//  EvalImmo
//

import Foundation

protocol ProjectRepository {
    var projects: [InvestmentProjectSnapshot] { get }

    func save(_ project: InvestmentProjectSnapshot) throws
}

final class InMemoryProjectRepository: ProjectRepository {
    private(set) var projects: [InvestmentProjectSnapshot] = []

    func save(_ project: InvestmentProjectSnapshot) throws {
        projects.append(project)
    }
}
