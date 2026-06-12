//
//  InvestmentCosts.swift
//  EvalImmo
//

import Foundation

struct InvestmentCosts: Equatable {
    let price: Double
    let notaryFees: Double
    let agencyCosts: Double
    let works: Double

    var total: Double {
        price + notaryFees + agencyCosts + works
    }
}
