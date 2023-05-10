//
//  Email.swift
//  Shop_App
//
//  Created by devsenior on 26/04/2023.
//

import UIKit
import FirebaseFirestore
import SendGrid

struct EmailManger {
    func WelcomingEmail(fullName: String,email: String, emailUser: String ,fullAddress: String, date: Date,purchasedItemIds: [String],phone: String,completion: @escaping (Result<Void, Error>) -> Void) {
        let apiKey = "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"
        let name = fullName
        let email = "jayce27052000@gmail.com"
        let emailUser = emailUser
        let fullAddress = fullAddress
        let developerEmail = "jayce27052000@gmail.com"
        let date = date
//        let objectId = objectId
//        let nameItems = nameItems
//        let price = price
//        let imageLinks = imageLinks
        let purchasedItemIds = purchasedItemIds.joined(separator: ", ")
        let phone = phone


        let data: [String: String] = [
            "name": name,
            "user": email,
            "fullAddress": fullAddress,
            "emailUser": emailUser,
            "date": "\(date)",
//            "objectId": objectId,
//            "nameItems": nameItems,
//            "price" : "\(price)",
//            "imageLinks": imageLinks
            "purchasedItemIds": purchasedItemIds,
            "phone": phone
        ]

        let personalization = TemplatedPersonalization(dynamicTemplateData: data, recipients: email)
        let session = Session()
        session.authentication = Authentication.apiKey(apiKey)

        let from = Address(email: developerEmail)

        let template = Email(personalizations: [personalization], from: from, templateID: "d-c8f99c06dada498fae370f715d10b32f")

        do {
            try session.send(request: template, completionHandler: { (result) in
                switch result {
                case .success(let response):
                    print("Email sent with status code: \(response.statusCode)")
                    completion(.success(()))
                case .failure(let error):
                    print("Error sending email: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            })

        } catch(let error) {
            print("Error sending email: \(error.localizedDescription)")
            completion(.failure(error))
        }
    }
}
