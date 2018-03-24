//
//  Register.swift
//  DriveBack
//
//  Created by Mufeez Amjad on 2018-03-22.
//  Copyright © 2018 Mufeez Amjad. All rights reserved.
//

import Foundation
import UIKit

class Register: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var fNameInput: UITextField!
    @IBOutlet weak var lNameInput: UITextField!
    
    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var passInput: UITextField!

    @IBOutlet weak var licenseInput: UITextField!
    @IBOutlet weak var stateInput: UITextField!
    
    @IBOutlet weak var createAccButton: UIButton!
    
    var emailValid = false
    var passValid = false
    var fNameValid = false
    var lNameValid = false
    var licenseValid = false
    var stateValid = false

    override func viewDidLoad() {
        super.viewDidLoad()
        createAccButton.backgroundColor = UIColor.white
        createAccButton.layer.cornerRadius = 10
        createAccButton.setTitleColor(UIColor(red:0.95, green:0.35, blue:0.16, alpha:1.0), for: .normal)
        
        fNameInput.delegate = self
        lNameInput.delegate = self
        emailInput.delegate = self
        passInput.delegate = self
        licenseInput.delegate = self
        stateInput.delegate = self

    }
    
    func isValid(email: String, password: String, fN: String, lN: String, license: String, state: String) -> Bool{ //1
        //checks if @ appears before .com, .ca, etc.
        var positionAt = -1
        var positionDot = -1
            
        if let idxAt = email.index(of: "@") {
            positionAt = email.distance(from: email.startIndex, to: idxAt)
        }
        
        if let idxDot = email.index(of: ".") {
            positionDot = email.distance(from: email.startIndex, to: idxDot)
        }
        emailValid = positionDot > positionAt
        passValid = password.count > 3
        fNameValid = fN.count >= 2
        lNameValid = lN.count >= 2
        licenseValid = license.count >= 2 && license.count <= 8 //Canada and USA license plates
        stateValid = state.count == 2 //2 letter abbreviations
        
        return emailValid && passValid && fNameValid && lNameValid && licenseValid && stateValid
    }
    
    @IBAction func xPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //hides keyboard when view is tapped
        fNameInput.resignFirstResponder()
        lNameInput.resignFirstResponder()
        emailInput.resignFirstResponder()
        passInput.resignFirstResponder()
        licenseInput.resignFirstResponder()
        stateInput.resignFirstResponder()
    }
    
    @IBAction func createAccPressed(_ sender: Any) {
        if let email = emailInput.text, let password = passInput.text, let fName = fNameInput.text, let lName = lNameInput.text, let license = licenseInput.text, let state = stateInput.text {
            
            if isValid(email: email, password: password, fN: fName, lN: lName, license: license, state: state) {
                
            }
            
            else {
                var message = ""
                
                if !fNameValid || !lNameValid {
                    message += "Please enter valid name. "
                }
                if !emailValid {
                    message += "Please enter a valid email address. "
                }
                if !passValid {
                    message += "Please enter a secure password. "
                }
                if !licenseValid {
                    message += "Please enter valid license plate number. "
                }
                if !stateValid {
                    message += "Please enter valid state/province abbreviation."
                }
                
                let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
                let actionOk = UIAlertAction(title: "OK",
                                                 style: .default,
                                                 handler: nil)
                alertController.addAction(actionOk)
                    
                self.present(alertController, animated: true, completion: nil)
                
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag = textField.tag + 1
        // Try to find next responder
        let nextResponder = textField.superview?.viewWithTag(nextTag) as UIResponder!
        
        if nextResponder != nil {
            // Found next responder, so set it
            nextResponder?.becomeFirstResponder()
        } else {
            // Not found, so remove keyboard
            textField.resignFirstResponder()
        }
        
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5, animations: {
            self.view.frame.origin.y = -100 // Move view 150 points upward
        }, completion: nil)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5, animations: {
            self.view.frame.origin.y = 0 // Move view to original position
        }, completion: nil)
    }
    
}
