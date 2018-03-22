//
//  SignIn.swift
//  DriveBack
//
//  Created by Mufeez Amjad on 2018-03-20.
//  Copyright © 2018 Mufeez Amjad. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class SignIn: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var passInput: UITextField!

    @IBOutlet weak var signInButton: UIButton!
    
    var email: String!
    var password: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //addTestUser()
        emailInput.delegate = self
        passInput.delegate = self
        
        signInButton.backgroundColor = UIColor.white
        signInButton.layer.cornerRadius = 10
        signInButton.setTitleColor(UIColor(red:0.95, green:0.35, blue:0.16, alpha:1.0), for: .normal)
        
        emailInput.borderStyle = UITextBorderStyle.roundedRect
        emailInput.layer.cornerRadius = 10
        
        passInput.borderStyle = UITextBorderStyle.roundedRect
        passInput.layer.cornerRadius = 10
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //hides keyboard when view is tapped
        emailInput.resignFirstResponder()
        passInput.resignFirstResponder()
    }
    
    func addTestUser(){
        Auth.auth().createUser(withEmail: "zeefumdajma@gmail.com", password: "abc123") { (user, error) in
            if error != nil {
                print(error?.localizedDescription)
                return
            }
        }
    }
    
    @IBAction func signInPressed(_ sender: UIButton?) {
        
        if let email = emailInput.text, let password = passInput.text {
            if isValid(email: emailInput.text!) {
                Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                    if let u = user {
                        //present main VC
                    }
                    else {
                        let alertController = UIAlertController(title: "Failed", message: "Username and password do not match or user does not exist.", preferredStyle: .alert)
                        let actionOk = UIAlertAction(title: "OK",
                                                     style: .default,
                                                     handler: nil)
                        alertController.addAction(actionOk)
                        
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
            else if email.count > 0 && password.count > 0 {
                let alertController = UIAlertController(title: "Error", message: "Your email address is invalid. Please enter a valid address.", preferredStyle: .alert)
                let actionOk = UIAlertAction(title: "OK",
                                             style: .default,
                                             handler: nil)
                alertController.addAction(actionOk)
                
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func isValid(email: String) -> Bool { //checks if @ appears before .com, .ca, etc.
        var positionAt = -1
        var positionDot = -1
        
        if let idxAt = email.index(of: "@") {
            positionAt = email.distance(from: email.startIndex, to: idxAt)
        }
        
        if let idxDot = email.index(of: ".") {
            positionDot = email.distance(from: email.startIndex, to: idxDot)
        }
        
        return positionDot > positionAt
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
            signInPressed(nil)
        }
        
        return false
    }
}
