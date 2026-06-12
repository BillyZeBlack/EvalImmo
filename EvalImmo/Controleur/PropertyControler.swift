//
//  PropertyControler.swift
//  EvalImmo
//
//  Created by williams saadi on 22/03/2021.
//

import Foundation
import Parse

class PropertyController {
    /**
     var nameProperty: String
     var placeProperty : String
     var grossYield : Double
     var netReturn : Double
     var netNetReturn : Double
     var userId: String
     */
    
    var propertyList : [Property] = []
    
    func saveProperty(property: Property) {
        let propertyToSave = PFObject(className: "Property")
        propertyToSave["nameProperty"] = property.nameProperty
        propertyToSave["placeProperty"] = property.placeProperty
        propertyToSave["grossYield"] = property.grossYield
        propertyToSave["netReturn"] = property.netReturn
        propertyToSave["netNetReturn"] = property.netNetReturn
        propertyToSave["userId"] = property.userId
        
        propertyToSave.saveInBackground()
        
        /*propertyToSave.saveInBackground { (succeeded, error) in
            if (succeeded) {
                print("Le bien est enregistré !!!")
            } else {
                print(error.debugDescription)
            }*/
        }
    //}
    
    func addProperty (property: Property)
    {
        //propertyList.append(property)
    }
    
    func deleteProperty(index: Int)
    {
        //propertyList.remove(at: index)
    }
    
    func deleteallProperty()
    {
        //propertyList.removeAll()
    }
    
}
