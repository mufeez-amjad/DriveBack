//
//  SocketIOManager.swift
//  DriveBack
//
//  Created by Mufeez Amjad on 2018-07-23.
//  Copyright © 2018 Mufeez Amjad. All rights reserved.
//

import Foundation
import SocketIO

class SocketIOManager: NSObject {
    static let sharedInstance = SocketIOManager()
    
    let manager = SocketManager(socketURL: URL(string: "http://localhost:3000")!, config: [.log(true), .compress])
    var socket: SocketIOClient!
    
    override init() {
        super.init()
        
        socket = manager.defaultSocket
    }
    
    func establishConnection(){
        socket.connect()
    }
    
    func closeConnection(){
        socket.disconnect()
    }
    
    func sendNewMessage(data: [Any]){
        socket.emit("newMessage", data)
    }
    
    func getMessageStatus(completion: @escaping (_ status: String) -> ()) {
        socket.on("messageStatus") { data, ack in
            
            guard let status = data[0] as? String else { return }
            completion(status)
        }
    }
    
    func newUser(user: [Any]){
        socket.emit("newUser", user)
    }
    
    func getUserStatus(completion: @escaping (_ status: String) -> ()) {
        socket.on("userStatus") { data, ack in
            
            guard let status = data[0] as? String else { return }
            completion(status)
        }
    }
    
    func requestConvos(plate: String) {
        socket.emit("getConvos", plate)
    }
    
    func getConvos(completion: @escaping (_ data: [[String: Any]]) -> ()) {
        socket.on("convos") { data, ack in

            guard let data = data as? [[String: Any]] else { return }
            print("received convos data")
            completion(data)
        }
    }
    
    
//    func exitChatWithNickname(nickname: String, completionHandler: () -> Void) {
//        socket.emit("exitUser", nickname)
//        completionHandler()
//    }
//
//    func getChatMessage(completionHandler: @escaping (_ messageInfo: [String: AnyObject]) -> Void){
//        socket.on("newChatMessage") { (dataArray, socketAck) in
//            var messageDictionary = [String: AnyObject]()
//            messageDictionary["nickname"] = dataArray[0] as! String as AnyObject
//            messageDictionary["message"] = dataArray[1] as! String as AnyObject
//            messageDictionary["date"] = dataArray[2] as! String as AnyObject
//
//            completionHandler(messageDictionary)
//        }
//    }
    
}
