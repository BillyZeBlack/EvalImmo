//
//  EvalImmoTests.swift
//  EvalImmoTests
//
//  Created by williams saadi on 22/03/2021.
//

import XCTest
@testable import EvalImmo

class EvalImmoTests: XCTestCase {
    private let calculator = InvestmentCalculator()

    func testInvestmentCalculatorComputesCommonEconomicResult() throws {
        let costs = try calculator.costs(
            price: 100_000,
            notaryFees: 8_000,
            agencyCosts: 5_000,
            works: 7_000
        )
        let indicators = try calculator.economicIndicators(
            monthlyRent: 800,
            monthlyCondominiumFees: 100,
            monthlyPayment: 500,
            monthlyPropertyTax: 50
        )

        let result = try calculator.economicResult(costs: costs, indicators: indicators)

        XCTAssertEqual(indicators.annualRentalPrice, 9_600)
        XCTAssertEqual(indicators.annualCondominiumFees, 1_200)
        XCTAssertEqual(indicators.annualPropertyTax, 600)
        XCTAssertEqual(result.grossYield, 8, accuracy: 0.0001)
        XCTAssertEqual(result.netYieldBeforeTax, 6.5, accuracy: 0.0001)
        XCTAssertEqual(result.monthlyCashflowBeforeTax, 150, accuracy: 0.0001)
    }

    func testInvestmentCalculatorPreservesCurrentIndicatorRules() throws {
        let indicators = try calculator.indicators(
            monthlyRent: 800,
            monthlyCondominiumFees: 100,
            taxRate: 30,
            monthlyPayment: 500,
            monthlyPropertyTax: 50
        )

        XCTAssertEqual(indicators.annualRentalPrice, 9_600)
        XCTAssertEqual(indicators.annualCondominiumFees, 1_200)
        XCTAssertEqual(indicators.taxes, 2_265.6, accuracy: 0.0001)
        XCTAssertEqual(indicators.monthlyPayment, 500)
        XCTAssertEqual(indicators.annualPropertyTax, 600)
    }

    func testInvestmentCalculatorPreservesCurrentYieldRules() throws {
        let costs = try calculator.costs(
            price: 100_000,
            notaryFees: 8_000,
            agencyCosts: 5_000,
            works: 7_000
        )
        let indicators = try calculator.indicators(
            monthlyRent: 800,
            monthlyCondominiumFees: 100,
            taxRate: 30,
            monthlyPayment: 500,
            monthlyPropertyTax: 50
        )

        let result = try calculator.yields(costs: costs, indicators: indicators)

        XCTAssertEqual(costs.total, 120_000)
        XCTAssertEqual(result.grossYield, 8, accuracy: 0.0001)
        XCTAssertEqual(result.netYield, 6.5, accuracy: 0.0001)
        XCTAssertEqual(result.netNetYield, 4.612, accuracy: 0.0001)
        XCTAssertEqual(result.monthlyCashflow, -38.8, accuracy: 0.0001)
    }

    func testInvestmentCalculatorRejectsInvalidTotalPrice() throws {
        let costs = try calculator.costs(price: 0, notaryFees: 0)
        let indicators = try calculator.indicators(
            monthlyRent: 800,
            monthlyCondominiumFees: 100,
            taxRate: 30,
            monthlyPayment: 500,
            monthlyPropertyTax: 50
        )

        XCTAssertThrowsError(try calculator.yields(costs: costs, indicators: indicators)) { error in
            XCTAssertEqual(error as? InvestmentCalculationError, .invalidTotalPrice)
        }
    }

    func testInvestmentCalculatorDoesNotAccumulateTotalPriceBetweenCalculations() throws {
        let costs = try calculator.costs(
            price: 100_000,
            notaryFees: 8_000,
            agencyCosts: 5_000,
            works: 7_000
        )

        XCTAssertEqual(costs.total, 120_000)
        XCTAssertEqual(costs.total, 120_000)
    }

    @MainActor
    func testProjectFormViewModelCalculatesCurrentProject() {
        let viewModel = ProjectFormViewModel(
            draft: InvestmentProjectDraft(
                purchasePrice: 100_000,
                notaryFees: 8_000,
                agencyCosts: 5_000,
                worksCost: 7_000,
                monthlyRent: 800,
                monthlyCondominiumFees: 100,
                monthlyPropertyTax: 50,
                monthlyPayment: 500,
                taxRate: 30
            )
        )

        viewModel.calculate()

        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.currentProject?.costs.total, 120_000)
        XCTAssertEqual(viewModel.currentProject?.economicResult.monthlyCashflowBeforeTax ?? 0, 150, accuracy: 0.0001)
        XCTAssertEqual(viewModel.currentProject?.result.grossYield ?? 0, 8, accuracy: 0.0001)
    }
}
