//
//  AlgoliaService.swift
//  Shop_App
//
//  Created by devsenior on 17/04/2023.
//

import Foundation
import InstantSearchClient

class AlgoliaService {
   static let shared = AlgoliaService()
    
    let client = Client(appID: kALGFOLIA_APP_ID, apiKey: KALGOLIA_ADMIN_KEY)
    let index = Client(appID: kALGFOLIA_APP_ID, apiKey: KALGOLIA_ADMIN_KEY).index(withName: "dev_Name")
    
    private init() {}
 
}


