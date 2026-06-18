//
//  PremiumOfferView.swift
//  EvalImmo
//

import SwiftUI

struct PremiumOfferView: View {
    let feature: PremiumFeature
    let isPremiumUnlocked: Bool
    let onUnlockPremium: () -> Void

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
        VStack(spacing: 10) {
            if isPremiumUnlocked {
                Label("Premium est actif", systemImage: "checkmark.seal.fill")
                    .font(.headline)
                    .foregroundStyle(PremiumOfferPalette.gain)
                    .frame(maxWidth: .infinity, minHeight: 50)
            } else {
                Button(action: onUnlockPremium) {
                    Text("Débloquer Premium")
                        .font(.headline)
                        .frame(maxWidth: .infinity, minHeight: 50)
                }
                .buttonStyle(.borderedProminent)
                .tint(PremiumOfferPalette.brand)

                Text("Activation locale temporaire pour valider le parcours avant l'intégration StoreKit.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
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
