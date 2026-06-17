//
//  InvestmentProjectDraft.swift
//  EvalImmo
//

import Foundation

struct InvestmentProjectDraft: Codable, Equatable {
    var name: String = ""
    var rentalType: RentalType = .furnished
    var taxRegime: TaxRegime = .microBIC
    var purchasePrice: Double = 0
    var notaryFees: Double = 0
    var agencyCosts: Double = 0
    var worksCost: Double = 0
    var downPayment: Double = 0
    var monthlyRent: Double = 0
    var vacancyRate: Double = 0
    var monthlyCondominiumFees: Double = 0
    var annualPropertyTax: Double = 0
    var annualOwnerInsurance: Double = 0
    var annualAccountantFees: Double = 0
    var monthlyPayment: Double = 0
    var taxRate: Double = 0

    init() {}

    enum CodingKeys: String, CodingKey {
        case name
        case rentalType
        case taxRegime
        case purchasePrice
        case notaryFees
        case agencyCosts
        case worksCost
        case downPayment
        case monthlyRent
        case vacancyRate
        case monthlyCondominiumFees
        case annualPropertyTax
        case annualOwnerInsurance
        case annualAccountantFees
        case monthlyPayment
        case taxRate
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        rentalType = try container.decodeIfPresent(RentalType.self, forKey: .rentalType) ?? .furnished
        taxRegime = try container.decodeIfPresent(TaxRegime.self, forKey: .taxRegime) ?? .microBIC
        purchasePrice = try container.decodeIfPresent(Double.self, forKey: .purchasePrice) ?? 0
        notaryFees = try container.decodeIfPresent(Double.self, forKey: .notaryFees) ?? 0
        agencyCosts = try container.decodeIfPresent(Double.self, forKey: .agencyCosts) ?? 0
        worksCost = try container.decodeIfPresent(Double.self, forKey: .worksCost) ?? 0
        downPayment = try container.decodeIfPresent(Double.self, forKey: .downPayment) ?? 0
        monthlyRent = try container.decodeIfPresent(Double.self, forKey: .monthlyRent) ?? 0
        vacancyRate = try container.decodeIfPresent(Double.self, forKey: .vacancyRate) ?? 0
        monthlyCondominiumFees = try container.decodeIfPresent(Double.self, forKey: .monthlyCondominiumFees) ?? 0
        annualPropertyTax = try container.decodeIfPresent(Double.self, forKey: .annualPropertyTax) ?? 0
        annualOwnerInsurance = try container.decodeIfPresent(Double.self, forKey: .annualOwnerInsurance) ?? 0
        annualAccountantFees = try container.decodeIfPresent(Double.self, forKey: .annualAccountantFees) ?? 0
        monthlyPayment = try container.decodeIfPresent(Double.self, forKey: .monthlyPayment) ?? 0
        taxRate = try container.decodeIfPresent(Double.self, forKey: .taxRate) ?? 0
    }
}
