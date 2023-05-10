//
//  Basket.swift
//  Shop_App
//
//  Created by devsenior on 05/04/2023.
//

import Foundation

class Basket {
    var id: String!
    var ownerId: String!
    var itemIds: [String]!
    
    init(){
     
    }
    
    init(_dicionary: NSDictionary){
     id = _dicionary[kOBJECTID] as? String
     ownerId = _dicionary[kOWNERID] as? String
     itemIds = _dicionary[kITEMIDS] as? [String]
        
    }

}
func dowloadBasketFromFirestore(_ ownerId: String, completion: @escaping (_ basket: Basket?)-> Void) {
    FirebaseReference(.Basket).whereField(kOWNERID, isEqualTo: ownerId).getDocuments { (snapshot, error) in
        guard let snapshot = snapshot else {
          completion(nil)
            return
          
        }
        
        if !snapshot.isEmpty && snapshot.documents.count > 0 {
            let basket = Basket(_dicionary: snapshot.documents.first!.data() as NSDictionary)
            completion(basket)
        } else {
          completion(nil)
        }
        
        
    }
}

func saveBasketToFirstore(_ basket: Basket){
    FirebaseReference(.Basket).document(basket.id).setData(basketDictionaryFrom(basket) as! [String: Any])
}

func basketDictionaryFrom(_ basket: Basket) -> NSDictionary {
    return NSDictionary(objects: [basket.id, basket.ownerId, basket.itemIds], forKeys: [kOBJECTID as NSCopying, kOWNERID as NSCopying, kITEMIDS as NSCopying])

}

func updateBasketInFirestore(_ basket: Basket, withValues: [String: Any], completion: @escaping (_ error: Error?) -> Void){
    FirebaseReference(.Basket).document(basket.id).updateData(withValues) { (error) in
        completion(error)
    }
}
