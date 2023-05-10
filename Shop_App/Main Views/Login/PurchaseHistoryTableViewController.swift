//
//  PurchaseHistoryTableViewController.swift
//  Shop_App
//
//  Created by devsenior on 12/04/2023.
//

import UIKit
import EmptyDataSet_Swift
class PurchaseHistoryTableViewController: UITableViewController {
    
    var itemArray: [Item] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self

    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadItems()
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return itemArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ItemTableViewCell
//        cell.generateCell(itemArray[indexPath.row])
        cell.generateCell(itemArray[indexPath.row])
        return cell
    }
    
    func loadItems(){
        downloadItems(User.currentUser()!.purchasedItemIds) { (allItems) in
            self.itemArray = allItems
            print("we have \(allItems.count) purchase items")
            self.tableView.reloadData()
        }
    }
    

}

extension PurchaseHistoryTableViewController: EmptyDataSetSource, EmptyDataSetDelegate {
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
