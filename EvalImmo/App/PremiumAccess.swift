//
//  PremiumAccess.swift
//  EvalImmo
//

import Foundation
import StoreKit

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
    static let premiumProductID = "valoria_premium_9.99"

    @Published private(set) var isPremiumUnlocked: Bool
    @Published private(set) var premiumProduct: Product?
    @Published private(set) var isLoadingProducts = false
    @Published private(set) var isPurchasing = false
    @Published private(set) var productLoadingMessage: String?

    private let defaults: UserDefaults
    private let premiumEntitlementKey = "hasPremiumEntitlement"
    #if DEBUG
    private let debugPremiumUnlockedKey = "isPremiumUnlockedForTesting"
    #endif

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.isPremiumUnlocked = defaults.bool(forKey: premiumEntitlementKey)
        #if DEBUG
        self.isPremiumUnlocked = self.isPremiumUnlocked || defaults.bool(forKey: debugPremiumUnlockedKey)
        #endif

        Task {
            await loadProducts()
            await refreshPurchasedProducts()
        }
    }

    func access(projectCount: Int) -> FeatureAccess {
        FeatureAccess(isPremium: isPremiumUnlocked, projectCount: projectCount)
    }

    func loadProducts() async {
        guard premiumProduct == nil else { return }

        isLoadingProducts = true
        productLoadingMessage = nil

        do {
            premiumProduct = try await Product.products(for: [Self.premiumProductID]).first
            if premiumProduct == nil {
                productLoadingMessage = "Produit Premium indisponible pour le moment."
            }
        } catch {
            productLoadingMessage = "Chargement de l'offre Premium impossible."
        }

        isLoadingProducts = false
    }

    func purchasePremium() async -> PremiumPurchaseResult {
        if premiumProduct == nil {
            await loadProducts()
        }

        guard let premiumProduct else {
            return .unavailable
        }

        isPurchasing = true
        defer { isPurchasing = false }

        do {
            let result = try await premiumProduct.purchase()

            switch result {
            case .success(let verificationResult):
                let transaction = try checkVerified(verificationResult)
                guard transaction.productID == Self.premiumProductID else {
                    return .failed("L'achat ne correspond pas à l'offre Premium.")
                }

                setPremiumEntitlement(true)
                await transaction.finish()
                return .purchased
            case .pending:
                return .pending
            case .userCancelled:
                return .cancelled
            @unknown default:
                return .failed("Résultat d'achat non reconnu.")
            }
        } catch {
            return .failed(error.localizedDescription)
        }
    }

    func restorePurchases() async -> PremiumPurchaseResult {
        do {
            try await AppStore.sync()
            await refreshPurchasedProducts()
            return hasPremiumEntitlement ? .restored : .failed("Aucun achat Premium restaurable n'a été trouvé.")
        } catch {
            return .failed(error.localizedDescription)
        }
    }

    func observeTransactionUpdates() async {
        for await verificationResult in Transaction.updates {
            guard let transaction = try? checkVerified(verificationResult) else { continue }

            if transaction.productID == Self.premiumProductID {
                await refreshPurchasedProducts()
                await transaction.finish()
            }
        }
    }

    func refreshPurchasedProducts() async {
        var hasPremiumEntitlement = false

        for await verificationResult in Transaction.currentEntitlements {
            guard let transaction = try? checkVerified(verificationResult) else { continue }

            if transaction.productID == Self.premiumProductID, transaction.revocationDate == nil {
                hasPremiumEntitlement = true
            }
        }

        setPremiumEntitlement(hasPremiumEntitlement)
    }

    #if DEBUG
    func unlockPremiumForTesting() {
        defaults.set(true, forKey: debugPremiumUnlockedKey)
        refreshPremiumUnlockedState()
    }

    func lockPremiumForTesting() {
        defaults.set(false, forKey: debugPremiumUnlockedKey)
        refreshPremiumUnlockedState()
    }
    #endif

    private func setPremiumEntitlement(_ hasEntitlement: Bool) {
        defaults.set(hasEntitlement, forKey: premiumEntitlementKey)
        refreshPremiumUnlockedState()
    }

    private var hasPremiumEntitlement: Bool {
        defaults.bool(forKey: premiumEntitlementKey)
    }

    private func refreshPremiumUnlockedState() {
        var isUnlocked = defaults.bool(forKey: premiumEntitlementKey)
        #if DEBUG
        isUnlocked = isUnlocked || defaults.bool(forKey: debugPremiumUnlockedKey)
        #endif
        isPremiumUnlocked = isUnlocked
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let safe):
            safe
        case .unverified:
            throw PremiumAccessError.failedVerification
        }
    }
}

enum PremiumPurchaseResult: Equatable {
    case purchased
    case restored
    case pending
    case cancelled
    case unavailable
    case failed(String)

    var message: String? {
        switch self {
        case .purchased:
            "Premium est maintenant actif."
        case .restored:
            "Votre achat Premium a été restauré."
        case .pending:
            "L'achat est en attente de validation."
        case .cancelled:
            nil
        case .unavailable:
            "L'offre Premium n'est pas disponible. Vérifiez l'identifiant produit StoreKit."
        case .failed(let message):
            message
        }
    }

    var isSuccess: Bool {
        switch self {
        case .purchased, .restored:
            true
        case .pending, .cancelled, .unavailable, .failed:
            false
        }
    }
}

private enum PremiumAccessError: LocalizedError {
    case failedVerification

    var errorDescription: String? {
        switch self {
        case .failedVerification:
            "La transaction n'a pas pu être vérifiée."
        }
    }
}
