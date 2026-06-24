//
//  ProjectFormViewModel.swift
//  EvalImmo
//

import Foundation

final class ProjectFormViewModel: ObservableObject {
    @Published var draft: InvestmentProjectDraft
    @Published private(set) var currentProject: InvestmentProjectSnapshot?
    @Published var errorMessage: String?
    @Published private(set) var hasSelectedTaxRate: Bool

    let taxRates: [Double] = [0, 11, 30, 41, 45]

    private let calculator: InvestmentCalculator

    init(
        draft: InvestmentProjectDraft = InvestmentProjectDraft(),
        currentProject: InvestmentProjectSnapshot? = nil,
        calculator: InvestmentCalculator = InvestmentCalculator()
    ) {
        self.draft = draft
        self.currentProject = currentProject
        self.hasSelectedTaxRate = currentProject != nil || draft.taxRate != 0
        self.calculator = calculator
        normalizeTaxRegime()
    }

    var availableTaxRegimes: [TaxRegime] {
        draft.rentalType.supportedTaxRegimes
    }

    var taxRegimeHint: String {
        switch draft.taxRegime {
        case .microFoncier:
            return "Abattement forfaitaire de 30% sur les revenus locatifs."
        case .microBIC:
            return "Abattement forfaitaire de 50% sur les recettes meublées."
        case .realFoncier:
            return "Charges de copropriété et taxe fonciere déduites des loyers."
        case .lmnpReal:
            return "Charges déduites avec amortissement simplifié sur 30 ans."
        }
    }

    var taxRateSelection: Double? {
        hasSelectedTaxRate ? draft.taxRate : nil
    }

    @MainActor
    func selectRentalType(_ rentalType: RentalType) {
        draft.rentalType = rentalType
        normalizeTaxRegime()
        clearCurrentCalculation()
    }

    @MainActor
    func selectTaxRegime(_ taxRegime: TaxRegime) {
        guard availableTaxRegimes.contains(taxRegime) else { return }

        draft.taxRegime = taxRegime
        clearCurrentCalculation()
    }

    @MainActor
    func selectTaxRate(_ taxRate: Double?) {
        guard let taxRate else {
            draft.taxRate = 0
            hasSelectedTaxRate = false
            clearCurrentCalculation()
            return
        }

        guard taxRates.contains(taxRate) else { return }

        draft.taxRate = taxRate
        hasSelectedTaxRate = true
        clearCurrentCalculation()
    }

    @MainActor
    func calculate() {
        do {
            normalizeTaxRegime()
            currentProject = try makeProjectSnapshot()
            errorMessage = nil
        } catch InvestmentCalculationError.invalidTotalPrice {
            currentProject = nil
            errorMessage = "Le prix total doit etre superieur a zero."
        } catch InvestmentCalculationError.ineligibleTaxRegime {
            currentProject = nil
            errorMessage = "Le regime fiscal choisi n'est pas compatible avec les revenus annuels saisis."
        } catch let error as ProjectFormValidationError {
            currentProject = nil
            errorMessage = error.message
        } catch {
            currentProject = nil
            errorMessage = "Impossible de calculer les indicateurs."
        }
    }

    @MainActor
    func save() -> InvestmentProjectSnapshot? {
        do {
            normalizeTaxRegime()
            let project = try makeProjectSnapshot()
            currentProject = project
            errorMessage = nil
            return project
        } catch InvestmentCalculationError.invalidTotalPrice {
            errorMessage = "Le projet doit etre calcule avec un prix total valide."
        } catch InvestmentCalculationError.ineligibleTaxRegime {
            errorMessage = "Le regime fiscal choisi n'est pas compatible avec les revenus annuels saisis."
        } catch let error as ProjectFormValidationError {
            errorMessage = error.message
        } catch {
            errorMessage = "Impossible de sauvegarder le projet."
        }

        return nil
    }

    private func normalizeTaxRegime() {
        guard availableTaxRegimes.contains(draft.taxRegime) else {
            draft.taxRegime = draft.rentalType.defaultTaxRegime
            return
        }
    }

