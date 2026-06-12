//
//  CustomUIView.swift
//  EvalImmo
//
//  Created by williams saadi on 28/04/2021.
//

import UIKit

class CustomUIView: UIView {

    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
     layer.cornerRadius = 20
     layer.cornerRadius = 20
     layer.borderWidth = 2
     layer.borderColor = UIColor.systemBlue.cgColor
     self.clipsToBounds = true
    }
    
}
