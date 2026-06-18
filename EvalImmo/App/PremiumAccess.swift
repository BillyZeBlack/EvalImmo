//
//  PremiumAccess.swift
//  EvalImmo
//

import Foundation

enum PremiumFeature: String, Identifiable {
    case additionalProject
    case duplication
    case comparison
    case projectPDFShare
    case comparisonPDFShare

    var id: String { rawValue }

    var title: String {
        switch self {
        case .additionalProject:
            "Projets illimités"
        case .duplication:
            "Duplication de scénarios"
        case .comparison:
            "Comparaison de projets"
        case .projectPDFShare:
            "Partage PDF du projet"
        case .comparisonPDFShare:
            "Partage PDF de la comparaison"
        }
    }

    var message: String {
        switch self {
        case .additionalProject:
            "La version gratuite permet de conserver un projet. Premium débloque la création de projets illimités."
        case .duplication:
            "Premium permet de dupliquer un projet pour tester rapidement plusieurs scénarios sur le même bien."
        case .comparison:
            "Premium débloque la comparaison de plusieurs projets pour faciliter la décision."
        case .projectPDFShare:
            "Premium permet de partager une synthèse PDF complète du projet."
        case .comparisonPDFShare:
            "Premium permet de partager une comparaison PDF lisible et rapide à transmettre."
        }
    }
}

struct FeatureAccess {
    static let freeProjectLimit = 1

    let isPremium: Bool
    let projectCount: Int

    var canCreateProject: Bool {
        isPremium || projectCount < Self.freeProjectLimit
    }

    var canDuplicateProject: Bool {
        isPremium
    }

    var canCompareProjects: Bool {
        isPremium
    }

    var canSharePDF: Bool {
        isPremium
    }
}

@MainActor
final class PremiumAccess: ObservableObject {
    @Published private(set) var isPremiumUnlocked: Bool

    private let defaults: UserDefaults
    private let premiumUnlockedKey = "isPremiumUnlockedForTesting"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.isPremiumUnlocked = defaults.bool(forKey: premiumUnlockedKey)
    }

    func access(projectCount: Int) -> FeatureAccess {
        FeatureAccess(isPremium: isPremiumUnlocked, projectCount: projectCount)
    }

    func unlockPremiumForTesting() {
        isPremiumUnlocked = true
        defaults.set(true, forKey: premiumUnlockedKey)
    }

    func lockPremiumForTesting() {
        isPremiumUnlocked = false
        defaults.set(false, forKey: premiumUnlockedKey)
    }
}
