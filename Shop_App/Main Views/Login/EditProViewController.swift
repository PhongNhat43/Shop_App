//
//  EditProViewController.swift
//  Shop_App
//
//  Created by devsenior on 12/04/2023.
//

import UIKit
import JGProgressHUD
class EditProViewController: UIViewController {

    @IBOutlet weak var nameTF: UITextField!
    
    @IBOutlet weak var surnameTF: UITextField!
    
    @IBOutlet weak var addressTF: UITextField!
    
    @IBOutlet weak var phoneTF: UITextField!
    let hud = JGProgressHUD(style: .dark)
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUserInfo()

        
    }
    
    
    @IBAction func saveBtnPressed(_ sender: Any) {
        dissmissKeyBoard()
        if textFieldsHaveText() {
            let withValues = [kFIRSTNAME: nameTF.text!, kLASTNAME: surnameTF.text!, kFULLNAME: (nameTF.text! + " " + surnameTF.text!),
                            kFULLADDRESS: addressTF.text!, kPHONE: phoneTF.text!]
            updateCurrentUserÌnFirestore(withValues: withValues) { (error) in
            
            if error == nil {
                self.hud.textLabel.text = "Updated!"
                self.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
                self.hud.show(in: self.view)
                self.hud.dismiss(afterDelay: 2.0)
            } else {
                print("Error updating user", error!.localizedDescription)
                self.hud.textLabel.text =  error!.localizedDescription
                self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
                self.hud.show(in: self.view)
                self.hud.dismiss(afterDelay: 2.0)
            }
        }
        
    } else{
        hud.textLabel.text =  "All fields are required!"
        hud.indicatorView = JGProgressHUDErrorIndicatorView()
        hud.show(in: self.view)
        hud.dismiss(afterDelay: 2.0)
      }
    }
    @IBAction func logOutBtnPressed(_ sender: Any) {
        logOutUser()
    }
    
    private func loadUserInfo(){
        if User.currentUser() != nil {
            let currentUser = User.currentUser()!
            nameTF.text = currentUser.firstName
            surnameTF.text = currentUser.lastName
            addressTF.text = currentUser.fullAddress
            phoneTF.text = currentUser.phone
        }
    }
    
    //Mark: Helper funcs
    private func dissmissKeyBoard(){
        self.view.endEditing(false)
    }
    
    private func textFieldsHaveText() -> Bool {
        return (nameTF.text != "" && surnameTF.text != "" && addressTF.text != "" && phoneTF.text != "")
    }
    
    private func logOutUser() {
        User.logOutCurrentUser { error in
            if error == nil {
              print("loggout out")
                self.navigationController?.popViewController(animated: true)
            } else {
                print("error login out", error!.localizedDescription)
            }
        }
    }
    

}
