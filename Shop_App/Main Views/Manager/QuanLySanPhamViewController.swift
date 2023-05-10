//
//  QuanLySanPhamViewController.swift
//  Shop_App
//
//  Created by devsenior on 10/05/2023.
//

import UIKit

class QuanLySanPhamViewController: UIViewController {
    var category: Category?
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var countItem: UILabel!
    var item: [Item?] = []
    
    var selectedProduct: Item?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        loadAllItems { (allitems) in
            self.item = allitems
            self.tableView.reloadData()
            self.countItem.text = "Chúng ta đang có : \(self.item.count) sản phẩm " // set label text here
        }
    }
    

}

extension QuanLySanPhamViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return item.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath) as! QuanLySanPhamTableViewCell
        cell.generateCell(item[indexPath.row]!)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedProduct = item[indexPath.row]
        performSegue(withIdentifier: "ShowItem", sender: self)
    
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowItem" {
            let itemVC = segue.destination as! ItemViewController
            itemVC.item = selectedProduct
        }
    }


}
