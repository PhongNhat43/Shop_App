//
//  ItemsTableViewController.swift
//  Shop_App
//
//  Created by devsenior on 31/03/2023.
//

import UIKit
import FirebaseAuth
import EmptyDataSet_Swift
class ItemsTableViewController: UITableViewController {
    
    @IBOutlet weak var addItemBtn: UIBarButtonItem!
    //Mark: Vars
    var category: Category?
    
    var itemArray: [Item] = []
    
    //Mark: View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        addItemBtn.isEnabled = false
        addItemBtn.tintColor = .clear

        
        tableView.tableFooterView = UIView()
        self.title = category?.name
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
    }
    
    func deleteItemFromFirebase(_ item: Item, completion: @escaping (_ success: Bool) -> Void) {
        FirebaseReference(.Items).document(item.id).delete { error in
            if let error = error {
                print("Error deleting item from Firestore: \(error.localizedDescription)")
                completion(false)
            } else {
                print("Item deleted successfully from Firestore")
                completion(true)
            }
        }
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if category != nil {
          loadItems()
        }
        
        if let currentUser = Auth.auth().currentUser,
            let email = currentUser.email,
            email == "jayce27052000@gmail.com" {
                // show the addCategoryOutlet if the user is an admin
            addItemBtn.isEnabled = true
            addItemBtn.tintColor = UIColor.systemBlue
        }
        
        
    }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return itemArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ItemTableViewCell
        cell.generateCell(itemArray[indexPath.row])
        cell.layer.cornerRadius = 10
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.blue.cgColor
        return cell
    }
    // Mark: - TableView Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        showItemView(itemArray[indexPath.row])
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
          return true
    }

    
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            let itemtoDelete = itemArray[indexPath.row]
//
//            itemArray.remove(at: indexPath.row)
//            tableView.reloadData()
//
//
//
//        }
//    }
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            let itemToDelete = itemArray[indexPath.row]
//
//            // Remove the item from the data source
//            itemArray.remove(at: indexPath.row)
//
//            // Delete the item from Firebase
//            deleteItemFromFirebase(itemToDelete) { success in
//                if success {
//                    // Remove the row from the table view
//                    tableView.deleteRows(at: [indexPath], with: .fade)
//                } else {
//                    // If deletion failed, add the item back to the data source and reload the table view
//                    self.itemArray.insert(itemToDelete, at: indexPath.row)
//                    tableView.reloadData()
//                }
//            }
//        }
//    }
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if let currentUser = Auth.auth().currentUser,
//            let email = currentUser.email,
//            email == "jayce27052000@gmail.com" {
//            if editingStyle == .delete {
//                let itemToDelete = itemArray[indexPath.row]
//
//                // Remove the item from the data source
//                itemArray.remove(at: indexPath.row)
//
//                // Delete the item from Firebase
//                deleteItemFromFirebase(itemToDelete) { success in
//                    if success {
//                        // Remove the row from the table view
//                        tableView.deleteRows(at: [indexPath], with: .fade)
//                    } else {
//                        // If deletion failed, add the item back to the data source and reload the table view
//                        self.itemArray.insert(itemToDelete, at: indexPath.row)
//                        tableView.reloadData()
//                    }
//                }
//            }
//
//        }
//
//
//    }



    
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "itemToAddItemSeg" {
            let vc = segue.destination as! AddItemViewController
            vc.category = category!
        }
    }
    
    private func showItemView(_ item: Item) {
        let itemVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "itemView") as! ItemViewController
        itemVC.item = item
        self.navigationController?.pushViewController(itemVC, animated: true)
    }
    
    //Mark: load Items
    private func loadItems(){
        downloadItemsFromFireBase(category!.id) { (allItems) in
            self.itemArray = allItems
            self.tableView.reloadData()
        
        }
    }
    

}

extension ItemsTableViewController: EmptyDataSetSource, EmptyDataSetDelegate {
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "No items to display")
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return UIImage(named: "emptyData")
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "Please check back later")
    }

}
