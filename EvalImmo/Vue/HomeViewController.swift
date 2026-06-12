//
//  ViewController.swift
//  EvalImmo
//
//  Created by williams saadi on 22/03/2021.
//

import UIKit

class HomeViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        goToHomeController()
        
    }
    
    private func goToHomeController()
    {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
             self.performSegue(withIdentifier: "goToLoginViewController", sender: self )
         }
    }


}

