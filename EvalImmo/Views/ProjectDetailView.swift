//
//  ProjectDetailView.swift
//  EvalImmo
//

import SwiftUI

struct ProjectDetailView: View {
    let project: InvestmentProjectSnapshot
    let onAddProject: () -> Void

    init(project: InvestmentProjectSnapshot, onAddProject: @escaping () -> Void = {}) {
        self.project = project
        self.onAddProject = onAddProject
    }

    var body: some View {
        List {
            Section("Projet") {
                textRow("Type de location", value: project.draft.rentalType.title)
                textRow("Regime fiscal", value: project.draft.taxRegime.title)
            }

            Section("Acquisition") {
                valueRow("Prix du bien", value: project.costs.price, suffix: "EUR")
                valueRow("Frais de notaire", value: project.costs.notaryFees, suffix: "EUR")
                valueRow("Frais d'agence", value: project.costs.agencyCosts, suffix: "EUR")
                valueRow("Travaux", value: project.costs.works, suffix: "EUR")
                valueRow("Prix total", value: project.costs.total, suffix: "EUR")
            }

            Section("Indicateurs") {
                valueRow("Rendement brut", value: project.result.grossYield, suffix: "%")
                valueRow("Rendement net", value: project.result.netYield, suffix: "%")
                valueRow("Rendement net-net", value: project.result.netNetYield, suffix: "%")
                valueRow("Cashflow mensuel", value: project.result.monthlyCashflow, suffix: "EUR")
            }

            Section("Revenus et charges") {
                valueRow("Loyers annuels", value: project.indicators.annualRentalPrice, suffix: "EUR")
                valueRow("Charges annuelles", value: project.indicators.annualCondominiumFees, suffix: "EUR")
                valueRow("Taxe fonciere annuelle", value: project.indicators.annualPropertyTax, suffix: "EUR")
                valueRow("Imposition estimee", value: project.indicators.taxes, suffix: "EUR")
            }
        }
        .navigationTitle("Projet")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: onAddProject) {
                    Label("Nouveau projet", systemImage: "plus")
                }
            }
        }
    }

    private func valueRow(_ title: String, value: Double, suffix: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text("\(value, specifier: "%.2f") \(suffix)")
                .foregroundStyle(.secondary)
        }
    }

    private func textRow(_ title: String, value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
    }
}

struct ProjectDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ProjectDetailView(
                project: InvestmentProjectSnapshot(
                    draft: InvestmentProjectDraft(),
                    costs: InvestmentCosts(price: 100_000, notaryFees: 8_000, agencyCosts: 5_000, works: 7_000),
                    indicators: InvestmentIndicators(
                        annualRentalPrice: 9_600,
                        annualCondominiumFees: 1_200,
                        taxes: 2_265.6,
                        monthlyPayment: 500,
                        annualPropertyTax: 600
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
