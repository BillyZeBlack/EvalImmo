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
    let indicators: InvestmentIndicators
    let result: InvestmentYieldResult

    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        draft: InvestmentProjectDraft,
        costs: InvestmentCosts,
        indicators: InvestmentIndicators,
        result: InvestmentYieldResult
    ) {
        self.id = id
        self.createdAt = createdAt
        self.draft = draft
        self.costs = costs
        self.indicators = indicators
        self.result = result
    }
}
