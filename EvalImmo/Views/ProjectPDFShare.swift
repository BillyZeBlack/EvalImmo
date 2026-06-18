//
//  ProjectPDFShare.swift
//  EvalImmo
//

import SwiftUI
import UIKit

struct ProjectShareItem: Identifiable {
    let id = UUID()
    let url: URL
}

struct ProjectShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

@MainActor
enum ProjectPDFExporter {
    static func export(project: InvestmentProjectSnapshot) throws -> URL {
        let pageSize = CGSize(width: 595, height: 842)
        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(fileName(for: project))

        var mediaBox = CGRect(origin: .zero, size: pageSize)

        guard let consumer = CGDataConsumer(url: fileURL as CFURL),
              let pdfContext = CGContext(consumer: consumer, mediaBox: &mediaBox, nil) else {
            throw ProjectPDFExportError.renderingFailed
        }

        for page in ProjectPDFPage.allCases {
            let document = ProjectPDFDocumentView(project: project, page: page)
                .frame(width: pageSize.width, height: pageSize.height)
            let renderer = ImageRenderer(content: document)
            renderer.proposedSize = ProposedViewSize(pageSize)

            pdfContext.beginPDFPage(nil)
            renderer.render { _, renderInContext in
                renderInContext(pdfContext)
            }
            pdfContext.endPDFPage()
        }

        pdfContext.closePDF()
        return fileURL
    }

    private static func fileName(for project: InvestmentProjectSnapshot) -> String {
        let rawName = project.pdfProjectTitle
            .folding(options: .diacriticInsensitive, locale: .current)
            .lowercased()
            .replacingOccurrences(of: "[^a-z0-9]+", with: "-", options: .regularExpression)
            .trimmingCharacters(in: CharacterSet(charactersIn: "-"))

        return "valoria-\(rawName.isEmpty ? "projet" : rawName).pdf"
    }
}

enum ProjectPDFExportError: LocalizedError {
    case renderingFailed

    var errorDescription: String? {
        "Le PDF n'a pas pu être généré."
    }
}

private enum ProjectPDFPage: CaseIterable {
    case summary
    case details

    var index: Int {
        switch self {
        case .summary:
            return 1
        case .details:
            return 2
        }
    }
}

private struct ProjectPDFDocumentView: View {
    let project: InvestmentProjectSnapshot
    let page: ProjectPDFPage

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            header

            switch page {
            case .summary:
                summaryPageContent
            case .details:
                detailsPageContent
            }

            Spacer(minLength: 8)

            if page == .details {
                disclaimer
            }

