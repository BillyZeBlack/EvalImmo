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
    private let simplifiedLMNPAmortizationDuration = 30.0

    func taxes(
        rentalType: RentalType,
        taxRegime: TaxRegime,
        annualRentalPrice: Double,
        annualCondominiumFees: Double,
        annualPropertyTax: Double,
        monthlyRent: Double,
        taxRate: Double,
        costs: InvestmentCosts?
    ) throws -> Double {
        switch (rentalType, taxRegime) {
        case (.bare, .microFoncier):
            return try microFoncierTaxes(
                annualRentalPrice: annualRentalPrice,
                taxRate: taxRate
            )
        case (.bare, .realFoncier):
            return realFoncierTaxes(
                annualRentalPrice: annualRentalPrice,
                annualCondominiumFees: annualCondominiumFees,
                annualPropertyTax: annualPropertyTax,
                taxRate: taxRate
            )
        case (.furnished, .microBIC):
            return try microBICTaxes(
                annualRentalPrice: annualRentalPrice,
                taxRate: taxRate
            )
        case (.furnished, .lmnpReal):
            return lmnpRealTaxes(
                annualRentalPrice: annualRentalPrice,
                annualCondominiumFees: annualCondominiumFees,
                annualPropertyTax: annualPropertyTax,
                taxRate: taxRate,
                costs: costs
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

    private func realFoncierTaxes(
        annualRentalPrice: Double,
        annualCondominiumFees: Double,
        annualPropertyTax: Double,
        taxRate: Double
    ) -> Double {
        let taxableIncome = max(
            annualRentalPrice - annualCondominiumFees - annualPropertyTax,
            0
        )
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

    private func lmnpRealTaxes(
        annualRentalPrice: Double,
        annualCondominiumFees: Double,
        annualPropertyTax: Double,
        taxRate: Double,
        costs: InvestmentCosts?
    ) -> Double {
        let annualAmortization = (costs?.total ?? 0) / simplifiedLMNPAmortizationDuration
        let taxableIncome = max(
            annualRentalPrice - annualCondominiumFees - annualPropertyTax - annualAmortization,
            0
        )
        return taxableIncome * ((taxRate + socialContributionsRate) / 100)
    }

    private func legacyTaxes(monthlyRent: Double, taxRate: Double) -> Double {
        (monthlyRent * 6) * ((taxRate + socialContributionsRate) / 100)
    }
}
