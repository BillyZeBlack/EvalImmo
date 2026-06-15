//
//  InvestmentTaxCalculator.swift
//  EvalImmo
//

import Foundation

struct InvestmentTaxCalculator {
    private let socialContributionsRate = 17.2
    private let microFoncierAllowanceRate = 0.30
    private let microFoncierAnnualRevenueLimit = 15_000.0

    func taxes(
        rentalType: RentalType,
        taxRegime: TaxRegime,
        annualRentalPrice: Double,
        monthlyRent: Double,
        taxRate: Double
    ) throws -> Double {
        switch (rentalType, taxRegime) {
        case (.bare, .microFoncier):
            return try microFoncierTaxes(
                annualRentalPrice: annualRentalPrice,
                taxRate: taxRate
            )
        default:
            return legacyTaxes(monthlyRent: monthlyRent, taxRate: taxRate)
        }
    }

    private func microFoncierTaxes(
        annualRentalPrice: Double,
        taxRate: Double
    ) throws -> Double {
        guard annualRentalPrice <= microFoncierAnnualRevenueLimit else {
            throw InvestmentCalculationError.ineligibleTaxRegime
        }

        let taxableIncome = annualRentalPrice * (1 - microFoncierAllowanceRate)
        return taxableIncome * ((taxRate + socialContributionsRate) / 100)
    }

    private func legacyTaxes(monthlyRent: Double, taxRate: Double) -> Double {
        (monthlyRent * 6) * ((taxRate + socialContributionsRate) / 100)
    }
}
