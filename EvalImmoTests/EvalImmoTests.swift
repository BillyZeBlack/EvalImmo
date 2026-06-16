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

    @MainActor
    func testReferenceBareMicroFoncierProjectSnapshot() {
        let viewModel = ProjectFormViewModel(
            draft: InvestmentProjectDraft(
                rentalType: .bare,
                taxRegime: .microFoncier,
                purchasePrice: 200_000,
                notaryFees: 15_000,
                agencyCosts: 8_000,
                worksCost: 0,
                monthlyRent: 1_000,
                monthlyCondominiumFees: 120,
                annualPropertyTax: 1_200,
                monthlyPayment: 900,
                taxRate: 11
            )
        )

        let project = viewModel.save()

        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(project?.costs.total ?? 0, 223_000, accuracy: 0.0001)
        XCTAssertEqual(project?.economicIndicators.annualRentalPrice ?? 0, 12_000, accuracy: 0.0001)
        XCTAssertEqual(project?.economicIndicators.annualCondominiumFees ?? 0, 1_440, accuracy: 0.0001)
        XCTAssertEqual(project?.economicIndicators.annualPropertyTax ?? 0, 1_200, accuracy: 0.0001)
        XCTAssertEqual(project?.economicResult.grossYield ?? 0, 5.3812, accuracy: 0.0001)
        XCTAssertEqual(project?.economicResult.netYieldBeforeTax ?? 0, 4.1973, accuracy: 0.0001)
        XCTAssertEqual(project?.economicResult.monthlyCashflowBeforeTax ?? 0, -120, accuracy: 0.0001)
        XCTAssertEqual(project?.indicators.taxes ?? 0, 2_368.8, accuracy: 0.0001)
        XCTAssertEqual(project?.result.netNetYield ?? 0, 3.1351, accuracy: 0.0001)
        XCTAssertEqual(project?.result.monthlyCashflow ?? 0, -317.4, accuracy: 0.0001)
    }

    @MainActor
    func testReferenceFurnishedMicroBICProjectSnapshot() {
        let viewModel = ProjectFormViewModel(
            draft: InvestmentProjectDraft(
                rentalType: .furnished,
                taxRegime: .microBIC,
                purchasePrice: 150_000,
                notaryFees: 12_000,
                agencyCosts: 5_000,
                worksCost: 8_000,
                monthlyRent: 850,
                monthlyCondominiumFees: 90,
                annualPropertyTax: 840,
                monthlyPayment: 650,
                taxRate: 30
            )
        )

        let project = viewModel.save()

        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(project?.costs.total ?? 0, 175_000, accuracy: 0.0001)
        XCTAssertEqual(project?.economicIndicators.annualRentalPrice ?? 0, 10_200, accuracy: 0.0001)
        XCTAssertEqual(project?.economicIndicators.annualCondominiumFees ?? 0, 1_080, accuracy: 0.0001)
        XCTAssertEqual(project?.economicIndicators.annualPropertyTax ?? 0, 840, accuracy: 0.0001)
        XCTAssertEqual(project?.economicResult.grossYield ?? 0, 5.8286, accuracy: 0.0001)
        XCTAssertEqual(project?.economicResult.netYieldBeforeTax ?? 0, 4.7314, accuracy: 0.0001)
        XCTAssertEqual(project?.economicResult.monthlyCashflowBeforeTax ?? 0, 40, accuracy: 0.0001)
        XCTAssertEqual(project?.indicators.taxes ?? 0, 2_407.2, accuracy: 0.0001)
        XCTAssertEqual(project?.result.netNetYield ?? 0, 3.3559, accuracy: 0.0001)
        XCTAssertEqual(project?.result.monthlyCashflow ?? 0, -160.6, accuracy: 0.0001)
    }

    @MainActor
    func testProjectFormViewModelFiltersSupportedTaxRegimesByRentalType() {
        let viewModel = ProjectFormViewModel()

        XCTAssertEqual(viewModel.draft.rentalType, .furnished)
        XCTAssertEqual(viewModel.availableTaxRegimes, [.microBIC, .lmnpReal])

        viewModel.selectRentalType(.bare)

        XCTAssertEqual(viewModel.draft.rentalType, .bare)
        XCTAssertEqual(viewModel.draft.taxRegime, .microFoncier)
        XCTAssertEqual(viewModel.availableTaxRegimes, [.microFoncier, .realFoncier])
    }

    @MainActor
    func testProjectFormViewModelIgnoresUnsupportedTaxRegimeSelection() {
        let viewModel = ProjectFormViewModel()

        viewModel.selectTaxRegime(.realFoncier)

        XCTAssertEqual(viewModel.draft.taxRegime, .microBIC)
    }

    @MainActor
    func testProjectFormViewModelClearsCurrentCalculationWhenRentalTypeChanges() {
        let viewModel = ProjectFormViewModel(
            draft: InvestmentProjectDraft(
                rentalType: .furnished,
                taxRegime: .microBIC,
                purchasePrice: 150_000,
                notaryFees: 12_000,
                monthlyRent: 850,
                monthlyCondominiumFees: 90,
                annualPropertyTax: 840,
                monthlyPayment: 650,
                taxRate: 30
            )
        )

        viewModel.calculate()
        XCTAssertNotNil(viewModel.currentProject)

        viewModel.selectRentalType(.bare)

        XCTAssertNil(viewModel.currentProject)
        XCTAssertNil(viewModel.errorMessage)
    }

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

    func testInvestmentCalculatorIncludesDownPaymentInCosts() throws {
        let costs = try calculator.costs(
            price: 100_000,
            notaryFees: 8_000,
            agencyCosts: 5_000,
            works: 7_000,
            downPayment: 20_000
        )

        XCTAssertEqual(costs.total, 120_000)
        XCTAssertEqual(costs.downPayment, 20_000)
        XCTAssertEqual(costs.financedAmount, 100_000)
    }

    func testInvestmentCalculatorDoesNotExposeNegativeFinancedAmount() throws {
        let costs = try calculator.costs(
            price: 100_000,
            notaryFees: 8_000,
            downPayment: 120_000
        )

        XCTAssertEqual(costs.total, 108_000)
        XCTAssertEqual(costs.financedAmount, 0)
    }

    func testInvestmentCalculatorAppliesVacancyAndOwnerInsuranceToEconomicResult() throws {
        let costs = try calculator.costs(
            price: 200_000,
            notaryFees: 0
        )
        let indicators = try calculator.economicIndicators(
            monthlyRent: 1_000,
            vacancyRate: 5,
            monthlyCondominiumFees: 100,
            monthlyPayment: 500,
            monthlyPropertyTax: 50,
            annualOwnerInsurance: 240
        )

        let result = try calculator.economicResult(costs: costs, indicators: indicators)

        XCTAssertEqual(indicators.annualRentalPrice, 11_400, accuracy: 0.0001)
        XCTAssertEqual(indicators.annualOwnerInsurance, 240, accuracy: 0.0001)
        XCTAssertEqual(result.grossYield, 5.7, accuracy: 0.0001)
        XCTAssertEqual(result.netYieldBeforeTax, 4.68, accuracy: 0.0001)
        XCTAssertEqual(result.monthlyCashflowBeforeTax, 280, accuracy: 0.0001)
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

    func testInvestmentCalculatorComputesBareMicroFoncierTaxes() throws {
        let indicators = try calculator.indicators(
            rentalType: .bare,
            taxRegime: .microFoncier,
            monthlyRent: 800,
            monthlyCondominiumFees: 100,
            taxRate: 30,
            monthlyPayment: 500,
            monthlyPropertyTax: 50
        )

        XCTAssertEqual(indicators.annualRentalPrice, 9_600)
        XCTAssertEqual(indicators.taxes, 3_171.84, accuracy: 0.0001)
    }

    func testInvestmentCalculatorComputesFurnishedMicroBICTaxes() throws {
        let indicators = try calculator.indicators(
            rentalType: .furnished,
            taxRegime: .microBIC,
            monthlyRent: 800,
            monthlyCondominiumFees: 100,
            taxRate: 30,
            monthlyPayment: 500,
            monthlyPropertyTax: 50
        )

        XCTAssertEqual(indicators.annualRentalPrice, 9_600)
        XCTAssertEqual(indicators.taxes, 2_265.6, accuracy: 0.0001)
    }

    func testInvestmentCalculatorComputesBareRealFoncierTaxes() throws {
        let indicators = try calculator.indicators(
            rentalType: .bare,
            taxRegime: .realFoncier,
            monthlyRent: 1_000,
            monthlyCondominiumFees: 120,
            taxRate: 11,
            monthlyPayment: 900,
            monthlyPropertyTax: 100
        )

        XCTAssertEqual(indicators.annualRentalPrice, 12_000)
        XCTAssertEqual(indicators.taxes, 2_639.52, accuracy: 0.0001)
    }

    func testInvestmentCalculatorDeductsOwnerInsuranceAndVacancyInBareRealFoncierTaxes() throws {
        let indicators = try calculator.indicators(
            rentalType: .bare,
            taxRegime: .realFoncier,
            monthlyRent: 1_000,
            vacancyRate: 5,
            monthlyCondominiumFees: 120,
            taxRate: 11,
            monthlyPayment: 900,
            monthlyPropertyTax: 100,
            annualOwnerInsurance: 240
        )

        XCTAssertEqual(indicators.annualRentalPrice, 11_400)
        XCTAssertEqual(indicators.taxes, 2_402.64, accuracy: 0.0001)
    }

    func testInvestmentCalculatorComputesSimplifiedLMNPRealTaxes() throws {
        let costs = try calculator.costs(
            price: 150_000,
            notaryFees: 12_000,
            agencyCosts: 5_000,
            works: 8_000
        )
        let indicators = try calculator.indicators(
            rentalType: .furnished,
            taxRegime: .lmnpReal,
            monthlyRent: 850,
            monthlyCondominiumFees: 90,
            taxRate: 30,
            monthlyPayment: 650,
            monthlyPropertyTax: 70,
            costs: costs
        )

        XCTAssertEqual(indicators.annualRentalPrice, 10_200)
        XCTAssertEqual(indicators.taxes, 1_154.8267, accuracy: 0.0001)
    }

    func testInvestmentCalculatorRejectsInvalidVacancyRate() throws {
        XCTAssertThrowsError(
            try calculator.economicIndicators(
                monthlyRent: 1_000,
                vacancyRate: 120,
                monthlyCondominiumFees: 100,
                monthlyPayment: 500,
                monthlyPropertyTax: 50
            )
        ) { error in
            XCTAssertEqual(error as? InvestmentCalculationError, .invalidInput)
        }
    }

    func testInvestmentCalculatorAppliesFurnishedMicroBICMinimumAllowance() throws {
        let indicators = try calculator.indicators(
            rentalType: .furnished,
            taxRegime: .microBIC,
            monthlyRent: 20,
            monthlyCondominiumFees: 0,
            taxRate: 30,
            monthlyPayment: 0,
            monthlyPropertyTax: 0
        )

        XCTAssertEqual(indicators.annualRentalPrice, 240)
        XCTAssertEqual(indicators.taxes, 0, accuracy: 0.0001)
    }

    func testInvestmentCalculatorRejectsBareMicroFoncierAboveAnnualRevenueLimit() throws {
        XCTAssertThrowsError(
            try calculator.indicators(
                rentalType: .bare,
                taxRegime: .microFoncier,
                monthlyRent: 1_300,
                monthlyCondominiumFees: 100,
                taxRate: 30,
                monthlyPayment: 500,
                monthlyPropertyTax: 50
            )
        ) { error in
            XCTAssertEqual(error as? InvestmentCalculationError, .ineligibleTaxRegime)
        }
    }

    func testInvestmentCalculatorRejectsFurnishedMicroBICAboveAnnualRevenueLimit() throws {
        XCTAssertThrowsError(
            try calculator.indicators(
                rentalType: .furnished,
                taxRegime: .microBIC,
                monthlyRent: 7_000,
                monthlyCondominiumFees: 100,
                taxRate: 30,
                monthlyPayment: 500,
                monthlyPropertyTax: 50
            )
        ) { error in
            XCTAssertEqual(error as? InvestmentCalculationError, .ineligibleTaxRegime)
        }
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
                rentalType: .bare,
                taxRegime: .microFoncier,
                purchasePrice: 100_000,
                notaryFees: 8_000,
                agencyCosts: 5_000,
                worksCost: 7_000,
                monthlyRent: 800,
                monthlyCondominiumFees: 100,
                annualPropertyTax: 600,
                monthlyPayment: 500,
                taxRate: 30
            )
        )

        viewModel.calculate()

        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.currentProject?.costs.total, 120_000)
        XCTAssertEqual(viewModel.currentProject?.economicResult.monthlyCashflowBeforeTax ?? 0, 150, accuracy: 0.0001)
        XCTAssertEqual(viewModel.currentProject?.indicators.taxes ?? 0, 3_171.84, accuracy: 0.0001)
        XCTAssertEqual(viewModel.currentProject?.result.grossYield ?? 0, 8, accuracy: 0.0001)
    }
}
