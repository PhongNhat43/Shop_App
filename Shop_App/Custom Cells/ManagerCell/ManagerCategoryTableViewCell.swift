//
//  ManagerCategoryTableViewCell.swift
//  Shop_App
//
//  Created by devsenior on 10/05/2023.
//

import UIKit

class ManagerCategoryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imageCategory: UIImageView!
    
    @IBOutlet weak var nameCategoryLB: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

       
    }
    func generateCell(_ category: Category){
        nameCategoryLB.text = category.name
        
        if category.imageCategoryLinks != nil && category.imageCategoryLinks.count > 0 {
            downloadImages(imageUrls: [category.imageCategoryLinks.first!]) { (images) in
                DispatchQueue.main.async {
                    self.imageCategory.image = images.first as? UIImage
                }
            }
        }
    }

    
}
