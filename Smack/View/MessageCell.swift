//
//  MessageCell.swift
//  Smack
//
//  Created by Christian Solis-Shepperson on 6/2/18.
//  Copyright © 2018 Christian Solis-Shepperson. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {

    
    //Outlets
    @IBOutlet weak var userImg: CircleImage!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var timeStampLbl: UILabel!
    @IBOutlet weak var messageBodyLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(message:Message){
        messageBodyLbl.text = message.message
        userNameLbl.text = message.userName
        userImg.image = UIImage(named: message.userAvatar)
        userImg.backgroundColor = UserDataService.instance.returnUIColor()
        
        
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ" // date format
//        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone!
//        let date = dateFormatter.date(from: timestamp)
//        timeStampLbl.text = date
        
        
        guard var isoDate = message.timeStamp else {return}
        let end = isoDate.index(isoDate.endIndex, offsetBy: -5)
        isoDate = String(isoDate[..<end])
        
        let isoFormatter = ISO8601DateFormatter()
        let chatDate = isoFormatter.date(from: isoDate.appending("Z"))
        
        let newFormatter = DateFormatter()
        newFormatter.dateFormat = "MMM d, h:mm a"
        
        if let finalDate = chatDate{
            let finalDate = newFormatter.string(from: finalDate)
            timeStampLbl.text = finalDate
        }
        
    }

}
