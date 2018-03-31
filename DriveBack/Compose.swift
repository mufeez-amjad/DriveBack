//
//  Compose.swift
//  DriveBack
//
//  Created by Mufeez Amjad on 2018-03-30.
//  Copyright © 2018 Mufeez Amjad. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class Compose: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var messageInput: UITextView!
    @IBOutlet weak var recipientInput: UITextField!
    @IBOutlet weak var stateInput: UITextField!
    
    @IBOutlet weak var sendButton: UIButton!
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        recipientInput.becomeFirstResponder()
        
        messageInput.delegate = self
        stateInput.delegate = self
        recipientInput.delegate = self
        
        var borderColor: UIColor? = UIColor(red: 204.0 / 255.0, green: 204.0 / 255.0, blue: 204.0 / 255.0, alpha: 1.0)

        /*
        recipientInput.layer.borderColor = borderColor?.cgColor
        recipientInput.layer.borderWidth = 0.5
        
        stateInput.layer.borderColor = borderColor?.cgColor
        stateInput.layer.borderWidth = 0.5
        */
        
        sendButton.backgroundColor = UIColor(red:0.95, green:0.35, blue:0.16, alpha:1.0)
        sendButton.layer.cornerRadius = 10
        sendButton.setTitleColor(UIColor.white, for: .normal)
        
        messageInput.layer.borderColor = borderColor?.cgColor
        messageInput.layer.borderWidth = 0.5
        messageInput.layer.cornerRadius = 5.0
    }
    
    @IBAction func xPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == recipientInput {
            stateInput.becomeFirstResponder()
            return false
        }
        else if textField == stateInput {
            messageInput.becomeFirstResponder()
            return false
        }
        return true
    }
    
    @IBAction func sendPressed(_ sender: Any) {
        
    }
}
