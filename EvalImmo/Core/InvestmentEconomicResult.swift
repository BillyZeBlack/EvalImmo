//
//  InvestmentEconomicResult.swift
//  EvalImmo
//

import Foundation

struct InvestmentEconomicResult: Codable, Equatable {
    let grossYield: Double
    let netYieldBeforeTax: Double
    let monthlyCashflowBeforeTax: Double
}
