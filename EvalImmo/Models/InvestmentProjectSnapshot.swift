//
//  InvestmentProjectSnapshot.swift
//  EvalImmo
//

import Foundation

struct InvestmentProjectSnapshot: Identifiable, Equatable {
    let id: UUID
    let createdAt: Date
    let draft: InvestmentProjectDraft
    let costs: InvestmentCosts
    let economicIndicators: InvestmentEconomicIndicators
    let economicResult: InvestmentEconomicResult
    let indicators: InvestmentIndicators
    let result: InvestmentYieldResult

    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        draft: InvestmentProjectDraft,
        costs: InvestmentCosts,
        economicIndicators: InvestmentEconomicIndicators,
        economicResult: InvestmentEconomicResult,
        indicators: InvestmentIndicators,
        result: InvestmentYieldResult
    ) {
        self.id = id
        self.createdAt = createdAt
        self.draft = draft
        self.costs = costs
        self.economicIndicators = economicIndicators
        self.economicResult = economicResult
        self.indicators = indicators
        self.result = result
    }
}
