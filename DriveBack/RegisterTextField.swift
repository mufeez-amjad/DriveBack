//
//  RegisterTextField.swift
//  DriveBack
//
//  Created by Mufeez Amjad on 2018-03-22.
//  Copyright © 2018 Mufeez Amjad. All rights reserved.
//

import Foundation
import UIKit

class RegisterTextField: UITextField{
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
        //Border
        self.layer.cornerRadius = 0.0;
        self.layer.borderWidth = 1.5
        self.layer.borderColor = UIColor(red:0.81, green:0.81, blue:0.81, alpha:1.0).cgColor
        
        //Background
        self.backgroundColor = UIColor.white
        
        //Text
        self.textColor = UIColor(red:0.81, green:0.81, blue:0.81, alpha:1.0)
        
        //Inset to right
        let paddingView = UIView(frame: CGRect(x: 0,y: 0,width: 8,height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = UITextFieldViewMode.always
    }
    
}
