//
//  HomeViewController.swift
//  EvalImmo
//
//  Created by williams saadi on 22/03/2021.
//

import UIKit
import Parse

class LoginViewController: UIViewController, SendUserConnectedProtocol, ShowAlertMessageWrongIdentifiersProtocol {
    
    let myGlobalControler = GlobalControler()
    var userConnected : PFUser!
    var userFind = false
    var screenSize : Double = 0.0
    var forgotPasswordViewIHidden = true
    
    @IBOutlet weak var firstnameTexfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var forgotPasswordEmailTextfield: UITextField!
    
    @IBOutlet weak var connectBtn: UIButton!
    @IBOutlet weak var signInBtn: UIButton!
    
    @IBOutlet weak var stackViewConstraints: NSLayoutConstraint!
    @IBOutlet weak var viewForgotPAsswordConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewForgotPasswordRightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var viewForgotPassword: UIView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Delegates <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        myGlobalControler.userControler.delegate = self
        myGlobalControler.userControler.secondDelagete = self
        
        firstnameTexfield.delegate = self
        passwordTextfield.delegate = self
        forgotPasswordEmailTextfield.delegate = self
        
        
        // Listen for keyborad events<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        
        //Initialisation de variables
        viewForgotPAsswordConstraint.constant =  1004
        
        
        // Appel des fonctions<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        screenSize = checkTheScreenSize()
        designViewForgotPassword()
        
