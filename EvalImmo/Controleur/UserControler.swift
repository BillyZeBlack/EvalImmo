//
//  UserControler.swift
//  EvalImmo
//
//  Created by williams saadi on 22/03/2021.
//

import Foundation
import Parse

protocol SendUserConnectedProtocol {
    func sendUserConnected(user: PFUser, found: Bool)
}

protocol ShowAlertMessageWrongIdentifiersProtocol {
    func showAlertMessage(message: String, title: String)
}

class UserControler {
    
    var delegate : SendUserConnectedProtocol? = nil
    var secondDelagete : ShowAlertMessageWrongIdentifiersProtocol? = nil
    var myPropertyController = PropertyController()
    
    var myUser : PFUser?
    
    
    func loginUser (firstname: String, userPassword: String) {
        PFUser.logInWithUsername(inBackground: firstname, password: userPassword) {
          (user: PFUser?, error: Error?) -> Void in
          if user != nil {
            if self.delegate != nil {
                self.myUser = user
                self.delegate?.sendUserConnected(user: self.myUser!, found: true)
            }
          } else {
            if self.secondDelagete != nil {
                self.secondDelagete?.showAlertMessage(message: "Veuillez vérifier vos identifiants.", title: "Erreur")
            }
          }
        }
    }
        
    func saveUser (user: User){
        let userToSave = PFUser()
        userToSave.username = user.firstname
        userToSave["lastname"] = user.lastname
        userToSave.password = user.userPassword
        userToSave.email = user.emailUser
        if user.propertyList == nil {
            userToSave["propertyList"] = []
        } else {
            userToSave["propertyList"] = user.propertyList
        }
        
        userToSave.signUpInBackground {
            (succeeded: Bool, error: Error?)->Void in
            if let error = error {
                let errorString = error.localizedDescription
                print(errorString)
            } else {
                self.secondDelagete?.showAlertMessage(message: "Inscription réussie", title: "Information")
            }
        }
    }
    
    func retrievePassword(email: String) {
        // An e-mail will be sent with further instructions
        PFUser.requestPasswordResetForEmail(inBackground: email)
        self.secondDelagete?.showAlertMessage(message: "Un email de \"b4a.app\", vous a été envoyé. Veuillez vérifier votre boite mail.", title: "Information")
    }
        
    func updateUser(property : Property) {
        myPropertyController.saveProperty(property: property)

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        do {
            let data = try encoder.encode(property)
            //print(String(data: data, encoding: .utf8))
            
            if let currentUser = PFUser.current(){
                currentUser["propertyList"] = String(data: data, encoding: .utf8)
                //currentUser.add("proertryList", forKey: String(data: data, encoding: .utf8)!)
                currentUser.saveInBackground()
            }
            
        } catch {
            //do something if try failled
        }
    }
    
}
