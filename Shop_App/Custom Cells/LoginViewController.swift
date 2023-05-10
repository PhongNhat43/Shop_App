//
//  LoginViewController.swift
//  Shop_App
//
//  Created by devsenior on 06/04/2023.
//

import UIKit
import JGProgressHUD
import NVActivityIndicatorView
class LoginViewController: UIViewController {

    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var resendBtn: UIButton!
    @IBOutlet weak var passWordTF: UITextField!
    
    //Mark: Vars
    let hud = JGProgressHUD(style: .dark)
    var activityIdicator: NVActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        activityIdicator = NVActivityIndicatorView(frame: CGRect(x: self.view.frame.width / 2 - 30, y: self.view.frame.height / 2 - 30, width: 60.0, height: 60.0), type: .ballPulse, color: UIColor(red: 0.9998469949, green: 0.4941213727, blue: 0.4734867811, alpha: 1.0), padding: nil)
    }

  
    @IBAction func loginBtn(_ sender: Any) {
        print("Login")
        if textFieldsHaveText() {
           loginUser()
           
        } else {
            hud.textLabel.text = "Please write your email"
            hud.indicatorView = JGProgressHUDErrorIndicatorView()
            hud.show(in: self.view)
            hud.dismiss(afterDelay: 2.0)
        }
    }
    
    
    @IBAction func registerBtn(_ sender: Any) {
        print("Register")
        if textFieldsHaveText() {
           registerUser()
        } else {
            hud.textLabel.text = "All the fields are required"
            hud.indicatorView = JGProgressHUDErrorIndicatorView()
            hud.show(in: self.view)
            hud.dismiss(afterDelay: 2.0)
        }
    }
    
    
    @IBAction func forgotBtn(_ sender: Any) {
        print("Forgot pass")
        if emailTF.text != "" {
          resetThePassWord()
        }else {
            hud.textLabel.text = "Please insert email!"
            hud.indicatorView = JGProgressHUDErrorIndicatorView()
            hud.show(in: self.view)
            hud.dismiss(afterDelay: 2.0)
        }
    }
    
    
    @IBAction func cancelBtn(_ sender: Any) {
        dismissView()
        print("Cancel")
    }
    
    
    @IBAction func resendBtnPressed(_ sender: Any) {
        print("resend email")
        User.resendVerificationEmail(email: emailTF.text!) { error in
            print("error resening email", error?.localizedDescription)
        }
    }
    
    //Mark: Login User
    private func loginUser(){
       showLoadingIdicator()
        
        User.loginUserWith(email: emailTF.text!, password: passWordTF.text!) { (error, isEmailVerified) in
            if error == nil {
               if isEmailVerified {
                   print("Email is Verified ")
                   self.dismissView()
               } else {
                   self.hud.textLabel.text = "Please verify your email"
                   self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
                   self.hud.show(in: self.view)
                   self.hud.dismiss(afterDelay: 2.0)
                   self.resendBtn.isHidden = false
               
               }
            
            } else {
                print("error loging in the user", error!.localizedDescription)
                self.hud.textLabel.text = error!.localizedDescription
                self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
                self.hud.show(in: self.view)
                self.hud.dismiss(afterDelay: 2.0)
                
            }
            self.hideLoadingIdicator()
        }
    }
    
    //Mark: Login Admin
//    private func loginAdmin() {
//        showLoadingIdicator()
//
//        Admin.loginAdminWith(email: emailTF.text!, password: passWordTF.text!) { (error) in
//            if error == nil {
//                print("Admin login successful")
//                self.dismissView()
//            } else {
//                print("Error logging in admin: ", error!.localizedDescription)
//                self.hud.textLabel.text = error!.localizedDescription
//                self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
//                self.hud.show(in: self.view)
//                self.hud.dismiss(afterDelay: 2.0)
//            }
//
//            self.hideLoadingIdicator()
//        }
//    }

    
    
    
    //Mark: Register
    private func registerUser(){
       showLoadingIdicator()
        User.registerUserWith(email: emailTF.text!, password: passWordTF.text!) { [self] (error) in
            if error == nil {
                self.hud.textLabel.text = "Varification Email sent"
                self.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
                self.hud.show(in: self.view)
                self.hud.dismiss(afterDelay: 2.0)
            } else {
                print("error register", error!.localizedDescription)
                self.hud.textLabel.text = error!.localizedDescription
                self.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
                self.hud.show(in: self.view)
                self.hud.dismiss(afterDelay: 2.0)
            }
            
            self.hideLoadingIdicator()
        }
    }
    
    //Mark: helpers
    private func textFieldsHaveText() -> Bool {
        return (emailTF.text != "" && passWordTF.text != "")
    }
    
    private func dismissView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func showLoadingIdicator(){
       if activityIdicator != nil {
           self.view.addSubview(activityIdicator!)
           activityIdicator!.startAnimating()
       }
    
    }
    
    private func hideLoadingIdicator(){
      if activityIdicator != nil {
          activityIdicator!.removeFromSuperview()
          activityIdicator!.startAnimating()
      
      }
    }
    
    private func resetThePassWord() {
        User.resetPasswordFor(email: emailTF.text!) { error in
            if error == nil {
                self.hud.textLabel.text = "Reset password email sent"
                self.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
                self.hud.show(in: self.view)
                self.hud.dismiss(afterDelay: 2.0)
            } else {
                self.hud.textLabel.text = error!.localizedDescription
                self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
                self.hud.show(in: self.view)
                self.hud.dismiss(afterDelay: 2.0)
            }
        }
    }
    
}