    private func clearCurrentCalculation() {
        currentProject = nil
        errorMessage = nil
    }

    private func makeProjectSnapshot() throws -> InvestmentProjectSnapshot {
        try validateDraft()

        let monthlyPropertyTax = draft.annualPropertyTax / 12
        let costs = try calculator.costs(
            price: draft.purchasePrice,
            notaryFees: draft.notaryFees,
            agencyCosts: draft.agencyCosts,
            works: draft.worksCost,
            downPayment: draft.downPayment
        )
        let economicIndicators = try calculator.economicIndicators(
            monthlyRent: draft.monthlyRent,
            vacancyRate: draft.vacancyRate,
            monthlyCondominiumFees: draft.monthlyCondominiumFees,
            monthlyPayment: draft.monthlyPayment,
            monthlyPropertyTax: monthlyPropertyTax,
            annualOwnerInsurance: draft.annualOwnerInsurance,
            annualAccountantFees: draft.annualAccountantFees
        )
        let economicResult = try calculator.economicResult(
            costs: costs,
            indicators: economicIndicators
        )
        let indicators = try calculator.indicators(
            rentalType: draft.rentalType,
            taxRegime: draft.taxRegime,
            monthlyRent: draft.monthlyRent,
            vacancyRate: draft.vacancyRate,
            monthlyCondominiumFees: draft.monthlyCondominiumFees,
            taxRate: draft.taxRate,
            monthlyPayment: draft.monthlyPayment,
            monthlyPropertyTax: monthlyPropertyTax,
            annualOwnerInsurance: draft.annualOwnerInsurance,
            annualAccountantFees: draft.annualAccountantFees,
            costs: costs
        )
        let result = try calculator.yields(costs: costs, indicators: indicators)

        return InvestmentProjectSnapshot(
            draft: draft,
            costs: costs,
            economicIndicators: economicIndicators,
            economicResult: economicResult,
            indicators: indicators,
            result: result
        )
    }

    private func validateDraft() throws {
        if let validationError = ProjectFormValidationError.first(for: draft, hasSelectedTaxRate: hasSelectedTaxRate) {
            throw validationError
        }
    }
}

private enum ProjectFormValidationError: Error {
    case negativeAmount
    case missingNotaryFees
    case missingMonthlyRent
    case missingPropertyTax
    case missingTaxRate

    static func first(for draft: InvestmentProjectDraft, hasSelectedTaxRate: Bool) -> ProjectFormValidationError? {
        let amounts = [
            draft.purchasePrice,
            draft.notaryFees,
            draft.agencyCosts,
            draft.worksCost,
            draft.downPayment,
            draft.monthlyRent,
            draft.monthlyCondominiumFees,
            draft.annualPropertyTax,
            draft.annualOwnerInsurance,
            draft.annualAccountantFees,
            draft.monthlyPayment
        ]

        guard amounts.allSatisfy({ $0 >= 0 }) else {
            return .negativeAmount
        }

        guard draft.notaryFees > 0 else {
            return .missingNotaryFees
        }

        guard draft.monthlyRent > 0 else {
            return .missingMonthlyRent
        }

        guard draft.annualPropertyTax > 0 else {
            return .missingPropertyTax
        }

        guard hasSelectedTaxRate else {
            return .missingTaxRate
        }

        return nil
    }

    var message: String {
        switch self {
        case .negativeAmount:
            return "Les montants saisis doivent etre superieurs ou egaux a zero."
        case .missingNotaryFees:
            return "Les frais de notaire sont obligatoires et doivent etre superieurs a zero."
        case .missingMonthlyRent:
            return "Le loyer mensuel est obligatoire et doit etre superieur a zero."
        case .missingPropertyTax:
            return "La taxe fonciere est obligatoire et doit etre superieure a zero."
        case .missingTaxRate:
            return "Selectionnez un taux marginal d'imposition. Le taux 0% est possible s'il correspond a votre situation."
        }
    }
}
