//
//  CategoryCollectionViewCell.swift
//  Shop_App
//
//  Created by devsenior on 21/03/2023.
//

import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    func generateCell(_ category: Category){
        nameLabel.text = category.name
        
        if category.imageCategoryLinks != nil && category.imageCategoryLinks.count > 0 {
            downloadImages(imageUrls: [category.imageCategoryLinks.first!]) { (images) in
                self.imageView.image = images.first as? UIImage
            }
        }
    }
}
