//
//  ProjectFormViewModel.swift
//  EvalImmo
//

import Foundation

final class ProjectFormViewModel: ObservableObject {
    @Published var draft: InvestmentProjectDraft
    @Published private(set) var currentProject: InvestmentProjectSnapshot?
    @Published var errorMessage: String?

    let taxRates: [Double] = [0, 11, 30, 41, 45]

    private let calculator: InvestmentCalculator

    init(
        draft: InvestmentProjectDraft = InvestmentProjectDraft(),
        calculator: InvestmentCalculator = InvestmentCalculator()
    ) {
        self.draft = draft
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
            annualOwnerInsurance: draft.annualOwnerInsurance
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
}
