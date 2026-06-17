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

enum ProjectRepositoryError: Error {
    case missingApplicationSupportDirectory
}

final class InMemoryProjectRepository: ProjectRepository {
    private(set) var projects: [InvestmentProjectSnapshot] = []

    func save(_ project: InvestmentProjectSnapshot) throws {
        if let index = projects.firstIndex(where: { $0.id == project.id }) {
            projects[index] = project
        } else {
            projects.append(project)
        }
    }

    func deleteProject(with id: InvestmentProjectSnapshot.ID) throws {
        projects.removeAll { $0.id == id }
    }
}

final class FileProjectRepository: ProjectRepository {
    private let fileURL: URL
    private let fileManager: FileManager
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    private(set) var projects: [InvestmentProjectSnapshot]

    init(
        fileURL: URL? = nil,
        fileManager: FileManager = .default
    ) {
        self.fileManager = fileManager
        self.encoder = JSONEncoder()
        self.decoder = JSONDecoder()
        self.encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        var resolvedFileURL: URL
        var loadedProjects: [InvestmentProjectSnapshot]
        do {
            resolvedFileURL = try fileURL ?? Self.defaultFileURL(fileManager: fileManager)
            loadedProjects = try Self.loadProjects(
                from: resolvedFileURL,
                fileManager: fileManager,
                decoder: decoder
            )
        } catch {
            let fallbackDirectory = fileManager.temporaryDirectory
                .appendingPathComponent("EvalImmo", isDirectory: true)
            resolvedFileURL = fallbackDirectory.appendingPathComponent("projects.json")
            loadedProjects = []
        }

        self.fileURL = resolvedFileURL
        self.projects = loadedProjects
    }

    func save(_ project: InvestmentProjectSnapshot) throws {
        if let index = projects.firstIndex(where: { $0.id == project.id }) {
            projects[index] = project
        } else {
            projects.append(project)
        }

        try persistProjects()
    }

    func deleteProject(with id: InvestmentProjectSnapshot.ID) throws {
        projects.removeAll { $0.id == id }
        try persistProjects()
    }

    private func persistProjects() throws {
        let directory = fileURL.deletingLastPathComponent()
        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)

        let data = try encoder.encode(projects)
        try data.write(to: fileURL, options: [.atomic])
    }

    private static func loadProjects(
        from fileURL: URL,
        fileManager: FileManager,
        decoder: JSONDecoder
    ) throws -> [InvestmentProjectSnapshot] {
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return []
        }

        let data = try Data(contentsOf: fileURL)
        return try decoder.decode([InvestmentProjectSnapshot].self, from: data)
    }

    private static func defaultFileURL(fileManager: FileManager) throws -> URL {
        guard let applicationSupportURL = fileManager.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first else {
            throw ProjectRepositoryError.missingApplicationSupportDirectory
        }

        return applicationSupportURL
            .appendingPathComponent("EvalImmo", isDirectory: true)
            .appendingPathComponent("projects.json")
    }
}
