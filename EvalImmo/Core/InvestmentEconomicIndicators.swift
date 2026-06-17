//
//  InvestmentEconomicIndicators.swift
//  EvalImmo
//

import Foundation

struct InvestmentEconomicIndicators: Codable, Equatable {
    let annualRentalPrice: Double
    let annualCondominiumFees: Double
    let monthlyPayment: Double
    let annualPropertyTax: Double
    let annualOwnerInsurance: Double
}
