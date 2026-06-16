//
//  ProjectFormView.swift
//  EvalImmo
//

import SwiftUI

struct ProjectFormView: View {
    @StateObject private var viewModel: ProjectFormViewModel
    @State private var projectPendingSave: InvestmentProjectSnapshot?
    @State private var projectName: String = ""
    @State private var isShowingSavePrompt = false
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
        .scrollContentBackground(.hidden)
        .background(Color(.systemGroupedBackground))
        .tint(.teal)
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
        .alert("Nom du projet", isPresented: $isShowingSavePrompt) {
            TextField("Ex. Studio centre-ville", text: $projectName)
                .textInputAutocapitalization(.words)

            Button("Annuler", role: .cancel) {
                projectPendingSave = nil
                projectName = ""
            }

            Button("Sauvegarder") {
                savePendingProject()
            }
        } message: {
            Text("Ajoute un nom pour retrouver facilement ce projet dans la liste.")
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
            .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))

            taxRegimeRow
        } header: {
            ProjectSectionHeader(title: "Projet", systemImage: "building.2")
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
            ProjectSectionHeader(title: "Acquisition", systemImage: "house")
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
                "Vacance locative",
                detail: "Part annuelle estimee sans loyer.",
                value: $viewModel.draft.vacancyRate,
                field: .vacancyRate,
                suffix: "%"
            )
            decimalField(
                "Charges de copropriete",
                detail: "Montant mensuel.",
                value: $viewModel.draft.monthlyCondominiumFees,
                field: .monthlyCondominiumFees
            )
            decimalField(
                "Taxe fonciere",
                detail: "Montant annuel connu ou estime.",
                value: $viewModel.draft.annualPropertyTax,
                field: .annualPropertyTax,
                suffix: "EUR/an"
            )
            decimalField(
                "Assurance PNO",
                detail: "Montant annuel estime.",
                value: $viewModel.draft.annualOwnerInsurance,
                field: .annualOwnerInsurance,
                suffix: "EUR/an"
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
            ProjectSectionHeader(title: "Revenus et charges", systemImage: "chart.line.uptrend.xyaxis")
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
            decimalField(
                "Apport",
                detail: "Montant financé sans emprunt.",
                value: $viewModel.draft.downPayment,
                field: .downPayment
            )
        } header: {
            ProjectSectionHeader(title: "Financement", systemImage: "creditcard")
        }
    }

    private var resultSection: some View {
        Section {
            if let project = viewModel.currentProject {
                resultRow("Montant finance", value: project.costs.financedAmount, suffix: "EUR", style: .standard)
                resultRow("Rendement brut", value: project.economicResult.grossYield, suffix: "%", style: .standard)
                resultRow("Rendement net", value: project.economicResult.netYieldBeforeTax, suffix: "%", style: .standard)
                resultRow("Rendement net-net", value: project.result.netNetYield, suffix: "%", style: .highlight)
                resultRow("Cashflow", value: project.result.monthlyCashflow, suffix: "EUR", style: .signed)
            } else {
                ContentUnavailableView {
                    Label("Aucun calcul", systemImage: "function")
                }
            }
        } header: {
            ProjectSectionHeader(title: "Indicateurs", systemImage: "percent")
        }
    }

    private var actionBar: some View {
        HStack(spacing: 12) {
            Button(action: viewModel.calculate) {
                Label("Calculer", systemImage: "function")
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .buttonStyle(.borderedProminent)
            .tint(.teal)

            Button {
                prepareProjectSave()
            } label: {
                Label("Sauvegarder", systemImage: "tray.and.arrow.down")
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .buttonStyle(.bordered)
            .disabled(viewModel.currentProject == nil)
        }
        .controlSize(.large)
        .buttonBorderShape(.roundedRectangle)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.regularMaterial)
    }

    private func prepareProjectSave() {
        guard let project = viewModel.save() else { return }

        projectPendingSave = project
        projectName = project.draft.name
        isShowingSavePrompt = true
    }

    private func savePendingProject() {
        guard let project = projectPendingSave else { return }

        var namedDraft = project.draft
        namedDraft.name = projectName.trimmingCharacters(in: .whitespacesAndNewlines)

        let namedProject = InvestmentProjectSnapshot(
            id: project.id,
            createdAt: project.createdAt,
            draft: namedDraft,
            costs: project.costs,
            economicIndicators: project.economicIndicators,
            economicResult: project.economicResult,
            indicators: project.indicators,
            result: project.result
        )

        projectPendingSave = nil
        projectName = ""
        onSave(namedProject)
    }

    private var taxRegimeRow: some View {
        HStack(alignment: .center, spacing: 12) {
            LabeledFieldTitle(
                title: "Regime fiscal",
                detail: viewModel.taxRegimeHint
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            .layoutPriority(1)

            Menu {
                ForEach(viewModel.availableTaxRegimes) { taxRegime in
                    Button {
                        viewModel.selectTaxRegime(taxRegime)
                    } label: {
                        if taxRegime == taxRegimeBinding.wrappedValue {
                            Label(taxRegime.title, systemImage: "checkmark")
                        } else {
                            Text(taxRegime.title)
                        }
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Text(taxRegimeBinding.wrappedValue.title)
                        .lineLimit(1)

                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption2.weight(.semibold))
                }
                .foregroundStyle(.secondary)
                .font(.body)
                .frame(minWidth: 112, alignment: .trailing)
            }
            .accessibilityLabel("Regime fiscal")
            .accessibilityValue(taxRegimeBinding.wrappedValue.title)
        }
    }

    private func decimalField(
        _ title: String,
        detail: String,
        value: Binding<Double>,
        field: ProjectFormField,
        suffix: String = "EUR"
    ) -> some View {
        LabeledContent {
            HStack(spacing: 6) {
                TextField("0", text: decimalTextBinding(value))
                    .multilineTextAlignment(.trailing)
                    .font(.body.monospacedDigit())
                    .focused($focusedField, equals: field)
                    .evalImmoDecimalKeyboard()

                Text(suffix)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
        } label: {
            LabeledFieldTitle(title: title, detail: detail)
        }
    }

    private func decimalTextBinding(_ value: Binding<Double>) -> Binding<String> {
        Binding(
            get: {
                guard value.wrappedValue != 0 else { return "" }
                return NumberFormatter.evalImmoDecimal.string(from: NSNumber(value: value.wrappedValue)) ?? ""
            },
            set: { newValue in
                let normalizedValue = newValue.replacingOccurrences(of: ",", with: ".")

                guard !normalizedValue.isEmpty else {
                    value.wrappedValue = 0
                    return
                }

                guard let doubleValue = Double(normalizedValue) else { return }
                value.wrappedValue = doubleValue
            }
        )
    }

    private func resultRow(_ title: String, value: Double, suffix: String, style: ProjectResultRowStyle) -> some View {
        LabeledContent(title) {
            Text("\(value, specifier: "%.2f") \(suffix)")
                .font(style == .highlight ? .headline.monospacedDigit() : .body.monospacedDigit())
                .foregroundStyle(resultForegroundStyle(value: value, style: style))
        }
    }

    private func resultForegroundStyle(value: Double, style: ProjectResultRowStyle) -> Color {
        switch style {
        case .standard:
            return .secondary
        case .highlight:
            return .teal
        case .signed:
            return value < 0 ? .red : .green
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
                viewModel.selectRentalType(rentalType)
            }
        )
    }

    private var taxRegimeBinding: Binding<TaxRegime> {
        Binding(
            get: {
                let taxRegime = viewModel.draft.taxRegime
                return viewModel.availableTaxRegimes.contains(taxRegime)
                    ? taxRegime
                    : viewModel.draft.rentalType.defaultTaxRegime
            },
            set: { taxRegime in
                viewModel.selectTaxRegime(taxRegime)
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
    case vacancyRate
    case monthlyCondominiumFees
    case annualPropertyTax
    case annualOwnerInsurance
    case monthlyPayment
    case downPayment
}

private enum ProjectResultRowStyle {
    case standard
    case highlight
    case signed
}

private struct ProjectSectionHeader: View {
    let title: String
    let systemImage: String

    var body: some View {
        Label(title, systemImage: systemImage)
            .font(.footnote)
            .bold()
            .foregroundStyle(.secondary)
    }
}

private struct LabeledFieldTitle: View {
    let title: String
    let detail: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.body)
            Text(detail)
                .font(.footnote)
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
