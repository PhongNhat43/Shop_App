//
//  CategoryCollectionViewController.swift
//  Shop_App
//
//  Created by devsenior on 21/03/2023.
//

import UIKit
import FirebaseAuth
private let reuseIdentifier = "Cell"

class CategoryCollectionViewController: UICollectionViewController {
    
    
    //Mark category
    var category: Category?
    var categoryArray: [Category] = []
    
    @IBOutlet weak var addCategoryOutlet: UIBarButtonItem!
    
    private let sectionInsets = UIEdgeInsets(top: 20.0, left: 10.0, bottom: 20.0, right: 10.0)
    
    private let itemsPerRow: CGFloat = 3
    
    // View lifecyle

    override func viewDidLoad() {
        super.viewDidLoad()
        addCategoryOutlet.isEnabled = false
        addCategoryOutlet.tintColor = UIColor.clear

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadCategories()
        if let currentUser = Auth.auth().currentUser,
            let email = currentUser.email,
            email == "jayce27052000@gmail.com" {
                // show the addCategoryOutlet if the user is an admin
            addCategoryOutlet.isEnabled = true
            addCategoryOutlet.tintColor = UIColor.systemBlue
        }


    }

   

    // MARK: UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
      
        return categoryArray.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Configure the cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CategoryCollectionViewCell
        cell.generateCell(categoryArray[indexPath.row])
        cell.layer.cornerRadius = 10
        cell.layer.borderWidth = 2
        cell.layer.borderColor = UIColor.blue.cgColor
    
        return cell
    }
    
    
    
    //Mark: UICollectionView Delegate
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "categoryToItemsSeg", sender: categoryArray[indexPath.row])
    }
    
    // dowload categories
//    private func loadCategories(){
//        dowloadCategoryFromFireBase { (allcategories) in
//            print("We have", allcategories.count)
//            self.categoryArray = allcategories
//            self.collectionView.reloadData()
//        }
//
//    }
    
    private func loadCategories(){
        dowloadCategoryFromFireBase { (allCategories) in
            self.categoryArray = allCategories
            self.collectionView.reloadData()
        }
    }
    
    //Mark: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "categoryToItemsSeg" {
        
            let vc = segue.destination as! ItemsTableViewController
            vc.category = sender as! Category
        }
    }
}

extension CategoryCollectionViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
//        let availableWidth = view.frame.width - paddingSpace
//        let withPerItem = availableWidth / itemsPerRow
//        return CGSize(width: withPerItem, height: withPerItem)
        let size = (collectionView.frame.size.width-10)/2
        return CGSize(width: size, height: size)
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return sectionInsets
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return sectionInsets.left
//    }
}
