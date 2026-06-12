//
//  SignInViewController.swift
//  EvalImmo
//
//  Created by williams saadi on 03/04/2021.
//

import UIKit

class SignInViewController: UIViewController, ShowAlertMessageWrongIdentifiersProtocol{

    //var myGlobalController : GlobalControler!
    var myGlobalController = GlobalControler()

    @IBOutlet weak var firstnameTextfield: UITextField!
    @IBOutlet weak var lastnameTextfield: UITextField!
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var confirmPasswordTextfield: UITextField!
    
    @IBOutlet weak var sendUserInfosBtn: CustomUiButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //myGlobalController!.userControler.secondDelagete = self
    }
    
    
    @IBAction func SendUserInfos(_ sender: Any)
    {
        if checkAllTextfieldsAreNoEmpty() && checkIfPasswordsAreSame() {
            let user = User(userId: nil, firstname: firstnameTextfield.text!, lastname: lastnameTextfield.text!, emailUser: emailTextfield.text!, password: passwordTextfield.text!, propertyList: nil)
            myGlobalController.userControler.saveUser(user: user)
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginViewController = storyboard.instantiateViewController(withIdentifier: "loginView") as? LoginViewController
            //loginViewController?.myGlobalController = myGlobalControler
            self.present(loginViewController!, animated: true, completion: nil)
        } else {
            showAlertMessage(message: "Vérifier les champs", title: "Erreur")
        }
    }
    
    private func checkAllTextfieldsAreNoEmpty()->Bool
    {
        
        return true
    }
    
    private func checkIfPasswordsAreSame()->Bool
    {
        
            return true
    }
    
    private func saveUserLastnameIntoUserDefaults()
    {
           //for futures connexions...
    }
    
    func showAlertMessage(message: String, title: String) {
        let alertController = UIAlertController(title: title, message:
                message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default))

            self.present(alertController, animated: true, completion: nil)
    }
}
