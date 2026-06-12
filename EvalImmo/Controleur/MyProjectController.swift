//
//  MyProjectController.swift
//  EvalImmo
//
//  Created by williams saadi on 29/04/2021.
//

import Foundation

protocol AlertFunctionProtocol {
    func alertMessage(title: String, message: String)
}

class MyProjectController {
    
    var delegate : AlertFunctionProtocol? = nil
    
    private let calculator = InvestmentCalculator()
    var allPrices = [String: Double]()
    var indicators = [String: Double]()
    var yields = [String: Double]()
    var totalPrice : Double = 0.0
    
    func allPricesInArray(price: Double, notaryFees: Double, agencyCosts: Double?, works: Double?)->[String: Double] {

        let costs = try? calculator.costs(
            price: price,
            notaryFees: notaryFees,
            agencyCosts: agencyCosts ?? 0,
            works: works ?? 0
        )

        allPrices = [
            "price": costs?.price ?? 0,
            "notaryFees": costs?.notaryFees ?? 0,
            "agencyCosts": costs?.agencyCosts ?? 0,
            "works": costs?.works ?? 0
        ]
        
        return allPrices
    }
    
    
    func calculateIndicators(rentPrice: Double, condominiumFees: Double, tax: Double, monthlyPayment: Double, propertyTax: Double)->[String: Double]
    {
        let calculatedIndicators = try? calculator.indicators(
            monthlyRent: rentPrice,
            monthlyCondominiumFees: condominiumFees,
            taxRate: tax,
            monthlyPayment: monthlyPayment,
            monthlyPropertyTax: propertyTax
        )

        indicators = [
            "annualRentalPrice": calculatedIndicators?.annualRentalPrice ?? 0,
            "AnnualCondominiumFees": calculatedIndicators?.annualCondominiumFees ?? 0,
            "taxes": calculatedIndicators?.taxes ?? 0,
            "monthlyPayment": calculatedIndicators?.monthlyPayment ?? 0,
            "propertyTax": calculatedIndicators?.annualPropertyTax ?? 0
        ]
        return indicators
    }
    
    func calculeTotalPrice(allPrices: [String: Double])->Double
    {
        totalPrice = allPrices.values.reduce(0, +)
        return totalPrice
    }
    
    func calculatYield(indicators: [String: Double], allPrices: [String: Double], totalPrice: Double)->[String: Double]
    {
        let costs = InvestmentCosts(
            price: allPrices["price"] ?? 0,
            notaryFees: allPrices["notaryFees"] ?? 0,
            agencyCosts: allPrices["agencyCosts"] ?? 0,
            works: allPrices["works"] ?? 0
        )
        let calculatedIndicators = InvestmentIndicators(
            annualRentalPrice: indicators["annualRentalPrice"] ?? 0,
            annualCondominiumFees: indicators["AnnualCondominiumFees"] ?? 0,
            taxes: indicators["taxes"] ?? 0,
            monthlyPayment: indicators["monthlyPayment"] ?? 0,
            annualPropertyTax: indicators["propertyTax"] ?? 0
        )

        guard let result = try? calculator.yields(costs: costs, indicators: calculatedIndicators) else {
            yields = [:]
            return yields
        }

        yields = [
            "grossYield": result.grossYield,
            "netYield": result.netYield,
            "netNetYield": result.netNetYield,
            "cashflow1" : result.monthlyCashflow
        ]
        
        return yields
    }
    
    func stringToDouble(values: [String])->[Double]
    {
        var valuesInDouble : [Double] = []
        var valueInDouble : Double = 0.0
        
        for value in values {
            if let convertedValue = Double(value) {
                valueInDouble = convertedValue
                valuesInDouble.append(valueInDouble)
            }
        }
        
        return valuesInDouble
    }
    
}
