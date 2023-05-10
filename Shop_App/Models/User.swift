//
//  User.swift
//  Shop_App
//
//  Created by devsenior on 07/04/2023.
//

import Foundation
import FirebaseAuth
class User {
    let objecId: String
    let email: String
    let firstName: String
    let lastName: String
    let fullName: String
    let phone: String
    var purchasedItemIds: [String]
    
    
    var fullAddress: String?
    var onBoard: Bool
    var isAdmin: Bool
    
    init(_objectId: String, _email: String, _firstName: String, _lastName: String, _phone: String){
       objecId = _objectId
       email = _email
        firstName = _firstName
        lastName = _lastName
        fullName = _firstName + _lastName
        fullAddress = ""
        phone = _phone
        onBoard = false
        isAdmin = false
        purchasedItemIds = []
       
    
    }
    
    init(_dictionary: NSDictionary){
       objecId = _dictionary[kOBJECTID] as! String
       
        if let mail = _dictionary[kEMAIL] {
             email = mail as! String
        } else {
            email = ""
        }
        
        
        if let fname = _dictionary[kFIRSTNAME] {
             firstName = fname as! String
        } else {
             firstName = ""
        }
        
        if let lname = _dictionary[kLASTNAME] {
            lastName = lname as! String
        } else {
            lastName = ""
        }
        
        if let fphone = _dictionary[kPHONE] {
            phone = fphone as! String
        } else {
           phone = ""
        }
        
        fullName = firstName + "" + lastName
        
        if let faddress = _dictionary[kFULLADDRESS] {
            fullAddress = faddress as! String
        } else {
            fullAddress = ""
        }
        
        if let onB = _dictionary[kONBOARD] {
            onBoard = onB as! Bool
        } else {
            onBoard = false
        }
        
        
        if let isA = _dictionary[kISADNIN] {
            isAdmin = isA as! Bool
        } else {
            isAdmin = false
        }
//
//        if let purchaseIds = _dictionary[kPURCHASEDITEMIDS] {
//            purchasedItemIds = purchaseIds as! [String]
//        } else {
//            purchasedItemIds = []
//        }
        if let purchaseIds = _dictionary[kPURCHASEDITEMIDS] as? [String] {
            purchasedItemIds = purchaseIds
        } else {
            purchasedItemIds = []
        }

    }
    
    //Mark: Return current user
    class func currentId() -> String {
        return Auth.auth().currentUser!.uid
    }
    
    class func currentUser() -> User? {
        if Auth.auth().currentUser != nil {
            if let dictionary = UserDefaults.standard.object(forKey: kCURRENTUSER) {
                return User.init(_dictionary: dictionary as! NSDictionary)
            }
        }
        return nil
    
    }
    
    //Mark: Login func
    class func loginUserWith(email: String, password: String, completion: @escaping(_ error: Error?, _ isEmailVerified: Bool) -> Void){
        Auth.auth().signIn(withEmail: email, password: password) { (authDataResult, error) in
            if error == nil {
                if authDataResult!.user.isEmailVerified {
                  // to download user from firestore
                    dowloadUserFromFirestore(userId: authDataResult!.user.uid, email: email)
                    completion(error, true)
                } else {
                  print("email is not varified")
                    completion(error, false)
                }
            } else {
              completion(error, false)
            
            }
        }
    
    }
    
    //Mark: -Resend link mehthods
    class func resetPasswordFor(email: String, completion: @escaping (_ error: Error?) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            completion(error)
        }
    }
    
    class func resendVerificationEmail(email: String, completion: @escaping (_ error: Error?) -> Void) {
        Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in
            print("resend error:",error?.localizedDescription)
            completion(error)
        })
    }
    
    // Mark: Register user
    class func registerUserWith(email: String, password: String, completion: @escaping (_ error: Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { (authDataResult, error)  in
            completion(error)
            
            if error == nil {
               //send email verification
                authDataResult!.user.sendEmailVerification { (error) in
                    print("Auth email error", error?.localizedDescription)
                }
            }
        }
    }
    
    class func logOutCurrentUser(completion: @escaping (_ error: Error?) -> Void){
       do {
           try Auth.auth().signOut()
           UserDefaults.standard.removeObject(forKey: kCURRENTUSER)
           UserDefaults.standard.synchronize()
           completion(nil)
       } catch let error as NSError {
          completion(error)
       }
    }
    
    //Admin
   
    
    
}//end of class
//Mark: Download User
func dowloadUserFromFirestore(userId: String, email: String) {
    FirebaseReference(.User).document(userId).getDocument { (snapshot, error) in
        guard let snapshot = snapshot else {return}
        
        if snapshot.exists {
          print("download current user from firebase")
            saveUserLocally(mUserDictionary: snapshot.data()! as NSDictionary)
        } else {
          // there is no user, save new in firebase
            let user = User(_objectId: userId, _email: email, _firstName: "", _lastName: "", _phone: "")
            saveUserLocally(mUserDictionary: userDictionaryFrom(user: user))
            saveUserToFirestore(mUser: user)
        }
    }

}


//Mark: Save user to firebase

func saveUserToFirestore(mUser: User){
    FirebaseReference(.User).document(mUser.objecId).setData(userDictionaryFrom(user: mUser) as! [String: Any]) { (error) in
        if error != nil {
            print("error saving user \(error!.localizedDescription)")
        }
    
    }
}

func saveUserLocally(mUserDictionary: NSDictionary){
    UserDefaults.standard.set(mUserDictionary, forKey: kCURRENTUSER)
    UserDefaults.standard.synchronize()
}

//Mark helper function
func userDictionaryFrom(user: User) -> NSDictionary {
    return NSDictionary(objects: [user.objecId, user.email, user.firstName, user.lastName, user.fullName, user.fullAddress ?? "", user.onBoard, user.isAdmin,user.purchasedItemIds, user.phone], forKeys: [kOBJECTID as NSCopying, kEMAIL as NSCopying, kFIRSTNAME as NSCopying, kLASTNAME as NSCopying, kFULLNAME as NSCopying, kFULLADDRESS as NSCopying, kONBOARD as NSCopying, kISADNIN as NSCopying,kPURCHASEDITEMIDS as NSCopying, kPHONE as NSCopying])

}

func updateCurrentUserÌnFirestore(withValues:[String: Any], completion: @escaping(_ error: Error?) -> Void) {
     
    if let dictionary = UserDefaults.standard.object(forKey: kCURRENTUSER) {
        let userObject = (dictionary as! NSDictionary).mutableCopy() as! NSMutableDictionary
        userObject.setValuesForKeys(withValues)
        
        FirebaseReference(.User).document(User.currentId()).updateData(withValues) { (error) in
            completion(error)
            if error == nil {
              saveUserLocally(mUserDictionary: userObject)
            }
        }
    }
}

