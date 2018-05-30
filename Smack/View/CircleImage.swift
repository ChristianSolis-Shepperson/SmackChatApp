//
//  CircleImage.swift
//  Smack
//
//  Created by Christian Solis-Shepperson on 5/28/18.
//  Copyright © 2018 Christian Solis-Shepperson. All rights reserved.
//

import UIKit

@IBDesignable
class CircleImage: UIImageView {

    override func awakeFromNib() {
        setUpView()
    }
    
    func setUpView(){
        self.layer.cornerRadius = self.frame.width / 2
        self.clipsToBounds = true
    }
  
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setUpView()
    }
    
}