        /**
            1 verifier si l'Id n'est pas dans le setting default
                    si oui  demande de mot de passe
                    si non proposer l'inscription
         */
        
    }
    
    private func designViewForgotPassword()
    {
        viewForgotPassword.layer.borderWidth = 2
        viewForgotPassword.layer.cornerRadius = 10
        viewForgotPassword.layer.shadowColor = UIColor.black.cgColor
        viewForgotPassword.layer.shadowOffset = CGSize(width: 15, height: -8)
        viewForgotPassword.layer.shadowOpacity = 0.7
        viewForgotPassword.layer.shadowRadius = 8
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
        
    @IBAction func loginBtn(_ sender: Any) {
        myGlobalControler.userControler.loginUser(firstname: firstnameTexfield.text!, userPassword: passwordTextfield.text!)
        
        /*let property = Property(nameProperty: "Bien 2", placeProperty: "13190", grossYield: 10.4, netReturn: 6.7, netNetReturn: 5.0, userId: (PFUser.current()?.objectId)!)
            myGlobalControler.propertyControler.saveProperty(property: property)*/
    }
    
    @IBAction func signInBtn(_ sender: Any)
    {
        //On récupère Main.storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
            //On crée une instance d'Exercice à partir du storyboard
        let signInViewController = storyboard.instantiateViewController(withIdentifier: "signInView") as? SignInViewController
            //On lui attribue le niveau en fonction du bouton
        signInViewController?.myGlobalController = myGlobalControler
            //On montre le nouveau controller
        //navigationController?.show(signInViewController!, sender: self)
        self.present(signInViewController!, animated: true, completion: nil)
    }
    
    
    @IBAction func forgotPasswordBtn(_ sender: Any)
    {
        if forgotPasswordViewIHidden {
            viewForgotPAsswordConstraint.constant =  16
            //viewForgotPasswordRightConstraint.constant =  16
            
            viewAnimate()
            
            forgotPasswordViewIHidden = !forgotPasswordViewIHidden
        }
    }
    
    @IBAction func sendRequestForgotPasswordBtn(_ sender: Any)
    {
        if !forgotPasswordViewIHidden && forgotPasswordEmailTextfield.text! != ""{
            // An e-mail will be sent with further instructions
            myGlobalControler.userControler.retrievePassword(email: forgotPasswordEmailTextfield.text!)
            
            viewForgotPAsswordConstraint.constant =  1004
            //viewForgotPasswordRightConstraint.constant = 0
            
            viewAnimate()
        } else if forgotPasswordEmailTextfield.text! == ""{
            viewForgotPAsswordConstraint.constant =  1004
            //viewForgotPasswordRightConstraint.constant = 0
            viewAnimate()
            showAlertMessage(message: "L'adresse email n'a pas été renseignée.", title: "Information")
        }
        forgotPasswordViewIHidden = !forgotPasswordViewIHidden
    }
    
    private func viewAnimate()
    {
        UIView.animate(withDuration: 0.6) {
            self.view.layoutIfNeeded()
        }
    }
    
    func sendUserConnected(user: PFUser, found: Bool) {
        self.userConnected = user
        /**
         myProjectViewController
         MyProjectViewController
         yieldsViews
         YieldsViewsViewController
         */
        
        if found {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let myProjectViewController  = storyboard.instantiateViewController(withIdentifier: "createProjectView") as? MyProjectViewController
            myProjectViewController?.myGlobalController = myGlobalControler
            self.present(myProjectViewController!, animated: true, completion: nil)
        } else {
            showAlertMessage(message: "Veuillez réessayer.", title: "Une erreur s'est produite")
        }
    }
    
    func showAlertMessage(message: String, title: String) {
        let alertController = UIAlertController(title: title, message:
                message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default))

            self.present(alertController, animated: true, completion: nil)
    }

    
    /*func catchUserConnected(user : PFUser){
        print("L'Id de l'user est : \(userConnected.email)")
    }*/
    
    func addPropertyToUser(){
        let property = Property(nameProperty: "Bien 2", placeProperty: "13013", grossYield: 9.4, netReturn: 5.7, netNetReturn: 3.0, userId: userConnected.objectId!)
        myGlobalControler.propertyControler.saveProperty(property: property)
        //myGlobalControler.propertyControler.addProperty(property: property)
    }
    
    @objc func keyboardWillChange(notification: Notification)
    {
        guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        
        if (notification.name.rawValue ==  "UIKeyboardWillShowNotification" || notification.name.rawValue == "UIKeyboardWillChangeFrameNotification") && screenSize <= 1336.0 {
            //view.frame.origin.y = -keyboardRect.height
            stackViewConstraints.constant = -keyboardRect.height/2
        } else {
            view.frame.origin.y = 0
        }
    }
    
    private func checkTheScreenSize()->Double
    {
        switch UIScreen.main.sizeType {
            case .iPhone4:
                screenSize = 960.0
                break
            case .iPhone5:
                screenSize = 1136.0
                break
            case .iPhone6AndSE:
                screenSize = 1334.0
                break
            case .iPhone6PlusOr8Plus:
                screenSize = 1920.0
                break
            case .iPhone12Mini:
                screenSize = 2340.0
                break
            case .iPhone12Or12Pro:
                screenSize = 2532.0
                break
            case .iPhone12ProMax:
                screenSize = 2778.0
                break
            case .iPhone11ProOrXSOrX:
                screenSize = 2436.0
                break
            case .iPhone11OrXR:
                screenSize = 1792
                break
            default:
                screenSize = 0.0
        }
        return screenSize
    }
    

}

//Detecte la taille de l'écran
extension UIScreen {

    enum SizeType: CGFloat {
        case Unknown = 0.0
        case iPhone4 = 960.0
        case iPhone5 = 1136.0
        case iPhone6AndSE = 1334.0
        case iPhoneSe1st = 1336.0
        case iPhone11OrXR = 1792
        case iPhone6PlusOr8Plus = 1920.0
        case iPhone12Mini = 2340.0
        case iPhone11ProOrXSOrX = 2436.0
        case iPhone12Or12Pro = 2532.0
        case iPhone11ProMaxOrXsMax = 2688.0
        case iPhone12ProMax = 2778.0
    }

    var sizeType: SizeType {
        let height = nativeBounds.height
        guard let sizeType = SizeType(rawValue: height) else { return .Unknown }
        return sizeType
    }
    
    
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        stackViewConstraints.constant = 36
        return true
    }
}
