//
//  InvestmentTaxCalculator.swift
//  EvalImmo
//

import Foundation

struct InvestmentTaxCalculator {
    private let socialContributionsRate = 17.2
    private let microFoncierAllowanceRate = 0.30
    private let microFoncierAnnualRevenueLimit = 15_000.0
    private let microBICAllowanceRate = 0.50
    private let microBICMinimumAllowance = 305.0
    private let microBICAnnualRevenueLimit = 83_600.0

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
        case (.furnished, .microBIC):
            return try microBICTaxes(
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

    private func microBICTaxes(
        annualRentalPrice: Double,
        taxRate: Double
    ) throws -> Double {
        guard annualRentalPrice <= microBICAnnualRevenueLimit else {
            throw InvestmentCalculationError.ineligibleTaxRegime
        }

        let allowance = max(
            annualRentalPrice * microBICAllowanceRate,
            min(microBICMinimumAllowance, annualRentalPrice)
        )
        let taxableIncome = max(annualRentalPrice - allowance, 0)
        return taxableIncome * ((taxRate + socialContributionsRate) / 100)
    }

    private func legacyTaxes(monthlyRent: Double, taxRate: Double) -> Double {
        (monthlyRent * 6) * ((taxRate + socialContributionsRate) / 100)
    }
}
