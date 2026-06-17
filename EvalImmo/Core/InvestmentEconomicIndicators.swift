//
//  InvestmentEconomicIndicators.swift
//  EvalImmo
//

import Foundation

struct InvestmentEconomicIndicators: Codable, Equatable {
    let annualRentalPrice: Double
    let annualCondominiumFees: Double
    let monthlyPayment: Double
    let annualPropertyTax: Double
    let annualOwnerInsurance: Double
    let annualAccountantFees: Double

    init(
        annualRentalPrice: Double,
        annualCondominiumFees: Double,
        monthlyPayment: Double,
        annualPropertyTax: Double,
        annualOwnerInsurance: Double,
        annualAccountantFees: Double = 0
    ) {
        self.annualRentalPrice = annualRentalPrice
        self.annualCondominiumFees = annualCondominiumFees
        self.monthlyPayment = monthlyPayment
        self.annualPropertyTax = annualPropertyTax
        self.annualOwnerInsurance = annualOwnerInsurance
        self.annualAccountantFees = annualAccountantFees
    }

    enum CodingKeys: String, CodingKey {
        case annualRentalPrice
        case annualCondominiumFees
        case monthlyPayment
        case annualPropertyTax
        case annualOwnerInsurance
        case annualAccountantFees
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        annualRentalPrice = try container.decode(Double.self, forKey: .annualRentalPrice)
        annualCondominiumFees = try container.decode(Double.self, forKey: .annualCondominiumFees)
        monthlyPayment = try container.decode(Double.self, forKey: .monthlyPayment)
        annualPropertyTax = try container.decode(Double.self, forKey: .annualPropertyTax)
        annualOwnerInsurance = try container.decode(Double.self, forKey: .annualOwnerInsurance)
        annualAccountantFees = try container.decodeIfPresent(Double.self, forKey: .annualAccountantFees) ?? 0
    }
}
