//
//  ProjectFormView.swift
//  EvalImmo
//

import SwiftUI

struct ProjectFormView: View {
    @StateObject private var viewModel: ProjectFormViewModel

    init(viewModel: ProjectFormViewModel = ProjectFormViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationView {
            Form {
                acquisitionSection
                rentalSection
                financingSection
                resultSection
                actionSection
            }
            .navigationTitle("Mon projet")
            .alert(item: errorBinding) { message in
                Alert(
                    title: Text("Information"),
                    message: Text(message.value),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }

    private var acquisitionSection: some View {
        Section(header: Text("Acquisition")) {
            decimalField("Prix du bien", value: $viewModel.draft.purchasePrice)
            decimalField("Frais de notaire", value: $viewModel.draft.notaryFees)
            decimalField("Frais d'agence", value: $viewModel.draft.agencyCosts)
            decimalField("Travaux", value: $viewModel.draft.worksCost)
        }
    }

    private var rentalSection: some View {
        Section(header: Text("Revenus et charges")) {
            decimalField("Loyer mensuel", value: $viewModel.draft.monthlyRent)
            decimalField("Charges de copropriete", value: $viewModel.draft.monthlyCondominiumFees)
            decimalField("Taxe fonciere mensuelle", value: $viewModel.draft.monthlyPropertyTax)

            Picker("TMI", selection: $viewModel.draft.taxRate) {
                ForEach(viewModel.taxRates, id: \.self) { rate in
                    Text("\(rate, specifier: "%.0f")%").tag(rate)
                }
            }
        }
    }

    private var financingSection: some View {
        Section(header: Text("Financement")) {
            decimalField("Mensualite", value: $viewModel.draft.monthlyPayment)
        }
    }

    private var resultSection: some View {
        Section(header: Text("Indicateurs")) {
            if let project = viewModel.currentProject {
                resultRow("Prix total", value: project.costs.total, suffix: "EUR")
                resultRow("Rendement brut", value: project.result.grossYield, suffix: "%")
                resultRow("Rendement net", value: project.result.netYield, suffix: "%")
                resultRow("Rendement net-net", value: project.result.netNetYield, suffix: "%")
                resultRow("Cashflow mensuel", value: project.result.monthlyCashflow, suffix: "EUR")
            } else {
                Text("Aucun calcul effectue")
                    .foregroundColor(.secondary)
            }
        }
    }

    private var actionSection: some View {
        Section {
            Button("Calculer") {
                viewModel.calculate()
            }

            Button("Sauvegarder") {
                viewModel.save()
            }
            .disabled(viewModel.currentProject == nil)
        }
    }

    private func decimalField(_ title: String, value: Binding<Double>) -> some View {
        TextField(title, value: value, formatter: NumberFormatter.evalImmoDecimal)
            .evalImmoDecimalKeyboard()
    }

    private func resultRow(_ title: String, value: Double, suffix: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text("\(value, specifier: "%.2f") \(suffix)")
                .foregroundColor(.secondary)
        }
    }

    private var errorBinding: Binding<ProjectFormError?> {
        Binding(
            get: {
                guard let message = viewModel.errorMessage else { return nil }
                return ProjectFormError(value: message)
            },
            set: { _ in viewModel.errorMessage = nil }
        )
    }
}

private struct ProjectFormError: Identifiable {
    let id = UUID()
    let value: String
}

private extension NumberFormatter {
    static let evalImmoDecimal: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter
    }()
}

private extension View {
    @ViewBuilder
    func evalImmoDecimalKeyboard() -> some View {
        #if os(iOS)
        keyboardType(.decimalPad)
        #else
        self
        #endif
    }
}

struct ProjectFormView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectFormView()
    }
}
