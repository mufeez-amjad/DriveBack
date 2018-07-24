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

struct Message: Decodable {
    let with: String
    let time: String
    let message: String
}

class Main: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    //var plates = ["BYPY237 ON", "2COOL AB", "4SKULE BC"]
    //var messages = ["Lorem ipsum dolor sit amet, consectetur...", "Lorem ipsum dolor sit amet, consectetur...", "Lorem ipsum dolor sit amet, consectetur..."]
    //var times = ["9:10 pm", "9:05 pm", "9:00 pm"]
    
    var plates = [String]()
    var times = [String]()
    var messages = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        SocketIOManager.sharedInstance.requestConvos(plate: "BYPY273ON")
        
        SocketIOManager.sharedInstance.getConvos() { data in
            for index in 0...data.count {
                self.plates.append(data[index]["with"] as! String)
                self.times.append(data[index]["time"] as! String)
                self.messages.append(data[index]["message"] as! String)
            }

            DispatchQueue.main.async{
                self.tableView.reloadData()
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //if (plates.count > 0){
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "MessageCell") as! MessageTableViewCell
            cell.plate?.text = plates[indexPath.row]
            cell.message?.text = messages[indexPath.row]
            cell.time?.text = times[indexPath.row]
        //}
        /*else {
            add label for no messages
        }*/
        
        return cell
    }
    
}
