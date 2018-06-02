//
//  UserDataService.swift
//  Smack
//
//  Created by Christian Solis-Shepperson on 5/20/18.
//  Copyright © 2018 Christian Solis-Shepperson. All rights reserved.
//

import Foundation


class UserDataService{
    
    static let instance = UserDataService()
    
    public private(set) var id = ""
    public private(set) var avatarColor = ""
    public private(set) var avatarName = ""
    public private(set) var email = ""
    public private(set) var name = ""
    
    func setUserData(id:String, color:String, avatarName: String, email:String, name: String){
        self.id = id
        self.avatarColor = color
        self.avatarName = avatarName
        self.email = email
        self.name = name
    }
    
    func setAvatarName(avatarName:String){
        self.avatarName = avatarName
    }
    
    func returnUIColor()-> UIColor{
        guard
            
            let data = avatarColor.data(using: .utf8),
            
            let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [CGFloat],
            
            let r = json?[0],
            let g = json?[1],
            let b = json?[2],
            let a = json?[3]
            
            else {
                
                return UIColor.lightGray
                
        }
        
        return UIColor(red: r, green: g, blue: b, alpha:a)
    }
    
    func logoutUser(){
        id = ""
        avatarName = ""
        avatarColor = ""
        email = ""
        name = ""
        AuthService.instance.isLoggedIn = false
        AuthService.instance.userEmail = ""
        AuthService.instance.authToken = ""
        MessageService.instance.clearChannels()
        MessageService.instance.clearMessages()
    }
}
