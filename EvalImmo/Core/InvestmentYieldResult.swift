//
//  InvestmentYieldResult.swift
//  EvalImmo
//

import Foundation

struct InvestmentYieldResult: Codable, Equatable {
    let grossYield: Double
    let netYield: Double
    let netNetYield: Double
    let monthlyCashflow: Double
}
