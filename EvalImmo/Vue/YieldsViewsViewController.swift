//
//  YieldsViewsViewController.swift
//  EvalImmo
//
//  Created by williams saadi on 21/05/2021.
//

import UIKit
import Parse

class YieldsViewsViewController: UIViewController {
    
    var myGlobalController : GlobalControler!
    var properties : [Property] = []
  
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUser()
        
        // Do any additional setup after loading the view.
    }
    
    func updateUser()
    {
        let currentUser = PFUser.current()
        let testAddPropertyToUser = Property(nameProperty: "testName6", placeProperty: "testPlace6", grossYield: 12.5, netReturn: 10.8, netNetReturn: 7.6, userId: currentUser!.objectId!)
        
        //myGlobalController.propertyControler.saveProperty(property: testAddPropertyToUser)
        myGlobalController.userControler.updateUser(property: testAddPropertyToUser)
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
