//
//  ChatVC.swift
//  Smack
//
//  Created by Christian Solis-Shepperson on 5/19/18.
//  Copyright © 2018 Christian Solis-Shepperson. All rights reserved.
//

import UIKit

class ChatVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //Outlets
    @IBOutlet weak var menuBtn: UIButton!
    @IBOutlet weak var channelNameLbl: UILabel!
    @IBOutlet weak var messageTxtBox: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var typingUserslBL: UILabel!
    
    
    //Variables
    var isTyping = false
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //will bind the keyboard to the bottom of the view,
        //allowing user to see keyboard as they type and not overlap
        view.bindToKeyboard()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableViewAutomaticDimension
        
         sendBtn.isHidden = true
        
        //removes keyboad when pressed outside of the keyboard or text box
        let tap = UITapGestureRecognizer(target: self, action: #selector(ChatVC.handleTap))
        view.addGestureRecognizer(tap)
        
        //using SWRevealController method to move the view controller as an overlay
        menuBtn.addTarget(self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)), for: .touchUpInside)
        
        //moves screen if pulled
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        //moves screen if screen is tapped
        self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        
        NotificationCenter.default.addObserver(self, selector: #selector(ChatVC.userDataDidChange(_:)), name: NOTIFY_USER_DATA_DID_CHANGE, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatVC.channelSelected(_:)), name: NOTIFY_CHANNEL_SELECTED, object: nil)
        
        SocketService.instance.getChatMessage { (newMessage) in
            if newMessage.channelID == MessageService.instance.selectedChannel?.id && AuthService.instance.isLoggedIn{
                MessageService.instance.messages.append(newMessage)
                self.tableView.reloadData()
                
                if MessageService.instance.messages.count > 0 {
                    let endIndex = IndexPath(row: MessageService.instance.messages.count - 1, section: 0)
                    
                    self.tableView.scrollToRow(at: endIndex, at: .bottom, animated: false)
                }
            }
        }
        
        
//        SocketService.instance.getChatMessage { (success) in
//            if success{
//                self.tableView.reloadData()
//
//                //scrolls to the bottom of the chat to see the most recent posting
//                if MessageService.instance.messages.count > 0 {
//                    let endIndex = IndexPath(row: MessageService.instance.messages.count - 1, section: 0)
//                    self.tableView.scrollToRow(at: endIndex, at: .bottom, animated: false)
//                }
//            }
//        }
        
        SocketService.instance.getTypingUsers { (typingUsers) in
            guard let channelId = MessageService.instance.selectedChannel?.id else {return}
            var names = ""
            var numOfTypers = 0
            
            for (typingUser,channel) in typingUsers{
                if typingUser != UserDataService.instance.name && channel == channelId {
                    if names == ""{
                        names = typingUser
                    } else {
                        names = "\(names), \(typingUser)"
                    }
                    numOfTypers += 1
                }
            }
            
            if numOfTypers > 0 && AuthService.instance.isLoggedIn{
                var verb = " is"
                if numOfTypers > 1{
                    verb = " are"
                }
                self.typingUserslBL.text = "\(names) \(verb) typing a message"
            } else {
                self.typingUserslBL.text = ""
            }
        }
        
        if AuthService.instance.isLoggedIn{
            AuthService.instance.findUserByEmail(completion: {(success) in
                NotificationCenter.default.post(name: NOTIFY_USER_DATA_DID_CHANGE, object: nil)
            })
        }
        
    }
    
    //updates view if user is logged in or out
    @objc func userDataDidChange(_ notif: Notification){
        if AuthService.instance.isLoggedIn{
            //get channels
            onLoginGetMessages()
        } else {
            channelNameLbl.text = "Please Log In"
            tableView.reloadData()
        }
    }
    
    @objc func channelSelected(_ notif: Notification){
        updateWithChannel()
    }
    
    @objc func handleTap(){
        view.endEditing(true)
    }
    
    func updateWithChannel(){
        let channelName = MessageService.instance.selectedChannel?.channelTitle ?? ""
        channelNameLbl.text = "#\(channelName)"
        getMessages()
    }
    
    @IBAction func messageBoxEditing(_ sender: Any) {
        guard let channelId = MessageService.instance.selectedChannel?.id else {return}
        if messageTxtBox.text == "" {
            isTyping = false
            sendBtn.isHidden = true
            SocketService.instance.socket.emit("stopType", UserDataService.instance.name, channelId)
        } else {
            if  isTyping == false{
                sendBtn.isHidden = false
                SocketService.instance.socket.emit("startType", UserDataService.instance.name, channelId)
            }
            isTyping = true
        }
    }
    
    
    @IBAction func sendMsgPressed(_ sender: Any) {
        if AuthService.instance.isLoggedIn{
            guard let channelId = MessageService.instance.selectedChannel?.id else {return}
            
            guard let message = messageTxtBox.text else {return}
            
            SocketService.instance.addMesage(messageBody: message, userId: UserDataService.instance.id, channelId: channelId) { (success) in
                if success{
                    self.messageTxtBox.text = ""
                    self.messageTxtBox.resignFirstResponder()
                    SocketService.instance.socket.emit("stopType", UserDataService.instance.name, channelId)
                }
            }
        }
    }
    
    func onLoginGetMessages(){
        MessageService.instance.findAllChannel { (success) in
            if success{
                if MessageService.instance.channels.count > 0 {
                    MessageService.instance.selectedChannel = MessageService.instance.channels[0]
                    self.updateWithChannel()
                } else {
                    self.channelNameLbl.text = "No channels yet!"
                }
                
            }
        }
    }
    
    func getMessages(){
        guard let channelID = MessageService.instance.selectedChannel?.id else {return}
        
        MessageService.instance.findAllMessagesForChannel(channelID: channelID) { (success) in
            if success{
                self.tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath) as? MessageCell {
            
            let message = MessageService.instance.messages[indexPath.row]
            cell.configureCell(message: message)
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MessageService.instance.messages.count
    }

}
