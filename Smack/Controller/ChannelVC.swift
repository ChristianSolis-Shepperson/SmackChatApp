//
//  ChannelVC.swift
//  Smack
//
//  Created by Christian Solis-Shepperson on 5/19/18.
//  Copyright © 2018 Christian Solis-Shepperson. All rights reserved.
//

import UIKit

class ChannelVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //Outlets
    @IBOutlet weak var loginBtn: UIButton!    
    @IBAction func prepereForUnwind(segue:UIStoryboardSegue){}
    @IBOutlet weak var userImg: CircleImage!
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self

        //sets the menu page to overlap and leave 60 pixels of space from the previous page to be seen
        self.revealViewController().rearViewRevealWidth = self.view.frame.size.width - 60
        
        NotificationCenter.default.addObserver(self, selector: #selector(ChannelVC.userDataDidChange(_:)), name: NOTIFY_USER_DATA_DID_CHANGE, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector (ChannelVC.channelsLoaded(_:)), name: NOTIFY_CHANNELS_LOADED, object: nil)
        
        SocketService.instance.getChannel { (success) in
            if success{
                self.tableView.reloadData()
            }
        }
        
        SocketService.instance.getChatMessage { (newMessage) in
            if newMessage.channelID != MessageService.instance.selectedChannel?.id && AuthService.instance.isLoggedIn{
                MessageService.instance.unreadChannels.append(newMessage.channelID)
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setUpUserInfo()
    }
    
    @IBAction func addChannelPressed(_ sender: Any) {
        
        if AuthService.instance.isLoggedIn{
            let addChannel = AddChannelVC()
            
            addChannel.modalPresentationStyle = .custom
            present(addChannel, animated: true, completion: nil)
        }
    }
    
    
    //Segues to the Login Page
    @IBAction func loginBtnPressed(_ sender: Any) {
        
        if AuthService.instance.isLoggedIn{
            //show profile page
            let profile = ProfileVC()
            profile.modalPresentationStyle = .custom
            present(profile, animated: true, completion: nil)
        } else {
            performSegue(withIdentifier: TO_LOGIN, sender: nil)
        }
    }
    
    //updates view if user is logged in or out
    @objc func userDataDidChange(_ notif: Notification){
        if AuthService.instance.isLoggedIn {
            loginBtn.setTitle(UserDataService.instance.name, for: .normal)
            userImg.image = UIImage(named: UserDataService.instance.avatarName)
        } else {
            loginBtn.setTitle("Login", for: .normal)
            userImg.image = UIImage(named: "menuProfileIcon")
            userImg.backgroundColor = UIColor.clear
        }
    }
    
    @objc func channelsLoaded(_ notif: Notification){
        tableView.reloadData()
    }
    
    func setUpUserInfo(){
        if AuthService.instance.isLoggedIn {
            loginBtn.setTitle(UserDataService.instance.name, for: .normal)
            userImg.image = UIImage(named: UserDataService.instance.avatarName)
        } else {
            loginBtn.setTitle("Login", for: .normal)
            userImg.image = UIImage(named: "menuProfileIcon")
            userImg.backgroundColor = UIColor.clear
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "channelCell", for: indexPath) as? ChannelCell{
     
            let channel = MessageService.instance.channels[indexPath.row]
            cell.configureCell(channel: channel)
            return cell
        } else {
            return UITableViewCell()
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MessageService.instance.channels.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let channel = MessageService.instance.channels[indexPath.row]
        MessageService.instance.selectedChannel = channel
        
        
        if MessageService.instance.unreadChannels.count > 0 {
            MessageService.instance.unreadChannels = MessageService.instance.unreadChannels.filter{$0 != channel.id}
        }
        
        let index = IndexPath(row: indexPath.row, section: 0)
        tableView.reloadRows(at: [index], with: .none)
        tableView.selectRow(at: index, animated: false, scrollPosition: .none)
        
        NotificationCenter.default.post(name: NOTIFY_CHANNEL_SELECTED, object: nil)
        
        self.revealViewController().revealToggle(animated: true)
    }
    

    
    
}
