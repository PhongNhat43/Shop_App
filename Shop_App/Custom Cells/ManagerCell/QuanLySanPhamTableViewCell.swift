//
//  QuanLySanPhamTableViewCell.swift
//  Shop_App
//
//  Created by devsenior on 10/05/2023.
//

import UIKit

class QuanLySanPhamTableViewCell: UITableViewCell {
  

    @IBOutlet weak var imageItem: UIImageView!
    
    @IBOutlet weak var nameItemLB: UILabel!
    
    @IBOutlet weak var priceItemLB: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)


    }
    
    func generateCell(_ item: Item){
        nameItemLB.text = item.name
        priceItemLB.text = convertToCurrency(item.price) + "VNĐ"
        priceItemLB.adjustsFontSizeToFitWidth = true

        if item.imageLinks != nil && item.imageLinks.count > 0 {
            downloadImages(imageUrls: [item.imageLinks.first!]) { (images) in
                self.imageItem.image = images.first as? UIImage
            }

        }



    }
    
   

}
