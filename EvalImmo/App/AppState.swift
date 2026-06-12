//
//  AppState.swift
//  EvalImmo
//

import Foundation

final class AppState: ObservableObject {
    enum MainSection: Hashable {
        case projects
        case newProject
    }

    @Published var selectedSection: MainSection

    init(selectedSection: MainSection = .newProject) {
        self.selectedSection = selectedSection
    }
}
