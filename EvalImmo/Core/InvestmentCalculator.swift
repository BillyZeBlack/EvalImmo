//
//  InvestmentCalculator.swift
//  EvalImmo
//

import Foundation

enum InvestmentCalculationError: Error, Equatable {
    case invalidTotalPrice
    case invalidInput
    case ineligibleTaxRegime
}

struct InvestmentCalculator {
    private let taxCalculator = InvestmentTaxCalculator()

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
        rentalType: RentalType = .furnished,
        taxRegime: TaxRegime = .microBIC,
        monthlyRent: Double,
        monthlyCondominiumFees: Double,
        taxRate: Double,
        monthlyPayment: Double,
        monthlyPropertyTax: Double
    ) throws -> InvestmentIndicators {
        let economicIndicators = try economicIndicators(
            monthlyRent: monthlyRent,
            monthlyCondominiumFees: monthlyCondominiumFees,
            monthlyPayment: monthlyPayment,
            monthlyPropertyTax: monthlyPropertyTax
        )
        let indicators = InvestmentIndicators(
            annualRentalPrice: economicIndicators.annualRentalPrice,
            annualCondominiumFees: economicIndicators.annualCondominiumFees,
            taxes: try taxCalculator.taxes(
                rentalType: rentalType,
                taxRegime: taxRegime,
                annualRentalPrice: economicIndicators.annualRentalPrice,
                monthlyRent: monthlyRent,
                taxRate: taxRate
            ),
            monthlyPayment: economicIndicators.monthlyPayment,
            annualPropertyTax: economicIndicators.annualPropertyTax
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

    func economicIndicators(
        monthlyRent: Double,
        monthlyCondominiumFees: Double,
        monthlyPayment: Double,
        monthlyPropertyTax: Double
    ) throws -> InvestmentEconomicIndicators {
        let indicators = InvestmentEconomicIndicators(
            annualRentalPrice: monthlyRent * 12,
            annualCondominiumFees: monthlyCondominiumFees * 12,
            monthlyPayment: monthlyPayment,
            annualPropertyTax: monthlyPropertyTax * 12
        )

        try validate([
            indicators.annualRentalPrice,
            indicators.annualCondominiumFees,
            indicators.monthlyPayment,
            indicators.annualPropertyTax
        ])
        return indicators
    }

    func economicResult(
        costs: InvestmentCosts,
        indicators: InvestmentEconomicIndicators
    ) throws -> InvestmentEconomicResult {
        let totalPrice = costs.total

        guard totalPrice > 0 else {
            throw InvestmentCalculationError.invalidTotalPrice
        }

        let grossYield = (indicators.annualRentalPrice / totalPrice) * 100
        let netYieldBeforeTax = (
            (indicators.annualRentalPrice - (indicators.annualCondominiumFees + indicators.annualPropertyTax))
            / totalPrice
        ) * 100
        let monthlyCashflowBeforeTax = (indicators.annualRentalPrice / 12)
            - (
                (indicators.annualCondominiumFees / 12)
                + (indicators.annualPropertyTax / 12)
                + indicators.monthlyPayment
            )

        let result = InvestmentEconomicResult(
            grossYield: grossYield,
            netYieldBeforeTax: netYieldBeforeTax,
            monthlyCashflowBeforeTax: monthlyCashflowBeforeTax
        )

        try validate([result.grossYield, result.netYieldBeforeTax, result.monthlyCashflowBeforeTax])
        return result
    }

    func yields(costs: InvestmentCosts, indicators: InvestmentIndicators) throws -> InvestmentYieldResult {
        let economicIndicators = InvestmentEconomicIndicators(
            annualRentalPrice: indicators.annualRentalPrice,
            annualCondominiumFees: indicators.annualCondominiumFees,
            monthlyPayment: indicators.monthlyPayment,
            annualPropertyTax: indicators.annualPropertyTax
        )
        let economicResult = try economicResult(costs: costs, indicators: economicIndicators)
        let totalPrice = costs.total
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
            grossYield: economicResult.grossYield,
            netYield: economicResult.netYieldBeforeTax,
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
