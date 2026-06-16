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
        works: Double = 0,
        downPayment: Double = 0
    ) throws -> InvestmentCosts {
        let costs = InvestmentCosts(
            price: price,
            notaryFees: notaryFees,
            agencyCosts: agencyCosts,
            works: works,
            downPayment: downPayment
        )

        try validate([costs.price, costs.notaryFees, costs.agencyCosts, costs.works, costs.downPayment])
        return costs
    }

    func indicators(
        rentalType: RentalType = .furnished,
        taxRegime: TaxRegime = .microBIC,
        monthlyRent: Double,
        vacancyRate: Double = 0,
        monthlyCondominiumFees: Double,
        taxRate: Double,
        monthlyPayment: Double,
        monthlyPropertyTax: Double,
        annualOwnerInsurance: Double = 0,
        costs: InvestmentCosts? = nil
    ) throws -> InvestmentIndicators {
        let economicIndicators = try economicIndicators(
            monthlyRent: monthlyRent,
            vacancyRate: vacancyRate,
            monthlyCondominiumFees: monthlyCondominiumFees,
            monthlyPayment: monthlyPayment,
            monthlyPropertyTax: monthlyPropertyTax,
            annualOwnerInsurance: annualOwnerInsurance
        )
        let indicators = InvestmentIndicators(
            annualRentalPrice: economicIndicators.annualRentalPrice,
            annualCondominiumFees: economicIndicators.annualCondominiumFees,
            taxes: try taxCalculator.taxes(
                rentalType: rentalType,
                taxRegime: taxRegime,
                annualRentalPrice: economicIndicators.annualRentalPrice,
                annualCondominiumFees: economicIndicators.annualCondominiumFees,
                annualPropertyTax: economicIndicators.annualPropertyTax,
                annualOwnerInsurance: economicIndicators.annualOwnerInsurance,
                monthlyRent: monthlyRent,
                taxRate: taxRate,
                costs: costs
            ),
            monthlyPayment: economicIndicators.monthlyPayment,
            annualPropertyTax: economicIndicators.annualPropertyTax,
            annualOwnerInsurance: economicIndicators.annualOwnerInsurance
        )

        try validate([
            indicators.annualRentalPrice,
            indicators.annualCondominiumFees,
            indicators.taxes,
            indicators.monthlyPayment,
            indicators.annualPropertyTax,
            indicators.annualOwnerInsurance
        ])
        return indicators
    }

    func economicIndicators(
        monthlyRent: Double,
        vacancyRate: Double = 0,
        monthlyCondominiumFees: Double,
        monthlyPayment: Double,
        monthlyPropertyTax: Double,
        annualOwnerInsurance: Double = 0
    ) throws -> InvestmentEconomicIndicators {
        guard (0...100).contains(vacancyRate) else {
            throw InvestmentCalculationError.invalidInput
        }

        let annualPotentialRentalPrice = monthlyRent * 12
        let annualRentalPrice = annualPotentialRentalPrice * (1 - (vacancyRate / 100))
        let indicators = InvestmentEconomicIndicators(
            annualRentalPrice: annualRentalPrice,
            annualCondominiumFees: monthlyCondominiumFees * 12,
            monthlyPayment: monthlyPayment,
            annualPropertyTax: monthlyPropertyTax * 12,
            annualOwnerInsurance: annualOwnerInsurance
        )

        try validate([
            indicators.annualRentalPrice,
            indicators.annualCondominiumFees,
            indicators.monthlyPayment,
            indicators.annualPropertyTax,
            indicators.annualOwnerInsurance
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
            (indicators.annualRentalPrice - (
                indicators.annualCondominiumFees
                + indicators.annualPropertyTax
                + indicators.annualOwnerInsurance
            ))
            / totalPrice
        ) * 100
        let monthlyCashflowBeforeTax = (indicators.annualRentalPrice / 12)
            - (
                (indicators.annualCondominiumFees / 12)
                + (indicators.annualPropertyTax / 12)
                + (indicators.annualOwnerInsurance / 12)
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
            annualPropertyTax: indicators.annualPropertyTax,
            annualOwnerInsurance: indicators.annualOwnerInsurance
        )
        let economicResult = try economicResult(costs: costs, indicators: economicIndicators)
        let totalPrice = costs.total
        let netNetYield = (
            (indicators.annualRentalPrice - (
                indicators.annualCondominiumFees
                + indicators.annualPropertyTax
                + indicators.annualOwnerInsurance
                + indicators.taxes
            ))
            / totalPrice
        ) * 100

        let monthlyCashflow = (indicators.annualRentalPrice / 12)
            - (
                (indicators.annualCondominiumFees / 12)
                + (indicators.annualPropertyTax / 12)
                + (indicators.annualOwnerInsurance / 12)
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
