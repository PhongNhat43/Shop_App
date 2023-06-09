//
//  DownLoader.swift
//  Shop_App
//
//  Created by devsenior on 01/04/2023.
//

import Foundation
import FirebaseStorage

let storage = Storage.storage()

func uploadImages(images: [UIImage?], itemId: String, completion: @escaping (_ imageLinks: [String]) -> Void ) {
    if Reachability.HasConncection() {
       var uploadedImageCount = 0
        var imageLinkArray: [String] = []
        var nameSuffix = 0
        
        for image in images {
            let fileName = "ItemImages/" + itemId + "/" + "\(nameSuffix)" + ".jpg"
            let imageData = image!.jpegData(compressionQuality: 0.5)
            
            saveImageInFirebase(imageData: imageData!, fileName: fileName) { (imageLink) in
                if imageLink != nil {
                    imageLinkArray.append(imageLink!)
                    uploadedImageCount += 1
                    if uploadedImageCount == images.count {
                      completion(imageLinkArray)
                    }
                }
            }
        }
    }
    else {
      print("No Internet Connection")
    }

}

func saveImageInFirebase(imageData: Data, fileName: String, completion: @escaping (_ imageLinks: String?) -> Void) {
    var task: StorageUploadTask!
    
    let storageRef = storage.reference(forURL: kFILEREFERENCE).child(fileName)
    
    task = storageRef.putData(imageData, metadata: nil, completion: {(metadata, error) in
    
        task.removeAllObservers()
        
        if error != nil {
            print("Error uploading image", error!.localizedDescription)
            completion(nil)
            return
        }
        
        storageRef.downloadURL { (url, error ) in
            guard let dowloadUrl = url else {
              completion(nil)
                return
            }
            completion(dowloadUrl.absoluteString)
        }
    } )
}

func downloadImages(imageUrls: [String], completion: @escaping (_ images: [UIImage?]) -> Void) {

    var imageArray: [UIImage] = []
    
    var dowloadCounter = 0
    
    for link in imageUrls {
       let url = NSURL(string: link)
        
       let downloadQueue = DispatchQueue(label: "imageDownloadQueue")
        
        downloadQueue.async {
            dowloadCounter += 1
            let data = NSData(contentsOf: url! as URL)
            if data != nil {
                imageArray.append(UIImage(data: data! as Data)!)
                
                if dowloadCounter == imageArray.count {
                    DispatchQueue.main.async {
                        completion(imageArray)
                    }
                }
            } else {
               print("Couldnt dowload image")
                completion(imageArray)
            }
        }
    }

}
