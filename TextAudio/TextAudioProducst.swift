//
//  TextAudioProducst.swift
//  TextAudio
//
//  Created by 김인로 on 2017. 4. 28..
//  Copyright © 2017년 highwill. All rights reserved.
//

import Foundation

public struct TextAudioProducts {
    
    //public static let Highwill = "kr.co.highwill.TextAudioBooks"
    
    //public static var ProductId:String = String()
    
    public static var productIdentifiers: Set<ProductIdentifier> = []
    
   //public static var productIdentifiers: Set<ProductIdentifier> = Set<ProductIdentifier>()
    
   public static let store = IAPHelper(productIds: TextAudioProducts.productIdentifiers)
}

func resourceNameForProductIdentifier(_ productIdentifier: String) -> String? {
    return productIdentifier.components(separatedBy: ".").last
}
