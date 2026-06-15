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

            InvestmentResultsDetailView(project: project)
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

    private func textRow(_ title: String, value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
    }
}

struct InvestmentResultsDetailView: View {
    let project: InvestmentProjectSnapshot

    private var monthlyRent: Double {
        project.economicIndicators.annualRentalPrice / 12
    }

    private var monthlyCondominiumFees: Double {
        project.economicIndicators.annualCondominiumFees / 12
    }

    private var monthlyPropertyTax: Double {
        project.economicIndicators.annualPropertyTax / 12
    }

    private var monthlyTaxes: Double {
        project.indicators.taxes / 12
    }

    var body: some View {
        Section {
            resultRow("Prix total", value: project.costs.total, format: .currency)
            resultRow("Rendement brut", value: project.economicResult.grossYield, format: .percent)
            resultRow("Rendement net avant impots", value: project.economicResult.netYieldBeforeTax, format: .percent)
            resultRow("Rendement net-net", value: project.result.netNetYield, format: .percent)
            resultRow("Cashflow apres impots", value: project.result.monthlyCashflow, format: .currency)
        } header: {
            Label("Synthese", systemImage: "chart.pie")
        }

        Section {
            resultRow("Prix du bien", value: project.costs.price, format: .currency)
            resultRow("Frais de notaire", value: project.costs.notaryFees, format: .currency)
            resultRow("Frais d'agence", value: project.costs.agencyCosts, format: .currency)
            resultRow("Travaux", value: project.costs.works, format: .currency)
            resultRow("Prix total", value: project.costs.total, format: .currency)
        } header: {
            Label("Acquisition", systemImage: "house")
        }

        Section {
            resultRow("Loyer mensuel", value: monthlyRent, format: .currency)
            resultRow("Loyers annuels", value: project.economicIndicators.annualRentalPrice, format: .currency)
            resultRow("Charges mensuelles", value: monthlyCondominiumFees, format: .currency)
            resultRow("Charges annuelles", value: project.economicIndicators.annualCondominiumFees, format: .currency)
            resultRow("Taxe fonciere mensuelle", value: monthlyPropertyTax, format: .currency)
            resultRow("Taxe fonciere annuelle", value: project.economicIndicators.annualPropertyTax, format: .currency)
            resultRow("Mensualite de credit", value: project.economicIndicators.monthlyPayment, format: .currency)
        } header: {
            Label("Revenus et charges", systemImage: "list.bullet.rectangle")
        }

        Section {
            resultTextRow("Regime", value: project.draft.taxRegime.title)
            resultRow("Taux marginal", value: project.draft.taxRate, format: .percent)
            resultRow("Imposition annuelle", value: project.indicators.taxes, format: .currency)
            resultRow("Imposition mensuelle", value: monthlyTaxes, format: .currency)
        } header: {
            Label("Fiscalite", systemImage: "percent")
        }

        Section {
            resultRow("Loyer mensuel", value: monthlyRent, format: .signedCurrency)
            resultRow("Charges", value: -monthlyCondominiumFees, format: .signedCurrency)
            resultRow("Taxe fonciere", value: -monthlyPropertyTax, format: .signedCurrency)
            resultRow("Mensualite de credit", value: -project.economicIndicators.monthlyPayment, format: .signedCurrency)
            resultRow("Cashflow avant impots", value: project.economicResult.monthlyCashflowBeforeTax, format: .signedCurrency)
            resultRow("Imposition", value: -monthlyTaxes, format: .signedCurrency)
            resultRow("Cashflow apres impots", value: project.result.monthlyCashflow, format: .signedCurrency)
        } header: {
            Label("Cashflow mensuel", systemImage: "arrow.left.arrow.right")
        }
    }

    private func resultRow(_ title: String, value: Double, format: ResultValueFormat) -> some View {
        LabeledContent(title) {
            Text(format.string(from: value))
                .foregroundStyle(value < 0 ? .red : .secondary)
        }
    }

    private func resultTextRow(_ title: String, value: String) -> some View {
        LabeledContent(title) {
            Text(value)
                .foregroundStyle(.secondary)
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
                        annualPropertyTax: 600
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
