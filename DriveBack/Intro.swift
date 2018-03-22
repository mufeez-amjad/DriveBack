//
//  ViewController.swift
//  DriveBack
//
//  Created by Mufeez Amjad on 2018-03-20.
//  Copyright © 2018 Mufeez Amjad. All rights reserved.
//

import UIKit

class Intro: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipedLeft))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func swipedLeft() {
        performSegue(withIdentifier: "toSignIn", sender: self)
    }
    
}

