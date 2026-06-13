//
//  ProjectFormView.swift
//  EvalImmo
//

import SwiftUI

struct ProjectFormView: View {
    @StateObject private var viewModel: ProjectFormViewModel
    @FocusState private var focusedField: ProjectFormField?
    private let onSave: (InvestmentProjectSnapshot) -> Void

    init(
        viewModel: ProjectFormViewModel = ProjectFormViewModel(),
        onSave: @escaping (InvestmentProjectSnapshot) -> Void = { _ in }
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onSave = onSave
    }

    var body: some View {
        Form {
            projectTypeSection
            acquisitionSection
            rentalSection
            financingSection
            resultSection
        }
        .navigationTitle("Mon projet")
        .safeAreaInset(edge: .bottom) {
            actionBar
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()

                Button("OK") {
                    focusedField = nil
                }
            }
        }
        .alert(item: errorBinding) { message in
            Alert(
                title: Text("Information"),
                message: Text(message.value),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    private var projectTypeSection: some View {
        Section {
            Picker("Type de location", selection: rentalTypeBinding) {
                ForEach(RentalType.allCases) { rentalType in
                    Text(rentalType.title).tag(rentalType)
                }
            }
            .pickerStyle(.segmented)

            Picker(selection: taxRegimeBinding) {
                ForEach(viewModel.draft.rentalType.availableTaxRegimes) { taxRegime in
                    Text(taxRegime.title).tag(taxRegime)
                }
            } label: {
                LabeledFieldTitle(
                    title: "Regime fiscal",
                    detail: "Option associee au type de location."
                )
            }
        } header: {
            Label("Projet", systemImage: "building.2")
        }
    }

    private var acquisitionSection: some View {
        Section {
            decimalField(
                "Prix d'achat",
                detail: "Prix net vendeur du bien.",
                value: $viewModel.draft.purchasePrice,
                field: .purchasePrice
            )
            decimalField(
                "Frais de notaire",
                detail: "Montant estime a l'acquisition.",
                value: $viewModel.draft.notaryFees,
                field: .notaryFees
            )
            decimalField(
                "Frais d'agence",
                detail: "Honoraires inclus dans le projet.",
                value: $viewModel.draft.agencyCosts,
                field: .agencyCosts
            )
            decimalField(
                "Travaux",
                detail: "Budget travaux conserve dans le calcul.",
                value: $viewModel.draft.worksCost,
                field: .worksCost
            )
        } header: {
            Label("Acquisition", systemImage: "house")
        }
    }

    private var rentalSection: some View {
        Section {
            decimalField(
                "Loyer mensuel",
                detail: "Loyer hors charges.",
                value: $viewModel.draft.monthlyRent,
                field: .monthlyRent
            )
            decimalField(
                "Charges de copropriete",
                detail: "Montant mensuel.",
                value: $viewModel.draft.monthlyCondominiumFees,
                field: .monthlyCondominiumFees
            )
            decimalField(
                "Taxe fonciere",
                detail: "Equivalent mensuel.",
                value: $viewModel.draft.monthlyPropertyTax,
                field: .monthlyPropertyTax
            )

            Picker(selection: $viewModel.draft.taxRate) {
                ForEach(viewModel.taxRates, id: \.self) { rate in
                    Text("\(rate, specifier: "%.0f")%").tag(rate)
                }
            } label: {
                LabeledFieldTitle(
                    title: "Taux marginal d'imposition",
                    detail: "TMI utilise pour l'impot."
                )
            }
        } header: {
            Label("Revenus et charges", systemImage: "chart.line.uptrend.xyaxis")
        }
    }

    private var financingSection: some View {
        Section {
            decimalField(
                "Mensualite de credit",
                detail: "Credit assurance comprise si applicable.",
                value: $viewModel.draft.monthlyPayment,
                field: .monthlyPayment
            )
        } header: {
            Label("Financement", systemImage: "creditcard")
        }
    }

    private var resultSection: some View {
        Section {
            if let project = viewModel.currentProject {
                resultRow("Prix total", value: project.costs.total, suffix: "EUR")
                resultRow("Rendement brut", value: project.economicResult.grossYield, suffix: "%")
                resultRow("Rendement net avant impots", value: project.economicResult.netYieldBeforeTax, suffix: "%")
                resultRow("Cashflow avant impots", value: project.economicResult.monthlyCashflowBeforeTax, suffix: "EUR")
                resultRow("Rendement net-net", value: project.result.netNetYield, suffix: "%")
                resultRow("Cashflow apres impots", value: project.result.monthlyCashflow, suffix: "EUR")
            } else {
                ContentUnavailableView {
                    Label("Aucun calcul", systemImage: "function")
                }
            }
        } header: {
            Label("Indicateurs", systemImage: "percent")
        }
    }

    private var actionBar: some View {
        HStack(spacing: 12) {
            Button {
                viewModel.calculate()
            } label: {
                Label("Calculer", systemImage: "function")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)

            Button {
                guard let project = viewModel.save() else { return }
                onSave(project)
            } label: {
                Label("Sauvegarder", systemImage: "tray.and.arrow.down")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(viewModel.currentProject == nil)
        }
        .controlSize(.large)
        .padding()
        .background(.bar)
    }

    private func decimalField(
        _ title: String,
        detail: String,
        value: Binding<Double>,
        field: ProjectFormField
    ) -> some View {
        LabeledContent {
            HStack(spacing: 6) {
                TextField("0", value: value, formatter: NumberFormatter.evalImmoDecimal)
                    .multilineTextAlignment(.trailing)
                    .focused($focusedField, equals: field)
                    .evalImmoDecimalKeyboard()

                Text("EUR")
                    .foregroundStyle(.secondary)
            }
        } label: {
            LabeledFieldTitle(title: title, detail: detail)
        }
    }

    private func resultRow(_ title: String, value: Double, suffix: String) -> some View {
        LabeledContent(title) {
            Text("\(value, specifier: "%.2f") \(suffix)")
                .foregroundStyle(.secondary)
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

    private var rentalTypeBinding: Binding<RentalType> {
        Binding(
            get: { viewModel.draft.rentalType },
            set: { rentalType in
                viewModel.draft.rentalType = rentalType
                viewModel.draft.taxRegime = rentalType.defaultTaxRegime
            }
        )
    }

    private var taxRegimeBinding: Binding<TaxRegime> {
        Binding(
            get: {
                let taxRegime = viewModel.draft.taxRegime
                return taxRegime.rentalType == viewModel.draft.rentalType
                    ? taxRegime
                    : viewModel.draft.rentalType.defaultTaxRegime
            },
            set: { taxRegime in
                viewModel.draft.taxRegime = taxRegime
            }
        )
    }
}

private struct ProjectFormError: Identifiable {
    let id = UUID()
    let value: String
}

private enum ProjectFormField: Hashable {
    case purchasePrice
    case notaryFees
    case agencyCosts
    case worksCost
    case monthlyRent
    case monthlyCondominiumFees
    case monthlyPropertyTax
    case monthlyPayment
}

private struct LabeledFieldTitle: View {
    let title: String
    let detail: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
            Text(detail)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
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
