//
//  ManagerCategoryViewController.swift
//  Shop_App
//
//  Created by devsenior on 10/05/2023.
//

import UIKit

class ManagerCategoryViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var countLabel: UILabel!
    
    var categories: [Category?] = []

    
    var selectedCategoryIndex: Int?


    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        dowloadCategoryFromFireBase { (categoryArray) in
                    self.categories = categoryArray
                    self.tableView.reloadData()
                    self.countLabel.text = "Chúng ta đang có : \(self.categories.count) danh mục " // set label text here
                }
       
    }
    
    func showEditCategoryAlert(category: Category) {
        let alertController = UIAlertController(title: "Edit Category Name", message: nil, preferredStyle: .alert)

        alertController.addTextField { (textField) in
            textField.text = category.name
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let saveAction = UIAlertAction(title: "Save", style: .default) { (action) in
            if let textField = alertController.textFields?.first, let categoryName = textField.text {
                category.name = categoryName
                // Update category name in Firebase
                updateCategory(name: categoryName, category)
                // Reload table view to show updated data
                self.tableView.reloadData()
            }
        }

        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)

        present(alertController, animated: true, completion: nil)
    }


}

extension ManagerCategoryViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ManagerCategoryTableViewCell
        cell.generateCell(categories[indexPath.row]!)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCategoryIndex = indexPath.row
        if let selectedCategoryIndex = selectedCategoryIndex, let category = categories[selectedCategoryIndex] {
            showEditCategoryAlert(category: category)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let categoryToDelete = categories[indexPath.row]
            categories.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            // Xoá category khỏi Firebase
            FirebaseReference(.Category).document(categoryToDelete!.id).delete()
        }
    }
    
    func reloadCategories() {
        dowloadCategoryFromFireBase { categories in
            self.categories = categories
            DispatchQueue.main.async {
                self.countLabel.text = "Chúng ta đang có : \(self.categories.count) danh mục"
            }
        }
    }





    


}
