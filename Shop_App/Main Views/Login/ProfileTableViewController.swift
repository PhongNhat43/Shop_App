//
//  ProfileTableViewController.swift
//  Shop_App
//
//  Created by devsenior on 11/04/2023.
//

import UIKit

class ProfileTableViewController: UITableViewController {

    @IBOutlet weak var finishRegisterBtn: UIButton!

    @IBOutlet weak var purchaseHistoryBtn: UIButton!

    var editBtnOutlet: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //check logged in status
        checkLoginStatus()
        checkOnboaringStatus()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }


    //Helpers
    private func checkOnboaringStatus(){
        if User.currentUser() != nil {
            if User.currentUser()!.onBoard {
                finishRegisterBtn.setTitle("Account is Active", for: .normal)
                finishRegisterBtn.isEnabled = false

            } else {
                finishRegisterBtn.setTitle("Finish registration", for: .normal)
                finishRegisterBtn.isEnabled = true
                finishRegisterBtn.tintColor = .red
            }
            purchaseHistoryBtn.isEnabled = true

        } else {
            finishRegisterBtn.setTitle("Logged out", for: .normal)
            finishRegisterBtn.isEnabled = false
            purchaseHistoryBtn.isEnabled = false
        }
    }

    //Check Login
    private func checkLoginStatus(){
        if User.currentUser() == nil {
           createRightBtn(title: "Login")
        }else {
            createRightBtn(title: "Edit")
        }
    }

    private func createRightBtn(title: String){
        editBtnOutlet = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(rightBarButtonItemPressed))
        self.navigationItem.rightBarButtonItem = editBtnOutlet
    }

    @objc func rightBarButtonItemPressed(){
        if editBtnOutlet.title == "Login" {
          showLoginView()
        }else{
          goToEditProfile()
        }
    }

    private func showLoginView(){ 
        let loginView = LoginViewController(nibName: "LoginViewController", bundle: nil )
        self.present(loginView, animated: true, completion: nil)
    }

    private func goToEditProfile(){
         performSegue(withIdentifier: "profileToEdit", sender: self)
    }

    @IBAction func finishBtn(_ sender: Any) {
        let vc = OnBoardingViewController(nibName: "OnBoardingViewController", bundle: nil)
        self.navigationController?.pushViewController(vc, animated: true)

    }
    




}
