//
//  Property.swift
//  EvalImmo
//
//  Created by williams saadi on 22/03/2021.
//

import Foundation

class Property: Codable {
    var nameProperty: String
    var placeProperty : String
    var grossYield : Double
    var netReturn : Double
    var netNetReturn : Double
    var userId: String
    
    init(nameProperty: String, placeProperty: String, grossYield: Double, netReturn: Double, netNetReturn: Double, userId: String) {
        self.nameProperty = nameProperty
        self.placeProperty = placeProperty
        self.grossYield = grossYield
        self.netReturn = netReturn
        self.netNetReturn = netNetReturn
        self.userId = userId
    }
    
}
