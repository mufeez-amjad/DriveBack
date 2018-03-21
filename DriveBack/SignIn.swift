//
//  SignIn.swift
//  DriveBack
//
//  Created by Mufeez Amjad on 2018-03-20.
//  Copyright © 2018 Mufeez Amjad. All rights reserved.
//

import Foundation
import UIKit

class SignIn: UIViewController {
    
    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var passInput: UITextField!

    @IBOutlet weak var signInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signInButton.backgroundColor = UIColor.white
        signInButton.layer.cornerRadius = 10
        signInButton.setTitleColor(UIColor(red:0.95, green:0.35, blue:0.16, alpha:1.0), for: .normal)
        
        emailInput.borderStyle = UITextBorderStyle.roundedRect
        emailInput.layer.cornerRadius = 10
        
        passInput.borderStyle = UITextBorderStyle.roundedRect
        passInput.layer.cornerRadius = 10
        
    }
    
}
