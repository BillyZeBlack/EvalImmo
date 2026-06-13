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
    }

    @MainActor
    func calculate() {
        do {
            currentProject = try makeProjectSnapshot()
            errorMessage = nil
        } catch InvestmentCalculationError.invalidTotalPrice {
            currentProject = nil
            errorMessage = "Le prix total doit etre superieur a zero."
        } catch {
            currentProject = nil
            errorMessage = "Impossible de calculer les indicateurs."
        }
    }

    @MainActor
    func save() -> InvestmentProjectSnapshot? {
        do {
            let project = try makeProjectSnapshot()
            currentProject = project
            errorMessage = nil
            return project
        } catch InvestmentCalculationError.invalidTotalPrice {
            errorMessage = "Le projet doit etre calcule avec un prix total valide."
        } catch {
            errorMessage = "Impossible de sauvegarder le projet."
        }

        return nil
    }

    private func makeProjectSnapshot() throws -> InvestmentProjectSnapshot {
        let costs = try calculator.costs(
            price: draft.purchasePrice,
            notaryFees: draft.notaryFees,
            agencyCosts: draft.agencyCosts,
            works: draft.worksCost
        )
        let economicIndicators = try calculator.economicIndicators(
            monthlyRent: draft.monthlyRent,
            monthlyCondominiumFees: draft.monthlyCondominiumFees,
            monthlyPayment: draft.monthlyPayment,
            monthlyPropertyTax: draft.monthlyPropertyTax
        )
        let economicResult = try calculator.economicResult(
            costs: costs,
            indicators: economicIndicators
        )
        let indicators = try calculator.indicators(
            monthlyRent: draft.monthlyRent,
            monthlyCondominiumFees: draft.monthlyCondominiumFees,
            taxRate: draft.taxRate,
            monthlyPayment: draft.monthlyPayment,
            monthlyPropertyTax: draft.monthlyPropertyTax
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
