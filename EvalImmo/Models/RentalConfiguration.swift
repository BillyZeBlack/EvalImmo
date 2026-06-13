//
//  RentalConfiguration.swift
//  EvalImmo
//

import Foundation

enum RentalType: String, CaseIterable, Equatable, Identifiable {
    case bare = "bare"
    case furnished = "furnished"

    var id: Self { self }

    var title: String {
        switch self {
        case .bare:
            return "Location nue"
        case .furnished:
            return "Location meublee"
        }
    }
}

enum TaxRegime: String, CaseIterable, Equatable, Identifiable {
    case microFoncier = "microFoncier"
    case realFoncier = "realFoncier"
    case microBIC = "microBIC"
    case lmnpReal = "lmnpReal"

    var id: Self { self }

    var title: String {
        switch self {
        case .microFoncier:
            return "Micro-foncier"
        case .realFoncier:
            return "Reel foncier"
        case .microBIC:
            return "Micro-BIC"
        case .lmnpReal:
            return "LMNP reel"
        }
    }

    var rentalType: RentalType {
        switch self {
        case .microFoncier, .realFoncier:
            return .bare
        case .microBIC, .lmnpReal:
            return .furnished
        }
    }
}

extension RentalType {
    var defaultTaxRegime: TaxRegime {
        switch self {
        case .bare:
            return .microFoncier
        case .furnished:
            return .microBIC
        }
    }

    var availableTaxRegimes: [TaxRegime] {
        TaxRegime.allCases.filter { $0.rentalType == self }
    }
}
