//
//  Main.swift
//  DriveBack
//
//  Created by Mufeez Amjad on 2018-03-30.
//  Copyright © 2018 Mufeez Amjad. All rights reserved.
//

import Foundation
import UIKit
import SocketIO


class MessageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var plate: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var message: UILabel!
    
}

class Main: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var plates = ["BYPY237 ON", "2COOL AB", "4SKULE BC"]
    var messages = ["Lorem ipsum dolor sit amet, consectetur...", "Lorem ipsum dolor sit amet, consectetur...", "Lorem ipsum dolor sit amet, consectetur..."]
    var times = ["9:10 pm", "9:05 pm", "9:00 pm"]
    
    let manager = SocketManager(socketURL: URL(string: "http://localhost:3000")!, config: [.log(true), .compress])
    var socket: SocketIOClient!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        socket = manager.defaultSocket
    }
    
    override func viewDidAppear(_ animated: Bool) {
        socket.connect()
        
        self.socket.on("connect") {data, ack in
            print("socket connected")
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "MessageCell") as! MessageTableViewCell
        cell.plate?.text = plates[indexPath.row]
        cell.message?.text = messages[indexPath.row]
        cell.time?.text = times[indexPath.row]
        
        return cell
    }
    
}
