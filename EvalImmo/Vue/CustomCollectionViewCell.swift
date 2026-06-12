//
//  CustomCollectionViewCell.swift
//  EvalImmo
//
//  Created by williams saadi on 01/05/2021.
//

import UIKit

class CustomCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var tmiLbl: UILabel!
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.layer.cornerRadius = 20
        self.layer.borderColor = UIColor.systemBlue.cgColor
        self.layer.borderWidth = 2
        //self.layer.backgroundColor = UIColor.clear.cgColor
    }
    
    func configure (tmi : String)
    {
        tmiLbl.text = tmi
    }
    
    func selctionBlocked () {
        self.layer.borderColor = UIColor.systemRed.cgColor
    }
}
