//
//  PremiumOfferView.swift
//  EvalImmo
//

import SwiftUI

struct PremiumOfferView: View {
    let feature: PremiumFeature
    @ObservedObject var premiumAccess: PremiumAccess
    let onPremiumUnlocked: () -> Void
    @State private var statusMessage: String?
    @State private var isRestoringPurchases = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    premiumHeader
                    benefitList
                    premiumAction
                }
                .padding(24)
            }
            .background(PremiumOfferPalette.background)
            .navigationTitle("Premium")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var premiumHeader: some View {
        VStack(alignment: .leading, spacing: 14) {
            Image(systemName: "sparkles")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(PremiumOfferPalette.gold)
                .frame(width: 52, height: 52)
                .background(PremiumOfferPalette.brand.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 16))

            VStack(alignment: .leading, spacing: 8) {
                Text(feature.title)
                    .font(.title.bold())
                    .foregroundStyle(PremiumOfferPalette.ink)

                Text(feature.message)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var benefitList: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Inclus avec Premium")
                .font(.headline)
                .foregroundStyle(PremiumOfferPalette.ink)

            premiumBenefit("Projets illimités", systemImage: "folder.badge.plus")
            premiumBenefit("Duplication de scénarios", systemImage: "doc.on.doc")
            premiumBenefit("Comparaison multi-projets", systemImage: "chart.bar.xaxis")
            premiumBenefit("Partage PDF projet et comparaison", systemImage: "square.and.arrow.up")
        }
        .padding(18)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private var premiumAction: some View {
        VStack(spacing: 12) {
            if premiumAccess.isPremiumUnlocked {
                Label("Premium est actif", systemImage: "checkmark.seal.fill")
                    .font(.headline)
                    .foregroundStyle(PremiumOfferPalette.gain)
                    .frame(maxWidth: .infinity, minHeight: 50)
            } else {
                Button {
                    Task {
                        await purchasePremium()
                    }
                } label: {
                    if premiumAccess.isPurchasing {
                        ProgressView()
                            .tint(.white)
                            .frame(maxWidth: .infinity, minHeight: 50)
                    } else {
                        Text(purchaseButtonTitle)
                            .font(.headline)
                            .frame(maxWidth: .infinity, minHeight: 50)
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(PremiumOfferPalette.brand)
                .disabled(premiumAccess.premiumProduct == nil || premiumAccess.isLoadingProducts || premiumAccess.isPurchasing)

                Button("Restaurer mes achats") {
                    Task {
                        await restorePurchases()
                    }
                }
                .buttonStyle(.bordered)
                .disabled(premiumAccess.isPurchasing || isRestoringPurchases)

                if isRestoringPurchases {
                    ProgressView()
                }

                if let statusMessage {
                    Text(statusMessage)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                } else if let productLoadingMessage = premiumAccess.productLoadingMessage {
                    Text(productLoadingMessage)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                #if DEBUG
                Button("Activer Premium en local") {
                    premiumAccess.unlockPremiumForTesting()
                    onPremiumUnlocked()
                }
                .font(.footnote.weight(.semibold))
                .foregroundStyle(PremiumOfferPalette.brand)
                #endif
            }
        }
    }

    private var purchaseButtonTitle: String {
        if premiumAccess.isLoadingProducts {
            "Chargement..."
        } else if let premiumProduct = premiumAccess.premiumProduct {
            "Débloquer Premium - \(premiumProduct.displayPrice)"
        } else {
            "Offre indisponible"
        }
    }

    private func purchasePremium() async {
        let result = await premiumAccess.purchasePremium()
        handle(result)
    }

    private func restorePurchases() async {
        isRestoringPurchases = true
        let result = await premiumAccess.restorePurchases()
        isRestoringPurchases = false
        handle(result)
    }

    private func handle(_ result: PremiumPurchaseResult) {
        statusMessage = result.message

        if result.isSuccess {
            onPremiumUnlocked()
        }
    }

    private func premiumBenefit(_ title: String, systemImage: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.headline)
                .foregroundStyle(PremiumOfferPalette.brand)
                .frame(width: 28)

            Text(title)
                .font(.body)
                .foregroundStyle(PremiumOfferPalette.ink)

            Spacer()
        }
    }
}

private enum PremiumOfferPalette {
    static let background = Color(red: 0.93, green: 0.97, blue: 0.96)
    static let brand = Color(red: 0.02, green: 0.29, blue: 0.24)
    static let ink = Color(red: 0.08, green: 0.13, blue: 0.14)
    static let gain = Color(red: 0.00, green: 0.48, blue: 0.38)
    static let gold = Color(red: 0.91, green: 0.69, blue: 0.32)
}
