//
//  BasKetViewController.swift
//  Shop_App
//
//  Created by devsenior on 05/04/2023.
//

import UIKit
import JGProgressHUD
import SendGrid
import Firebase
import Braintree

class BasKetViewController: UIViewController {
    
    var braintreeClient: BTAPIClient!
    
    var db: Firestore!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var checkOutBtn: UIButton!
    @IBOutlet weak var totalItemsLabel: UILabel!
    @IBOutlet weak var basketTotalPriceLabel: UILabel!
    
    
    //Mark Vars
    var basket: Basket?
    var allItems: [Item] = []
    var purchasedItemIds: [String] = []
    let hud = JGProgressHUD(style: .dark)
    
    let datee = Date()
    
//    var environment: String = PayPalEnvironmentNoNetwork {
//       willSet (newEnvironment) {
//          if (newEnvironment != environment) {
//              PayPalMobile.preconnect(withEnvironment: newEnvironment)
//          }
//       }
//    }
    
//    var payPalConfig = PayPalConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = footerView
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        
//        braintreeClient = BTAPIClient(authorization: "sandbox_6mrgwshn_3mp8s3tfrkmzb6cs")
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Todo: check if user is logged in
        if User.currentUser() != nil {
            loadBasketFromFirestore()
        }else {
            self.updateTotalLabels(true)
        }
    }
    
    
    

    
    @IBAction func checkoutBtn(_ sender: Any) {
        
        if User.currentUser()!.onBoard {
            //proceed with purchase
         showOptions()
            
          
        } else {
            self.hud.textLabel.text = "Please complete you profile!"
            self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
            self.hud.show(in: self.view)
            self.hud.dismiss(afterDelay: 2.0)
        }
    }
    
    //Mark: Download basket
    private func loadBasketFromFirestore() {
        dowloadBasketFromFirestore(User.currentId()) { (basket) in
            self.basket = basket
            self.getBasketItems()
        }
    }
    
    private func getBasketItems(){
       if basket != nil {
           downloadItems(basket!.itemIds) { (allItems) in
               self.allItems = allItems
               self.updateTotalLabels(false)
               self.tableView.reloadData()
           }
       }
    }
    
    //Mark: Helper functions
    private func updateTotalLabels(_ isEmpty: Bool){
       if isEmpty {
           totalItemsLabel.text = "0"
       } else {
           basketTotalPriceLabel.text = "\(allItems.count)"
           totalItemsLabel.text = returnBasketTotalPrice()
           
       }
        checkoutButtonStatusUpdate()
    }
    
    private func returnBasketTotalPrice() -> String {
        var totalPrice = 0.0
        
        for item in allItems {
            totalPrice += item.price
        }
        
        return "Total price:" + convertToCurrency(totalPrice)
    }
    
    //Mark: Helper functions
    
    func tempFunction(){
        for item in allItems {
            purchasedItemIds.append(item.id)
        }
    }
    
    private func emptyTheBasket(){
        purchasedItemIds.removeAll()
        allItems.removeAll()
        tableView.reloadData()
        
        basket!.itemIds = []
        
        updateBasketInFirestore(basket!, withValues: [kITEMIDS: basket!.itemIds]) { error in
            if error != nil {
                print("Error updatig basket", error!.localizedDescription)
            }
            self.getBasketItems()
        }
    }
    
