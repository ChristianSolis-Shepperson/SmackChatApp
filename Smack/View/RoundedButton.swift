//
//  RoundedButton.swift
//  Smack
//
//  Created by Christian Solis-Shepperson on 5/20/18.
//  Copyright © 2018 Christian Solis-Shepperson. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedButton: UIButton {

    //sets the button corner radius to the variable created in IDE
    @IBInspectable var cornerRadius: CGFloat = 3.0{
        didSet{
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    //Sets the button corner  to variable created during runtime
    func setupView(){
        self.layer.cornerRadius = cornerRadius
    }
    
    //overrides method to allow changes to show in IDE
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        self.setupView()
    }

    //Calls method to set up new view for button when button is created
    override func awakeFromNib() {
        self.setupView()
    }
}
