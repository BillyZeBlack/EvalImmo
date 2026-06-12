//
//  User.swift
//  EvalImmo
//
//  Created by williams saadi on 22/03/2021.
//

import Foundation
import Parse

class User {
    
    var userId : String?
    var firstname : String
    var lastname : String
    var emailUser : String
    var userPassword : String
    var propertyList: [Property]?
    
    init(userId: String?, firstname: String, lastname: String, emailUser: String, password: String, propertyList: [Property]?) {
        self.userId = userId
        self.firstname = firstname
        self.lastname = lastname
        self.emailUser = emailUser
        self.userPassword = password
        self.propertyList = propertyList
    }
    
}
