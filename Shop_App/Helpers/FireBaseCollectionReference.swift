//
//  FireBaseCollectionReference.swift
//  Shop_App
//
//  Created by devsenior on 21/03/2023.
//

import Foundation
import FirebaseFirestore
import UIKit

enum FCollectionReference: String {
   case User
   case Category
   case Items
   case Basket
   case Admin

}

func FirebaseReference(_ collectionReference: FCollectionReference) -> CollectionReference {
    return Firestore.firestore().collection(collectionReference.rawValue)
}