//    private func addItemsToPurchaseHistory(_ itemIds: [String]){
//        if User.currentUser() != nil {
//            let newItemIds = User.currentUser()!.purchasedItemIds + itemIds
//            updateCurrentUserÌnFirestore(withValues: [kPURCHASEDITEMIDS: newItemIds]) { (error) in
//                if error != nil {
//                    print("Error adding purchased items", error!.localizedDescription)
//                }
//            }
//        }
//    }
    
    private func addItemsToPurchaseHistory(_ itemIds: [String]){
        if let currentUser = User.currentUser() {
            let newItemIds = currentUser.purchasedItemIds + itemIds
            let purchaseDate = Date()
            let newItemIdsWithTimestamp = newItemIds.map { ["id": $0, "timestamp": purchaseDate] }
            updateCurrentUserÌnFirestore(withValues: [kPURCHASEDITEMIDS: newItemIdsWithTimestamp]) { (error) in
                if error != nil {
                    print("Error adding purchased items", error!.localizedDescription)
                }
            }
        }
    }
    

    
    //Mark: - Control checkoutButton
    private func checkoutButtonStatusUpdate(){
        checkOutBtn.isEnabled = allItems.count > 0
        
        if checkOutBtn.isEnabled {
            checkOutBtn.backgroundColor = .red
        }else {
           disableCheckoutButton()
           
        }
    }
    
    private func disableCheckoutButton() {
        checkOutBtn.isEnabled = false
        checkOutBtn.backgroundColor = .gray
    }
    
    private func removeItemFromBasket(itemId: String) {
        for i in 0..<basket!.itemIds.count {
            if itemId == basket!.itemIds[i] {
                basket!.itemIds.remove(at: i)
                return
            }
        }
    }
    
    private func showItemView(withItem: Item){
        let itemVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "itemView") as! ItemViewController
        itemVC.item = withItem
        self.navigationController?.pushViewController(itemVC, animated: true)
    }
    
    private func showOptions(){
        let alertController = UIAlertController(title: "Phương thức thanh toán", message: "Chọn phương thức" ,preferredStyle: .actionSheet)
       
        let payAction = UIAlertAction(title: "Thanh toán sau khi nhận hàng", style: .default) { (action) in
            self.tempFunction()
            self.addItemsToPurchaseHistory(self.purchasedItemIds)
            self.emptyTheBasket()
            guard let currentUser = Auth.auth().currentUser else {
                print("User not signed in")
                return
            }
            
            let userId = currentUser.uid
            
            let db = Firestore.firestore()
            let userRef = db.collection("User").document(userId)
           
              
            userRef.getDocument { (document, error) in
                  guard let document = document, document.exists else {
                      print("User not found")
                      return
                  }
                

                  let fullName = document.data()?["fullName"] as? String ?? ""
                  let purchasedItemIds = document.data()?["purchasedItemIds"] as? [String] ?? []
                  let email = document.data()?["email"] as? String ?? ""
                  let fullAddress = document.data()?["fullAddress"] as? String ?? ""
                  let emailUser =  document.data()?["email"] as? String ?? ""
                  let date = Date()
                  let phone = document.data()?["phone"] as? String ?? ""
                

                 

                  let emailManager = EmailManger()
                emailManager.WelcomingEmail(fullName: fullName, email: email, emailUser: emailUser, fullAddress: fullAddress, date: date, purchasedItemIds: purchasedItemIds, phone: phone) { result in
                      switch result {
                      case .success:
                          print("Email sent successfully")
                      case .failure(let error):
                          print("Failed to send email with error: \(error.localizedDescription)")
                      }
                  }
              
            }
        }
        
        let paypalAction = UIAlertAction(title: "Thanh toán bằng Paypal", style: .default) { (action) in
            self.paypal()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(payAction)
        alertController.addAction(paypalAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
        
        
    }
    
    //PayPal

    private func paypal(){
//        let payPayDriver = BTPayPalDriver(apiClient: braintreeClient)
//        payPayDriver.viewControllerPresentingDelegate = self
//        payPayDriver.appSwitchDelegate = self
//
//        let request = BTPayPalRequest(amount: "2.32")
//        request.currencyCode = "USD"
//        payPayDriver.requestOneTimePayment(request) { (tokenizedPayPalAccount, error) in
//            if let tokenizedPayPalAccount = tokenizedPayPalAccount {
//                print("Got a nonce: \(tokenizedPayPalAccount.nonce)")
//
//                //access additional information
//                let email = tokenizedPayPalAccount.email
//                let firstName = tokenizedPayPalAccount.firstName
//                let lastName = tokenizedPayPalAccount.lastName
//                let phone = tokenizedPayPalAccount.phone
//
//                //see btpostAddress.h
//                let billingAddress = tokenizedPayPalAccount.billingAddress
//                let shippingAddress = tokenizedPayPalAccount.shippingAddress
//
//
//            } else if let error = error {
//
//            } else {
//
//            }
//        }
    }
    
}

extension BasKetViewController: UITableViewDataSource, UIApplicationDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ItemTableViewCell
        cell.generateCell(allItems[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let itemtoDelete = allItems[indexPath.row]

            allItems.remove(at: indexPath.row)
            tableView.reloadData()

            removeItemFromBasket(itemId: itemtoDelete.id)
            updateBasketInFirestore(basket!, withValues: [kITEMIDS: basket!.itemIds]) { (error) in
                if error != nil {
                    print("error updating the basket", error?.localizedDescription)
                }
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        showItemView(withItem: allItems[indexPath.row])
     
    }
    
}

//extension BasKetViewController: PayPalPaymentDelegate {
//    func payPalPaymentDidCancel(_ paymentViewController: PayPalPaymentViewController) {
//        print("pay pal payment cancelled")
//        paymentViewController.dismiss(animated: true, completion: nil)
//    }
//
//    func payPalPaymentViewController(_ paymentViewController: PayPalPaymentViewController, didComplete completedPayment: PayPalPayment) {
//        paymentViewController.dismiss(animated: true) {
//            self.addItemsToPurchaseHistory(self.purchasedItemIds)
//            self.emptyTheBasket()
//        }
//    }
//
//
//
//}



//extension BasKetViewController: BTViewControllerPresentingDelegate {
//    func paymentDriver(_ driver: Any, requestsPresentationOf viewController: UIViewController) {
//
//    }
//
//    func paymentDriver(_ driver: Any, requestsDismissalOf viewController: UIViewController) {
//
//    }
//
//
//
//}
//
//extension BasKetViewController: BTAppSwitchDelegate {
//    func appSwitcherWillPerformAppSwitch(_ appSwitcher: Any) {
//
//    }
//
//    func appSwitcher(_ appSwitcher: Any, didPerformSwitchTo target: BTAppSwitchTarget) {
//
//    }
//
//    func appSwitcherWillProcessPaymentInfo(_ appSwitcher: Any) {
//
//    }
//
//
//}




