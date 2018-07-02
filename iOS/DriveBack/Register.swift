//
//  Register.swift
//  DriveBack
//
//  Created by Mufeez Amjad on 2018-03-22.
//  Copyright © 2018 Mufeez Amjad. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import SocketIO

class Register: UIViewController, UITextFieldDelegate {
    
     let defaults = UserDefaults.standard
    
    @IBOutlet weak var fNameInput: UITextField!
    @IBOutlet weak var lNameInput: UITextField!
    
    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var passInput: UITextField!

    @IBOutlet weak var licenseInput: UITextField!
    @IBOutlet weak var stateInput: UITextField!
    
    @IBOutlet weak var createAccButton: UIButton!
    
    @IBOutlet weak var logo: UIImageView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var emailValid = false
    var passValid = false
    var fNameValid = false
    var lNameValid = false
    var licenseValid = false
    var stateValid = false
    
    //var db: Firestore!
    
    let manager = SocketManager(socketURL: URL(string: "http://localhost:3000")!, config: [.log(true), .compress])
    var socket: SocketIOClient!
    
    override func viewDidAppear(_ animated: Bool) {
        socket.connect()
        
        self.socket.on("connect") {data, ack in
            print("socket connected")
        }
    }
    
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
        
        socket = manager.defaultSocket

        /*
        // [START setup]
        let settings = FirestoreSettings()
        
        Firestore.firestore().settings = settings
        // [END setup]
        db = Firestore.firestore()
         */
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        self.view.addGestureRecognizer(tap)
    }
    
    func isValid(email: String, password: String, fN: String, lN: String, license: String, state: String) -> Bool{ //1
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        emailValid = emailTest.evaluate(with: email)
        
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
    
    @objc func viewTapped(){
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
                Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                    if error != nil {
                        print(error?.localizedDescription)
                        let alertController = UIAlertController(title: "Error", message: "An account with that email already exists", preferredStyle: .alert)
                        let actionOk = UIAlertAction(title: "OK",
                                                     style: .default,
                                                     handler: nil)
                        alertController.addAction(actionOk)
                        
                        self.present(alertController, animated: true, completion: nil)
                        return
                    }
                    else {
                        // Add a new document with a generated ID
                        var userId = Auth.auth().currentUser?.uid
                        self.defaults.set(userId, forKey: "UID")
                        self.defaults.set(fName, forKey: "fName")
                        self.defaults.set(lName, forKey: "lName")
                        self.defaults.set("\(license)\(state)", forKey: "plate")

                        let user: [Any]  = [
                            [
                                "uid": userId,
                                "First": fName,
                                "Last": lName,
                                "Plate": "\(license)\(state)"
                            ]
                        ]
                        self.socket.emit("newUser", user)
                        
                        weak var pvc = self.presentingViewController
                        
                        //dismisses to sign in, then segues to main
                        self.dismiss(animated: true) {
                            pvc?.performSegue(withIdentifier: "toMain", sender: nil)
                        }
                            
                        /*
                        self.db.collection("users").document(userId!).setData([
                            "first": fName,
                            "last": lName,
                            "license": "\(license)\(state)"
                        ]) { err in
                            if let err = err {
                                print("Error writing document: \(err)")
                            } else {
                                weak var pvc = self.presentingViewController
                                
                                self.dismiss(animated: true) { //dismisses to sign in, then segues to main
                                    pvc?.performSegue(withIdentifier: "toMain", sender: nil)
                                }
                            }
                        }
                        */
                    }
                }
            }
            
            else {
                var message = ""
                
                if !fNameValid || !lNameValid {
                    message += "Please enter a valid name. "
                }
                if !emailValid {
                    message += "Please enter a valid email address. "
                }
                if !passValid {
                    message += "Please enter a secure password. "
                }
                if !licenseValid {
                    message += "Please enter a valid license plate number. "
                }
                if !stateValid {
                    message += "Please enter a valid 2 letter state/province abbreviation."
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
            let nextResponder = textField.superview?.viewWithTag(nextTag) as UIResponder!
            
            textField.resignFirstResponder()
        }
        
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        scrollView.setContentOffset(CGPoint(x: 0, y: 100), animated: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
}
