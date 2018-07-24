//
//  Compose.swift
//  DriveBack
//
//  Created by Mufeez Amjad on 2018-03-30.
//  Copyright © 2018 Mufeez Amjad. All rights reserved.
//

import Foundation
import UIKit
import SocketIO

class Compose: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var messageInput: UITextView!
    @IBOutlet weak var recipientInput: UITextField!
    @IBOutlet weak var stateInput: UITextField!
    
    @IBOutlet weak var sendButton: UIButton!
    
    //let db = Firestore.firestore()
    
    var socket: SocketIOClient!
    
    var plate: String!
    
    var status = "failed"
    
    override func viewDidLoad() {
        
        plate = defaults.string(forKey: "plate")
        
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
        if let message = messageInput.text, let state = stateInput.text, let sendTo = recipientInput.text {
            let address = sendTo + "" + state
            let data: [Any]  = [
                [
                    "from": plate,
                    "to": address,
                    "message": message
                ]
            ]
            SocketIOManager.sharedInstance.sendNewMessage(data: data)
        }

        _ = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.presentError), userInfo: nil, repeats: false)

        SocketIOManager.sharedInstance.getMessageStatus() { data in
            self.status = data
            
            if self.status == "sent" {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    
    @objc func presentError(){
        if (status == "failed"){
            let alertController = UIAlertController(title: "Error", message: "An error occured and the message could not be sent.", preferredStyle: .alert)
            let actionOk = UIAlertAction(title: "OK",
                                         style: .default,
                                         handler: nil)
            alertController.addAction(actionOk)
            
            self.present(alertController, animated: true, completion: nil)
            return
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        recipientInput.becomeFirstResponder() //opens keyboard
    }
}
