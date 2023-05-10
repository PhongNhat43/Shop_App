//
//  ItemBasketTableViewCell.swift
//  Shop_App
//
//  Created by devsenior on 09/05/2023.
//

import UIKit

class ItemBasketTableViewCell: UITableViewCell {

    @IBOutlet weak var itemImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var sizeLabel: UILabel!
    
    @IBOutlet weak var price: UILabel!
    
    @IBOutlet weak var percentSaleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        itemImageView.layer.cornerRadius = 10
        itemImageView.layer.borderWidth = 1
        itemImageView.layer.borderColor = UIColor.blue.cgColor
        
        percentSaleLabel.layer.cornerRadius = 10
        percentSaleLabel.layer.borderWidth = 1
        percentSaleLabel.layer.borderColor = UIColor.blue.cgColor
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func generateCell(_ item: Item){
        nameLabel.text = item.name
        price.text = convertToCurrency(item.price)
        price.adjustsFontSizeToFitWidth = true
        percentSaleLabel.text = "-" + item.percentSale + "%"
        sizeLabel.text = item.availableSizes.joined(separator: ", ")

        
        if item.imageLinks != nil && item.imageLinks.count > 0 {
            downloadImages(imageUrls: [item.imageLinks.first!]) { (images) in
                self.itemImageView.image = images.first as? UIImage
            }
        
        }
        
        //Todo: DownLoad Image
        
    }

}
