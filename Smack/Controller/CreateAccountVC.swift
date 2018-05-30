//
//  CreateAccountVC.swift
//  Smack
//
//  Created by Christian Solis-Shepperson on 5/19/18.
//  Copyright © 2018 Christian Solis-Shepperson. All rights reserved.
//

import UIKit

class CreateAccountVC: UIViewController {

    //Outlets
    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    
    //Variables
    var avatarName = "profileDefault"
    var avatarColor = "[0.5, 0.5, 0.5, 1]"
    var bgColor: UIColor?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if UserDataService.instance.avatarName != ""{
            userImg.image = UIImage(named: UserDataService.instance.avatarName)
            avatarName = UserDataService.instance.avatarName
            
            if avatarName.contains("light") && bgColor == nil {
                userImg.backgroundColor = UIColor.lightGray
            }
        }
    }
    
    
    //may need to be taken out -- used to touch and make keyboard disappear
    func removeTextField(_ textField: UITextView) -> Bool{
        if textField == usernameTxt || textField == passwordTxt || textField == emailTxt {
            usernameTxt.becomeFirstResponder()
        }
        return true
    }
    
    @IBAction func createAccntPressed(_ sender: Any) {
        spinner.isHidden = false
        spinner.startAnimating()
        
        //gets email, password and name if not null else return
        guard let email = emailTxt.text , emailTxt.text != nil else {return}
        guard let password = passwordTxt.text, passwordTxt.text != nil else {return}
        guard let name = usernameTxt.text, usernameTxt.text != nil else {return}
        
        AuthService.instance.registerUsers(email: email, password: password) { (success) in
            if success {
                print("registered user!")
                AuthService.instance.loginUser(email: email, password: password, completion: { (success) in
                    if success {
                        print("logged in user!" ,AuthService.instance.authToken)
                        AuthService.instance.createUser(name: name, email: email, avatarName: self.avatarName, avatarColor: self.avatarColor, completion: { (success) in
                            if success {
                                self.spinner.isHidden = true
                                self.spinner.startAnimating()
                                self.performSegue(withIdentifier: UNWIND, sender: nil)
                                NotificationCenter.default.post(name: NOTIFY_USER_DATA_DID_CHANGE, object: nil)
                            }
                        })
                    }
                })
            }
        }
    }
    
    @IBAction func pickAvatarPressed(_ sender: Any) {
        performSegue(withIdentifier: TO_AVATAR_PICKER, sender: nil)
        
    }
    
    @IBAction func pickBGColorPressed(_ sender: Any) {
        let r = CGFloat(arc4random_uniform(255)) /  255
        let g = CGFloat(arc4random_uniform(255)) /  255
        let b = CGFloat(arc4random_uniform(255)) /  255
        
        bgColor = UIColor(displayP3Red: r, green: g, blue: b, alpha: 1)
        avatarColor = "[\(r),\(g),\(b), 1]"
        UIView.animate(withDuration: 0.2){
         self.userImg.backgroundColor = self.bgColor
        }
        
    }
    

    //goes back to menu page is close button is pressed in account creation page
    @IBAction func closePressed(_ sender: Any) {
        performSegue(withIdentifier: UNWIND, sender: nil)
    }
    
    func setUpView(){
        spinner.isHidden = true
        
        usernameTxt.attributedPlaceholder = NSAttributedString(string: "username", attributes: [NSAttributedStringKey.foregroundColor: SMACK_PURPLE_COLOR_PLACEHOLDER])
        emailTxt.attributedPlaceholder = NSAttributedString(string: "email", attributes: [NSAttributedStringKey.foregroundColor: SMACK_PURPLE_COLOR_PLACEHOLDER])
        passwordTxt.attributedPlaceholder = NSAttributedString(string: "password", attributes: [NSAttributedStringKey.foregroundColor: SMACK_PURPLE_COLOR_PLACEHOLDER])
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(CreateAccountVC.handleTap))
        view.addGestureRecognizer(tap)
    }
    
    @objc func handleTap(){
        view.endEditing(true)
    }
}
