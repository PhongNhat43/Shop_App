//
//  HelperFunctions.swift
//  Shop_App
//
//  Created by devsenior on 03/04/2023.
//

import Foundation

func convertToCurrency(_ number: Double) -> String {
     let currencyFormatter = NumberFormatter()
    currencyFormatter.usesGroupingSeparator = true
    currencyFormatter.numberStyle = .currency
    currencyFormatter.locale = Locale.current
    
    let priceString = currencyFormatter.string(from: NSNumber(value: number))!
    
    return priceString

}
