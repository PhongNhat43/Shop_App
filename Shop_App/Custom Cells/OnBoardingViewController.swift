//
//  OnBoardingViewController.swift
//  Shop_App
//
//  Created by devsenior on 11/04/2023.
//

import UIKit
import JGProgressHUD
class OnBoardingViewController: UIViewController {
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var surnameTF: UITextField!
    @IBOutlet weak var addressTF: UITextField!
    @IBOutlet weak var doneBtn: UIButton!
    
    //Mark: Vars
    let hud = JGProgressHUD(style: .dark)

    override func viewDidLoad() {
        super.viewDidLoad()

        nameTF.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        surnameTF.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        addressTF.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
    }


    @IBAction func doneBtnPressd(_ sender: Any) {
        finishOnboarding()
    }
    
    
    
    @IBAction func cancelBtnPressd(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField){
        updateDoneButtonStatus()
    }
    
    //Mark: -helper
    private func updateDoneButtonStatus(){
        if nameTF.text != "" && surnameTF.text != "" && addressTF.text != "" {
            doneBtn.backgroundColor = .red
            doneBtn.isEnabled = true
            
        }else {
            doneBtn.backgroundColor = .gray
            doneBtn.isEnabled = false
        }
    
    }
    
    private func finishOnboarding(){
        let withValues = [kFIRSTNAME : nameTF.text!, kLASTNAME : surnameTF.text!, kONBOARD : true , kFULLADDRESS : addressTF.text!,
                           kFULLNAME : (nameTF.text! + " " + surnameTF.text!)] as [String : Any] as [String : Any] as [String : Any] as [String: Any]
        
        updateCurrentUserÌnFirestore(withValues: withValues) { (error) in
           if error == nil {
               self.hud.textLabel.text = "Updated!"
               self.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
               self.hud.show(in: self.view)
               self.hud.dismiss(afterDelay: 2.0)
               self.dismiss(animated: true, completion: nil)
           
           } else {
               print("error updating user\(error!.localizedDescription)")
               self.hud.textLabel.text = error!.localizedDescription
               self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
               self.hud.show(in: self.view)
               self.hud.dismiss(afterDelay: 2.0)
           }
        }
    }
    
}
