//
//  ProjectDetailView.swift
//  EvalImmo
//

import SwiftUI

struct ProjectDetailView: View {
    let project: InvestmentProjectSnapshot
    let onEditProject: () -> Void

    init(project: InvestmentProjectSnapshot, onEditProject: @escaping () -> Void = {}) {
        self.project = project
        self.onEditProject = onEditProject
    }

    var body: some View {
        List {
            Section("Projet") {
                textRow("Nom", value: projectTitle)
                textRow("Type de location", value: project.draft.rentalType.title)
                textRow("Régime fiscal", value: project.draft.taxRegime.title)
            }

            InvestmentResultsDetailView(project: project)
        }
        .navigationTitle("Projet")
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(ProjectDetailPalette.background)
        .tint(ProjectDetailPalette.brand)
        .toolbarBackground(ProjectDetailPalette.background, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Modifier", systemImage: "pencil", action: onEditProject)
            }
        }
    }

    private var projectTitle: String {
        let name = project.draft.name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else {
            return "Projet du \(project.createdAt.formatted(date: .abbreviated, time: .omitted))"
        }

        return name
    }

    private func textRow(_ title: String, value: String) -> some View {
        LabeledContent(title) {
            Text(value)
                .foregroundStyle(.secondary)
        }
    }
}

struct InvestmentResultsDetailView: View {
    let project: InvestmentProjectSnapshot

    var body: some View {
        Section {
            resultRow("Prix total", value: project.costs.total, format: .currency)
            InvestmentPerformanceSummaryView(project: project)
        } header: {
            Label("Synthese", systemImage: "chart.pie")
        }

        Section {
            MonthlyFlowChartView(project: project)
        } header: {
            Label("Revenus et charges", systemImage: "list.bullet.rectangle")
        }
    }

    private func resultRow(_ title: String, value: Double, format: ResultValueFormat) -> some View {
        LabeledContent(title) {
            Text(format.string(from: value))
                .font(.body.monospacedDigit())
                .foregroundStyle(value < 0 ? ProjectDetailPalette.loss : .secondary)
        }
    }

}

private enum ResultValueFormat {
    case currency
    case signedCurrency
    case percent

    func string(from value: Double) -> String {
        let formattedValue = String(format: "%.2f", value)

        switch self {
        case .currency:
            return "\(formattedValue) EUR"
        case .signedCurrency:
            return "\(value >= 0 ? "+" : "")\(formattedValue) EUR"
        case .percent:
            return "\(formattedValue) %"
        }
    }
}

private enum ProjectDetailPalette {
    static let background = Color(red: 0.93, green: 0.97, blue: 0.96)
    static let brand = Color(red: 0.02, green: 0.29, blue: 0.24)
    static let loss = Color(red: 0.78, green: 0.18, blue: 0.16)
}

struct ProjectDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ProjectDetailView(
                project: InvestmentProjectSnapshot(
                    draft: InvestmentProjectDraft(),
                    costs: InvestmentCosts(price: 100_000, notaryFees: 8_000, agencyCosts: 5_000, works: 7_000),
                    economicIndicators: InvestmentEconomicIndicators(
                        annualRentalPrice: 9_600,
                        annualCondominiumFees: 1_200,
                        monthlyPayment: 500,
                        annualPropertyTax: 600,
                        annualOwnerInsurance: 180
                    ),
                    economicResult: InvestmentEconomicResult(
                        grossYield: 8,
                        netYieldBeforeTax: 6.5,
                        monthlyCashflowBeforeTax: 150
                    ),
                    indicators: InvestmentIndicators(
                        annualRentalPrice: 9_600,
                        annualCondominiumFees: 1_200,
                        taxes: 2_265.6,
                        monthlyPayment: 500,
                        annualPropertyTax: 600,
                        annualOwnerInsurance: 180
                    ),
                    result: InvestmentYieldResult(
                        grossYield: 8,
                        netYield: 6.5,
                        netNetYield: 4.61,
                        monthlyCashflow: -38.8
                    )
                )
            )
        }
    }
}
