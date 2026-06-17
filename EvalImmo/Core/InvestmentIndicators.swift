//
//  InvestmentIndicators.swift
//  EvalImmo
//

import Foundation

struct InvestmentIndicators: Codable, Equatable {
    let annualRentalPrice: Double
    let annualCondominiumFees: Double
    let taxes: Double
    let monthlyPayment: Double
    let annualPropertyTax: Double
    let annualOwnerInsurance: Double
    let annualAccountantFees: Double

    init(
        annualRentalPrice: Double,
        annualCondominiumFees: Double,
        taxes: Double,
        monthlyPayment: Double,
        annualPropertyTax: Double,
        annualOwnerInsurance: Double,
        annualAccountantFees: Double = 0
    ) {
        self.annualRentalPrice = annualRentalPrice
        self.annualCondominiumFees = annualCondominiumFees
        self.taxes = taxes
        self.monthlyPayment = monthlyPayment
        self.annualPropertyTax = annualPropertyTax
        self.annualOwnerInsurance = annualOwnerInsurance
        self.annualAccountantFees = annualAccountantFees
    }

    enum CodingKeys: String, CodingKey {
        case annualRentalPrice
        case annualCondominiumFees
        case taxes
        case monthlyPayment
        case annualPropertyTax
        case annualOwnerInsurance
        case annualAccountantFees
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        annualRentalPrice = try container.decode(Double.self, forKey: .annualRentalPrice)
        annualCondominiumFees = try container.decode(Double.self, forKey: .annualCondominiumFees)
        taxes = try container.decode(Double.self, forKey: .taxes)
        monthlyPayment = try container.decode(Double.self, forKey: .monthlyPayment)
        annualPropertyTax = try container.decode(Double.self, forKey: .annualPropertyTax)
        annualOwnerInsurance = try container.decode(Double.self, forKey: .annualOwnerInsurance)
        annualAccountantFees = try container.decodeIfPresent(Double.self, forKey: .annualAccountantFees) ?? 0
    }
}
