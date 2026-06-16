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
    let downPayment: Double

    init(
        price: Double,
        notaryFees: Double,
        agencyCosts: Double = 0,
        works: Double = 0,
        downPayment: Double = 0
    ) {
        self.price = price
        self.notaryFees = notaryFees
        self.agencyCosts = agencyCosts
        self.works = works
        self.downPayment = downPayment
    }

    var total: Double {
        price + notaryFees + agencyCosts + works
    }

    var financedAmount: Double {
        max(total - downPayment, 0)
    }
}
