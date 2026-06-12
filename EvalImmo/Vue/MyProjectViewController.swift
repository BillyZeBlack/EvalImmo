//
//  MyProjectViewController.swift
//  EvalImmo
//
//  Created by williams saadi on 28/04/2021.
//

import UIKit

class MyProjectViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource , AlertFunctionProtocol {
    
    
    var myGlobalController : GlobalControler!
    
    @IBOutlet weak var priceTextfield: UITextField!
    @IBOutlet weak var notaryFeesTextfield: UITextField!
    @IBOutlet weak var agencyCostsTextfield: UITextField!
    @IBOutlet weak var worksTextfield: UITextField!
    @IBOutlet weak var condominiumFeesTextfield: UITextField!
    @IBOutlet weak var propertyTaxTextfield: UITextField!
    @IBOutlet weak var monthlyPaymentTextfield: UITextField!
    @IBOutlet weak var rentTextfield: UITextField!
    //@IBOutlet weak var furnitureTextfield: UITextField!
    
    @IBOutlet weak var btnValider: CustomUiButton!
    
    
    @IBOutlet weak var myCollectionView: UICollectionView!
    
    
    var price : Double = 0.0        //Prix d'achat
    var notaryFees : Double = 0.0   //frais de notaire
    var agencyCosts : Double = 0.0  //frais d'agence
    var works : Double = 0.0        //travaux
    var condominiumFees : Double = 0.0  //charge de copro
    var propertyTax : Double = 0.0      //taxe fonciere
    var monthlyPayment : Double = 0.0   //mensualité
    var rent : Double = 0.0             //loyer
    var tmiTax : Double = 0.0              //tmi
    //var furnitures : Double = 0.0           // meubles
    
    var necessaryUITextfieldArray = [UITextField]()
    var optionalUITextfieldArray = [UITextField]()
    var labelTmi : [String] = ["0%", "11%", "30%", "41%", "45%"]
    
    var allTextfieldFull = false
    var textfieldNotEmpty = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboard()
        //btnValider.isEnabled = false
        
        necessaryUITextfieldArray = [
            priceTextfield,
            notaryFeesTextfield,
            propertyTaxTextfield,
            monthlyPaymentTextfield,
            rentTextfield
        ]
        
