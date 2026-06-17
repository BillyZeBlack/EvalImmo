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
    private let editedProject: InvestmentProjectSnapshot?
    private let onSave: (InvestmentProjectSnapshot) -> Void

    init(
        viewModel: ProjectFormViewModel = ProjectFormViewModel(),
        editedProject: InvestmentProjectSnapshot? = nil,
        onSave: @escaping (InvestmentProjectSnapshot) -> Void = { _ in }
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.editedProject = editedProject
        self.onSave = onSave
    }

    init(
        project: InvestmentProjectSnapshot,
        onSave: @escaping (InvestmentProjectSnapshot) -> Void = { _ in }
    ) {
        _viewModel = StateObject(wrappedValue: ProjectFormViewModel(draft: project.draft, currentProject: project))
        self.editedProject = project
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
        .navigationTitle(isEditing ? "Modifier le projet" : "Mon projet")
        .scrollContentBackground(.hidden)
        .background(ProjectFormPalette.background)
        .tint(ProjectFormPalette.brand)
        .toolbarBackground(ProjectFormPalette.background, for: .navigationBar)
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

            Button(savePromptActionTitle) {
                savePendingProject()
            }
        } message: {
            Text(savePromptMessage)
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
        .listRowBackground(ProjectFormPalette.card)
    }

    private var acquisitionSection: some View {
        Section {
            decimalField(
                "Prix d'achat",
                detail: "Prix net-vendeur du bien.",
                value: $viewModel.draft.purchasePrice,
                field: .purchasePrice
            )
            decimalField(
                "Frais de notaire",
                detail: "Montant estimé à l'acquisition.",
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
                detail: "Budget travaux conservé dans le calcul.",
                value: $viewModel.draft.worksCost,
                field: .worksCost
            )
        } header: {
            ProjectSectionHeader(title: "Acquisition", systemImage: "house")
        }
        .listRowBackground(ProjectFormPalette.card)
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
                detail: "Part annuelle estimée sans loyer.",
                value: $viewModel.draft.vacancyRate,
                field: .vacancyRate,
                suffix: "%"
            )
            decimalField(
                "Charges de copropriété",
                detail: "Montant mensuel.",
                value: $viewModel.draft.monthlyCondominiumFees,
                field: .monthlyCondominiumFees
            )
            decimalField(
                "Taxe foncière",
                detail: "Montant annuel connu ou estimé.",
                value: $viewModel.draft.annualPropertyTax,
                field: .annualPropertyTax,
                suffix: "EUR/an"
            )
            decimalField(
                "Assurance PNO",
                detail: "Montant annuel estimé.",
                value: $viewModel.draft.annualOwnerInsurance,
                field: .annualOwnerInsurance,
                suffix: "EUR/an"
            )
            decimalField(
                "Comptable",
                detail: "Facturation annuelle.",
                value: $viewModel.draft.annualAccountantFees,
                field: .annualAccountantFees,
                suffix: "EUR/an"
            )

            Picker(selection: $viewModel.draft.taxRate) {
                ForEach(viewModel.taxRates, id: \.self) { rate in
                    Text("\(rate, specifier: "%.0f")%").tag(rate)
                }
            } label: {
                LabeledFieldTitle(
                    title: "Taux marginal d'imposition",
                    detail: "TMI utilisé pour l'impôt."
                )
            }
        } header: {
            ProjectSectionHeader(title: "Revenus et charges", systemImage: "chart.line.uptrend.xyaxis")
        }
        .listRowBackground(ProjectFormPalette.card)
    }

    private var financingSection: some View {
        Section {
            decimalField(
                "Mensualité de crédit",
                detail: "Crédit assurance comprise si applicable.",
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
        .listRowBackground(ProjectFormPalette.card)
    }

    private var resultSection: some View {
        Section {
            if let project = viewModel.currentProject {
                resultRow("Montant financé", value: project.costs.financedAmount, suffix: "EUR", style: .standard)
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
        .listRowBackground(ProjectFormPalette.card)
    }

    private var actionBar: some View {
        HStack(spacing: 12) {
            Button(action: viewModel.calculate) {
                Label("Analyser", systemImage: "chart.xyaxis.line")
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .buttonStyle(.borderedProminent)
            .tint(ProjectFormPalette.brand)

            Button {
                prepareProjectSave()
            } label: {
                Label(saveButtonTitle, systemImage: saveButtonIcon)
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .buttonStyle(.bordered)
            .disabled(viewModel.currentProject == nil)
        }
        .controlSize(.large)
        .buttonBorderShape(.roundedRectangle)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(ProjectFormPalette.barMaterial)
    }

    private func prepareProjectSave() {
        guard let project = viewModel.save() else { return }

        let projectToSave = projectForCurrentMode(from: project)
        projectPendingSave = projectToSave
        projectName = projectToSave.draft.name
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

    private var isEditing: Bool {
        editedProject != nil
    }

    private var saveButtonTitle: String {
        isEditing ? "Mettre à jour" : "Sauvegarder"
    }

    private var saveButtonIcon: String {
        isEditing ? "checkmark.circle" : "tray.and.arrow.down"
    }

    private var savePromptActionTitle: String {
        isEditing ? "Mettre à jour" : "Sauvegarder"
    }

    private var savePromptMessage: String {
        if isEditing {
            return "Vous pouvez ajuster le nom avant de mettre à jour ce projet."
        }

        return "Ajoutez un nom pour retrouver facilement ce projet dans la liste."
    }

    private func projectForCurrentMode(from project: InvestmentProjectSnapshot) -> InvestmentProjectSnapshot {
        guard let editedProject else { return project }

        return InvestmentProjectSnapshot(
            id: editedProject.id,
            createdAt: editedProject.createdAt,
            draft: project.draft,
            costs: project.costs,
            economicIndicators: project.economicIndicators,
            economicResult: project.economicResult,
            indicators: project.indicators,
            result: project.result
        )
    }

    private var taxRegimeRow: some View {
        HStack(alignment: .center, spacing: 12) {
            LabeledFieldTitle(
                title: "Régime fiscal",
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
            .accessibilityLabel("Régime fiscal")
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
            return ProjectFormPalette.brand
        case .signed:
            return value < 0 ? ProjectFormPalette.loss : ProjectFormPalette.gain
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
    case annualAccountantFees
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
            .foregroundStyle(ProjectFormPalette.brand)
    }
}

private struct LabeledFieldTitle: View {
    let title: String
    let detail: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.body)
                .foregroundStyle(ProjectFormPalette.ink)
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

private enum ProjectFormPalette {
    static let background = Color(red: 0.93, green: 0.97, blue: 0.96)
    static let card = Color.white
    static let brand = Color(red: 0.02, green: 0.29, blue: 0.24)
    static let ink = Color(red: 0.08, green: 0.13, blue: 0.14)
    static let gain = Color(red: 0.00, green: 0.48, blue: 0.38)
    static let loss = Color(red: 0.78, green: 0.18, blue: 0.16)
    static let barMaterial = Color.white.opacity(0.94)
}

struct ProjectFormView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectFormView()
    }
}
