//
//  ImageCollectionViewCell.swift
//  Shop_App
//
//  Created by devsenior on 04/04/2023.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    func setupID(itemImage: UIImage){
        imageView.image = itemImage
    }
}
