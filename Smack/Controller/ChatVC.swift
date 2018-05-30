//
//  ChatVC.swift
//  Smack
//
//  Created by Christian Solis-Shepperson on 5/19/18.
//  Copyright © 2018 Christian Solis-Shepperson. All rights reserved.
//

import UIKit

class ChatVC: UIViewController {

    //Outlets
    @IBOutlet weak var menuBtn: UIButton!
    @IBOutlet weak var channelNameLbl: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //using SWRevealController method to move the view controller as an overlay
        menuBtn.addTarget(self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)), for: .touchUpInside)
        
        //moves screen if pulled
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        //moves screen if screen is tapped
        self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        
        NotificationCenter.default.addObserver(self, selector: #selector(ChatVC.userDataDidChange(_:)), name: NOTIFY_USER_DATA_DID_CHANGE, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatVC.channelSelected(_:)), name: NOTIFY_CHANNEL_SELECTED, object: nil)
        
        
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
        }
    }
    
    @objc func channelSelected(_ notif: Notification){
        updateWithChannel()
    }
    
    func updateWithChannel(){
        let channelName = MessageService.instance.selectedChannel?.channelTitle ?? ""
        channelNameLbl.text = "#\(channelName)"
        getMessages()
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
                
            }
        }
    }

}
