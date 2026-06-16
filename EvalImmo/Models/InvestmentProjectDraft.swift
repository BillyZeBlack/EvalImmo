//
//  InvestmentProjectDraft.swift
//  EvalImmo
//

import Foundation

struct InvestmentProjectDraft: Equatable {
    var rentalType: RentalType = .furnished
    var taxRegime: TaxRegime = .microBIC
    var purchasePrice: Double = 0
    var notaryFees: Double = 0
    var agencyCosts: Double = 0
    var worksCost: Double = 0
    var downPayment: Double = 0
    var monthlyRent: Double = 0
    var vacancyRate: Double = 0
    var monthlyCondominiumFees: Double = 0
    var annualPropertyTax: Double = 0
    var annualOwnerInsurance: Double = 0
    var monthlyPayment: Double = 0
    var taxRate: Double = 0
}
