//
//  Category.swift
//  Shop_App
//
//  Created by devsenior on 22/03/2023.
//

import Foundation
import UIKit

class Category {
    var id: String!
    var name: String!
    var imageCategoryLinks: [String]!
//    var id: String
//    var name: String
//    var image: UIImage?
//    var imageName: String?
    
    
//    init(_name: String, _imageName: String) {
//       id = ""
//       name = _name
//       imageName = _imageName
//       image = UIImage(named: _imageName)

//    }
    
    init(){


    }
    
    
    init(_dictionary: NSDictionary) {
      id = _dictionary[kOBJECTID] as? String
      name = _dictionary[kNAME] as? String
      imageCategoryLinks = _dictionary[kIMAGCATEGORYELINKS] as? [String]
    }

  

//    init(_dictionary: NSDictionary) {
//      id = _dictionary[kOBJECTID] as! String
//      name = _dictionary[kNAME] as! String
//      image = UIImage(named: _dictionary[kIMAGENAME] as? String ?? "")
//    }

}
// Mark: Save category function

func saveCategoryToFirebase(_ category: Category){

   FirebaseReference(.Category).document(category.id).setData(categoryDictionaryFrom(category) as! [String: Any])

}


func categoryDictionaryFrom(_ category: Category) -> NSDictionary {
  return NSDictionary(objects: [category.id, category.name, category.imageCategoryLinks], forKeys: [kOBJECTID as NSCopying, kNAME as NSCopying, kIMAGCATEGORYELINKS as NSCopying])


}

//func categoryDictionaryFrom(_ category: Category) -> NSDictionary {
//    return NSDictionary(objects: [category.id, category.name, category.imageName], forKeys: [kOBJECTID as NSCopying, kNAME as NSCopying, kIMAGENAME as NSCopying])
//
//}

// Mark: Dowload category from firebase



func dowloadCategoryFromFireBase(completion: @escaping (_ categoryArray: [Category]) -> Void) {
    var categoryArray: [Category] = []
    
    FirebaseReference(.Category).getDocuments { (snapshot, error) in
       guard let snapshot = snapshot else {
         completion(categoryArray)
           return
       }
        
        if !snapshot.isEmpty {
            for categoryDict in snapshot.documents {
                categoryArray.append(Category(_dictionary: categoryDict.data() as NSDictionary))
            }
        }
        completion(categoryArray)
    }
}

func dowloadCategories(_ withIds: [String], completion: @escaping (_ categoryArray: [Category]) -> Void) {

     var count = 0
    var categoryArray: [Category] = []

    if withIds.count > 0 {
      for categoryId in withIds {
          FirebaseReference(.Category).document(categoryId).getDocument { (snapshot, error) in
              guard let snapshot = snapshot else {
                completion(categoryArray)
                  return
              }
              if snapshot.exists {
                  categoryArray.append(Category(_dictionary: snapshot.data()! as NSDictionary))
                  count += 1
              } else{
                 completion(categoryArray)
              }

              if count == withIds.count {
                completion(categoryArray)
              }
          }

      }
    } else {
      completion(categoryArray)
    }

}

func updateCategory(name: String, _ category: Category) {
    category.name = name
    let data = categoryDictionaryFrom(category) as! [String: Any]
    FirebaseReference(.Category).document(category.id).updateData(data)
}

func deleteCategoryFromFirebase(_ category: Category) {
    FirebaseReference(.Category).document(category.id).delete { (error) in
        if let error = error {
            print("Error deleting category: \(error.localizedDescription)")
        } else {
            print("Category deleted successfully!")
        }
    }
}