        optionalUITextfieldArray = [
            agencyCostsTextfield,
            worksTextfield,
            condominiumFeesTextfield,
            //furnitureTextfield
        ]
    }
                                            /////////////////////////////////////////////////////////////////////////////////////////////////// Marks IBAction  \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    @IBAction func validBtnPressed(_ sender: Any){
                
        textfieldNotEmpty = checkNecessaryTextfield()
        checkOptionalTextfield()
        stringToDouble()
        
        if textfieldNotEmpty {
            myGlobalController.myProjectController.allPrices = myGlobalController.myProjectController.allPricesInArray(price: price, notaryFees: notaryFees, agencyCosts: agencyCosts, works: works)
            //print("variable allPrices : \(myGlobalController.myProjectController.allPrices)")
            
            myGlobalController.myProjectController.indicators = myGlobalController.myProjectController.calculateIndicators(rentPrice: rent, condominiumFees: condominiumFees, tax: tmiTax , monthlyPayment: monthlyPayment, propertyTax: propertyTax)
            //print("variable indicators : \(myGlobalController.myProjectController.indicators)")
            
            myGlobalController.myProjectController.totalPrice = myGlobalController.myProjectController.calculeTotalPrice(allPrices: myGlobalController.myProjectController.allPrices)
            //print("variable totalPrice : \(myGlobalController.myProjectController.totalPrice)")
            
            myGlobalController.myProjectController.yields = myGlobalController.myProjectController.calculatYield(indicators: myGlobalController.myProjectController.indicators, allPrices: myGlobalController.myProjectController.allPrices, totalPrice: myGlobalController.myProjectController.totalPrice)
            print("variable yield : \(myGlobalController.myProjectController.yields)")
        }
        
        /*myCollectionView.isUserInteractionEnabled = true
        myCollectionView.allowsSelection = true*/
    }
    
    
                                    /////////////////////////////////////////////////////////////////////////////////////////////////// Marks private function  \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    //convert string to double
    private func stringToDouble()
    {
        if priceTextfield.text != "" {
            guard let constant = Double(priceTextfield.text!) else {return alertMessage(title: "Erreur", message: "Vérifier le champs \"prix du bien\"")}
            price = constant
        } else {
            alertMessage(title: "Information", message: "Le prix est obligatoire")
        }
        
        if notaryFeesTextfield.text != "" {
            guard let constant = Double(notaryFeesTextfield.text!) else {return alertMessage(title: "Erreur", message: "Vérifier le champs \"frais de notaire\"")}
            notaryFees = constant
        } else {
            alertMessage(title: "Information", message: "Les frais de notaire sont obligatoire")
        }
        
        if agencyCostsTextfield.text != "" {
            guard let constant = Double(agencyCostsTextfield.text!) else {return alertMessage(title: "Erreur", message: "Vérifier le champs \"loyer CC\"")}
            agencyCosts = constant
        }
        
        if worksTextfield.text != "" {
            guard let constant = Double(worksTextfield.text!) else {return alertMessage(title: "Erreur", message: "Vérifier le champs \"travaux\"")}
            works = constant
        }
        
        /*if furnitureTextfield.text != "" {
            guard let constant = Double(furnitureTextfield.text!) else {return alertMessage(title: "Erreur", message: "Vérifier le champs \"Meubles\"")}
            furnitures = constant
        }*/
        
        if condominiumFeesTextfield.text != "" {
            guard let constant = Double(condominiumFeesTextfield.text!) else {return alertMessage(title: "Erreur", message: "Vérifier le champs \"charges de copropriété\"")}
            condominiumFees = constant
        }
        
        if propertyTaxTextfield.text != "" {
            guard let constant = Double(propertyTaxTextfield.text!) else {return alertMessage(title: "Erreur", message: "Vérifier le champs \"taxe foncière\"")}
            propertyTax = constant
        } else {
            alertMessage(title: "Information", message: "La taxe est obligatoire")
        }
        
        if monthlyPaymentTextfield.text != "" {
            guard let constant = Double(monthlyPaymentTextfield.text!) else {return alertMessage(title: "Erreur", message: "Vérifier le champs \"mensualité\"")}
            monthlyPayment = constant
        } else {
            alertMessage(title: "Information", message: "La mensualité est obligatoire")
        }
        
        if rentTextfield.text != "" {
            guard let constant = Double(rentTextfield.text!) else {return alertMessage(title: "Erreur", message: "Vérifier le champs \"loyer CC\"")}
            rent = constant
        } else {
            alertMessage(title: "Information", message: "Le loyer est obligatoire")
        }
    }
    
    //check necessary textfield are not empty
    private func checkNecessaryTextfield ()->Bool
    {
        for textfield in necessaryUITextfieldArray {
            if textfield.text == "" {
                return false
            } else {
                textfield.text = replaceString(myString: textfield.text!)
            }
        }
        return true
    }
    
    //check optional textfield are not empty
    private func checkOptionalTextfield()
    {
        for textfield in optionalUITextfieldArray {
            if textfield.text == "" {
                textfield.text = "0.0"
            } else {
                textfield.text = replaceString(myString: textfield.text!)
            }
        }
    }
    
    //replace "," by "."
    private func replaceString(myString : String)-> String
    {
        let newString = myString.replacingOccurrences(of: ",", with: ".")
        return newString
    }
    
    
    func alertMessage(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        if title == "Erreur" || title == "Information"{
            textfieldNotEmpty = false
        }
        
        self.present(alert, animated: true)
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////marks collectionView protocol\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        labelTmi.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var mycell = UICollectionViewCell()
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? CustomCollectionViewCell {
            cell.configure(tmi: labelTmi[indexPath.row])
            mycell = cell
        }

        collectionView.layer.borderWidth = 0
        
        return mycell
    }
    
    var cell = UICollectionViewCell()
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var tmiSelected = labelTmi[indexPath.row]
        
        cell = collectionView.cellForItem(at: indexPath)!
        cell.layer.borderWidth = 5.0
        cell.layer.borderColor = UIColor.green.cgColor

        if let i = tmiSelected.firstIndex(of: "%") {
            tmiSelected.remove(at: i)
            tmiTax = Double(tmiSelected)!
        }
        print("TMI : \(tmiTax)")
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else {
            return
        }
        cell.layer.borderWidth = 2.0
        cell.layer.borderColor = UIColor.systemBlue.cgColor
    }
}

extension UIViewController {
    func hideKeyboard()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target:  self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
}
