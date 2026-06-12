//
//  InvestmentCalculator.swift
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

struct InvestmentIndicators: Equatable {
    let annualRentalPrice: Double
    let annualCondominiumFees: Double
    let taxes: Double
    let monthlyPayment: Double
    let annualPropertyTax: Double
}

struct InvestmentYieldResult: Equatable {
    let grossYield: Double
    let netYield: Double
    let netNetYield: Double
    let monthlyCashflow: Double
}

enum InvestmentCalculationError: Error, Equatable {
    case invalidTotalPrice
    case invalidInput
}

struct InvestmentCalculator {
    func costs(
        price: Double,
        notaryFees: Double,
        agencyCosts: Double = 0,
        works: Double = 0
    ) throws -> InvestmentCosts {
        let costs = InvestmentCosts(
            price: price,
            notaryFees: notaryFees,
            agencyCosts: agencyCosts,
            works: works
        )

        try validate([costs.price, costs.notaryFees, costs.agencyCosts, costs.works])
        return costs
    }

    func indicators(
        monthlyRent: Double,
        monthlyCondominiumFees: Double,
        taxRate: Double,
        monthlyPayment: Double,
        monthlyPropertyTax: Double
    ) throws -> InvestmentIndicators {
        let indicators = InvestmentIndicators(
            annualRentalPrice: monthlyRent * 12,
            annualCondominiumFees: monthlyCondominiumFees * 12,
            taxes: (monthlyRent * 6) * ((taxRate + 17.2) / 100),
            monthlyPayment: monthlyPayment,
            annualPropertyTax: monthlyPropertyTax * 12
        )

        try validate([
            indicators.annualRentalPrice,
            indicators.annualCondominiumFees,
            indicators.taxes,
            indicators.monthlyPayment,
            indicators.annualPropertyTax
        ])
        return indicators
    }

    func yields(costs: InvestmentCosts, indicators: InvestmentIndicators) throws -> InvestmentYieldResult {
        let totalPrice = costs.total

        guard totalPrice > 0 else {
            throw InvestmentCalculationError.invalidTotalPrice
        }

        let grossYield = (indicators.annualRentalPrice / totalPrice) * 100
        let netYield = (
            (indicators.annualRentalPrice - (indicators.annualCondominiumFees + indicators.annualPropertyTax))
            / totalPrice
        ) * 100
        let netNetYield = (
            (indicators.annualRentalPrice - (
                indicators.annualCondominiumFees
                + indicators.annualPropertyTax
                + indicators.taxes
            ))
            / totalPrice
        ) * 100

        let monthlyCashflow = (indicators.annualRentalPrice / 12)
            - (
                (indicators.annualCondominiumFees / 12)
                + (indicators.annualPropertyTax / 12)
                + (indicators.taxes / 12)
                + indicators.monthlyPayment
            )

        let result = InvestmentYieldResult(
            grossYield: grossYield,
            netYield: netYield,
            netNetYield: netNetYield,
            monthlyCashflow: monthlyCashflow
        )

        try validate([result.grossYield, result.netYield, result.netNetYield, result.monthlyCashflow])
        return result
    }

    private func validate(_ values: [Double]) throws {
        guard values.allSatisfy({ $0.isFinite }) else {
            throw InvestmentCalculationError.invalidInput
        }
    }
}