            footer
        }
        .padding(24)
        .background(ProjectPDFPalette.background)
    }

    private var summaryPageContent: some View {
        VStack(alignment: .leading, spacing: 10) {
            pdfSection("Projet") {
                pdfRow("Type", project.draft.rentalType.title)
                pdfRow("Régime fiscal", project.draft.taxRegime.title)
                pdfRow("Création", project.createdAt.formatted(date: .abbreviated, time: .omitted))
            }

            pdfSection("Synthèse") {
                pdfRow("Prix total", pdfCurrency(project.costs.total))
                pdfRow("Montant financé", pdfCurrency(project.costs.financedAmount))
                pdfRow("Cashflow", pdfSignedCurrency(project.result.monthlyCashflow) + "/mois")
                pdfRow("Impôts estimés", pdfCurrency(project.indicators.taxes))
            }

            pdfSection("Acquisition") {
                pdfRow("Prix d'achat", pdfCurrency(project.draft.purchasePrice))
                pdfRow("Frais de notaire", pdfCurrency(project.draft.notaryFees))
                pdfRow("Frais d'agence", pdfCurrency(project.draft.agencyCosts))
                pdfRow("Travaux", pdfCurrency(project.draft.worksCost))
                pdfRow("Apport", pdfCurrency(project.draft.downPayment))
            }

            pdfSection("Financement") {
                pdfRow("Mensualité de crédit", pdfCurrency(project.draft.monthlyPayment) + "/mois")
                pdfRow("Montant financé", pdfCurrency(project.costs.financedAmount))
            }
        }
    }

    private var detailsPageContent: some View {
        VStack(alignment: .leading, spacing: 10) {
            pdfSection("Revenus et charges") {
                pdfRow("Loyer mensuel", pdfCurrency(project.draft.monthlyRent))
                pdfRow("Vacance locative", pdfPercent(project.draft.vacancyRate))
                pdfRow("Charges copropriété", pdfCurrency(project.draft.monthlyCondominiumFees) + "/mois")
                pdfRow("Taxe foncière", pdfCurrency(project.draft.annualPropertyTax) + "/an")
                pdfRow("Assurance PNO", pdfCurrency(project.draft.annualOwnerInsurance) + "/an")
                pdfRow("Comptable", pdfCurrency(project.draft.annualAccountantFees) + "/an")
            }

            pdfSection("Rendements") {
                pdfRow("Rendement brut", pdfPercent(project.economicResult.grossYield))
                pdfRow("Rendement net", pdfPercent(project.economicResult.netYieldBeforeTax))
                pdfRow("Rendement net-net", pdfPercent(project.result.netNetYield))
                pdfRow("Cashflow avant impôts", pdfSignedCurrency(project.economicResult.monthlyCashflowBeforeTax) + "/mois")
                pdfRow("Cashflow après impôts", pdfSignedCurrency(project.result.monthlyCashflow) + "/mois")
            }
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Valoria")
                    .font(.title)
                    .bold()
                    .foregroundStyle(ProjectPDFPalette.brand)

                Text("Synthèse du projet \(project.pdfProjectTitle)")
                    .font(.title2)
                    .bold()
                    .foregroundStyle(ProjectPDFPalette.ink)
                    .lineLimit(2)
            }

            Spacer()

            Text(Date().formatted(date: .abbreviated, time: .omitted))
                .font(.subheadline.monospacedDigit())
                .foregroundStyle(.secondary)
                .frame(width: 120, alignment: .trailing)
                .lineLimit(1)
        }
        .padding(.top, 4)
        .padding(.bottom, 2)
    }

    private var disclaimer: some View {
        Text("Les résultats présentés sont des estimations indicatives, calculées à partir des données saisies. Ils ne constituent pas un conseil financier, fiscal, juridique ou patrimonial. Avant toute décision d'investissement, vérifiez vos hypothèses auprès de professionnels compétents.")
            .font(.footnote)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
            .padding(10)
            .background(ProjectPDFPalette.note)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var footer: some View {
        HStack {
            Text("Valoria")
            Spacer()
            Text("Page \(page.index)/\(ProjectPDFPage.allCases.count)")
        }
        .font(.footnote.monospacedDigit())
        .foregroundStyle(.secondary)
    }

    private func pdfSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .bold()
                .foregroundStyle(ProjectPDFPalette.brand)

            VStack(spacing: 0) {
                content()
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(ProjectPDFPalette.card)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func pdfRow(_ title: String, _ value: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(width: 210, alignment: .leading)
                .lineLimit(2)

            Spacer(minLength: 8)

            Text(value)
                .font(.subheadline.monospacedDigit())
                .foregroundStyle(ProjectPDFPalette.ink)
                .multilineTextAlignment(.trailing)
                .lineLimit(2)
        }
        .padding(.vertical, 3)
    }

    private func pdfCurrency(_ value: Double) -> String {
        String(format: "%.2f EUR", value)
    }

    private func pdfSignedCurrency(_ value: Double) -> String {
        "\(value >= 0 ? "+" : "")\(String(format: "%.2f EUR", value))"
    }

    private func pdfPercent(_ value: Double) -> String {
        String(format: "%.2f %%", value)
    }
}

private enum ProjectPDFPalette {
    static let background = Color(red: 0.93, green: 0.97, blue: 0.96)
    static let card = Color.white
    static let brand = Color(red: 0.02, green: 0.29, blue: 0.24)
    static let ink = Color(red: 0.08, green: 0.13, blue: 0.14)
    static let note = Color.white.opacity(0.72)
}

private extension InvestmentProjectSnapshot {
    var pdfProjectTitle: String {
        let name = draft.name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else {
            return "Projet du \(createdAt.formatted(date: .abbreviated, time: .omitted))"
        }

        return name
    }
}
