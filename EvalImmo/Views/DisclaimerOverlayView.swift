//
//  DisclaimerOverlayView.swift
//  EvalImmo
//

import SwiftUI

struct DisclaimerOverlayView: View {
    @State private var hasConfirmedReading = false
    let onAccept: () -> Void

    var body: some View {
        ZStack {
            DisclaimerPalette.backdrop
                .ignoresSafeArea()

            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 20) {
                    header

                    Text(disclaimerText)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)

                    confirmationToggle

                    Button("Continuer") {
                        onAccept()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .buttonBorderShape(.roundedRectangle)
                    .tint(DisclaimerPalette.brand)
                    .frame(maxWidth: .infinity)
                    .disabled(!hasConfirmedReading)
                }
                .padding(24)
                .background(DisclaimerPalette.card)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .shadow(color: .black.opacity(0.12), radius: 28, y: 16)
                .padding(.horizontal, 20)
            }
            .frame(maxWidth: 460)
        }
        .accessibilityAddTraits(.isModal)
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: "info.circle")
                .font(.title2)
                .foregroundStyle(DisclaimerPalette.brand)
                .frame(width: 34, height: 34)
                .background(DisclaimerPalette.brand.opacity(0.10))
                .clipShape(Circle())
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 6) {
                Text("Avant de commencer")
                    .font(.title3)
                    .bold()
                    .foregroundStyle(DisclaimerPalette.ink)

                Text("Un rappel important sur la portée des calculs.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var confirmationToggle: some View {
        Button {
            hasConfirmedReading.toggle()
        } label: {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: hasConfirmedReading ? "checkmark.square.fill" : "square")
                    .font(.title3)
                    .foregroundStyle(hasConfirmedReading ? DisclaimerPalette.brand : .secondary)
                    .frame(width: 28, height: 28)

                Text("J'ai lu et compris les limites de l'application")
                    .font(.body)
                    .foregroundStyle(DisclaimerPalette.ink)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(minHeight: 44)
        }
        .buttonStyle(.plain)
        .padding(14)
        .background(DisclaimerPalette.selectionBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityValue(hasConfirmedReading ? "Confirmé" : "Non confirmé")
    }

    private var disclaimerText: String {
        "Les résultats présentés sont des estimations indicatives, calculées à partir des données saisies. Ils ne constituent pas un conseil financier, fiscal, juridique ou patrimonial. Avant toute décision d'investissement, vérifiez vos hypothèses auprès de professionnels compétents."
    }
}

private enum DisclaimerPalette {
    static let backdrop = Color.black.opacity(0.28)
    static let card = Color.white
    static let brand = Color(red: 0.02, green: 0.29, blue: 0.24)
    static let ink = Color(red: 0.08, green: 0.13, blue: 0.14)
    static let selectionBackground = Color(red: 0.93, green: 0.97, blue: 0.96)
}

#Preview {
    DisclaimerOverlayView {}
}
