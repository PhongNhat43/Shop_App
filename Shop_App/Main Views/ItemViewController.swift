//
//  ItemViewController.swift
//  Shop_App
//
//  Created by devsenior on 04/04/2023.
//

import UIKit
import JGProgressHUD
class ItemViewController: UIViewController {

    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var priceLabel: UILabel!

    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBOutlet weak var percentSale: UILabel!
    
    @IBOutlet weak var pageView: UIPageControl!
    
    @IBOutlet weak var addBtn: UIButton!
    var item: Item!
    var itemImages: [UIImage] = []
    let hud = JGProgressHUD(style: .dark)
    
    var timer: Timer?
    
    var currentcellIndex = 0
    
    private let sectionInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    private let cellHeight: CGFloat = 196.0
    private let itemsPerRow: CGFloat = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        downloadPictures()
        
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action: #selector(self.backAction))]
        
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(image: UIImage(named: "basket"), style: .plain, target: self, action: #selector(self.addToBasket))]
        
        timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(slideToNext), userInfo: nil, repeats: true)
        
        pageView.numberOfPages = [itemImages].count
        
        addBtn.layer.cornerRadius = 10
        addBtn.layer.borderWidth = 1
        addBtn.layer.borderColor = UIColor.blue.cgColor
        
        
    }
    
    
    // Mark DownLoad Image
    private func downloadPictures(){
        if item != nil && item.imageLinks != nil {
            downloadImages(imageUrls: item.imageLinks) { (allImages) in
                if allImages.count > 0 {
                    self.itemImages = allImages as! [UIImage]
                    self.imageCollectionView.reloadData()
                }
            
            }
        }
    
    }
    
    // Mark setupUI
    private func setupUI(){
      if item != nil {
          self.title = item.name
          nameLabel.text = item.name
          priceLabel.text = convertToCurrency(item.price) + "VNĐ"
          descriptionTextView.text = item.description
          percentSale.text = "-" + item.percentSale + "%"
      
      }else {
          print("Loi hien thi item")
       }
    }
    
    // Timer
    @objc  func slideToNext(){
        if currentcellIndex < [itemImages].count-1
        {
          currentcellIndex = currentcellIndex + 1
        }
        else
        {
          currentcellIndex = 0
        }
        
        pageView.currentPage = currentcellIndex
        
        imageCollectionView.scrollToItem(at: IndexPath(item: currentcellIndex, section: 0), at: .right, animated: true)
    
    }
    
    @objc func backAction(){
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func addToBasket(){
        if User.currentUser() != nil {
            dowloadBasketFromFirestore((User.currentId())) { (basket) in
                if basket == nil {
                    self.createNewBasket()
                } else {
                    basket!.itemIds.append(self.item.id)
                    self.updateBasket(basket: basket!, withValues: [kITEMIDS: basket!.itemIds])
                }
            }
            
        } else {
            showLoginView()
        }
    
    }
    
    //Mark : Add to basket
    private func createNewBasket(){
      let newBasket = Basket()
        newBasket.id = UUID().uuidString
        newBasket.ownerId = User.currentId()
        newBasket.itemIds = [self.item.id]
        saveBasketToFirstore(newBasket)
        
        self.hud.textLabel.text = "Added to Basket"
        self.hud.show(in: self.view)
        self.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
        self.hud.dismiss(afterDelay: 2.0)
    }
    
    @IBAction func addToCart(_ sender: Any) {
        addToBasket()
    }
    
    
    private func updateBasket(basket: Basket, withValues:[String: Any]){
        updateBasketInFirestore(basket, withValues: withValues) { (error) in
            if error != nil {
                self.hud.textLabel.text = "Error: \(error!.localizedDescription)"
                self.hud.show(in: self.view)
                self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
                self.hud.dismiss(afterDelay: 2.0)
                print("error updateting Basket", error!.localizedDescription)
            } else {
                self.hud.textLabel.text = "Added to Basket"
                self.hud.show(in: self.view)
                self.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
                self.hud.dismiss(afterDelay: 2.0)

            }
        }
    
    }
    
    private func showLoginView(){
        let loginView = LoginViewController(nibName: "LoginViewController", bundle: nil )
        present(loginView, animated: true, completion: nil)
    }

}

extension ItemViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemImages.count == 0 ? 1 : itemImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ImageCollectionViewCell
        if itemImages.count > 0 {
            cell.setupID(itemImage: itemImages[indexPath.row])
        }
        
        return cell
    }
    


}

extension ItemViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let availableWidth = collectionView.frame.width - sectionInsets.left
        return CGSize(width: availableWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}

//
