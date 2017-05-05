//
//  Util.swift
//  SpeakingBooks
//
//  Created by 김인로 on 2017. 4. 6..
//  Copyright © 2017년 김인로. All rights reserved.
//

import UIKit

open class Util: NSObject {
    
    
    open static let cacheDir : String = {
        var paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true) as [String]
        return paths[0]
    }()
    
    open class func imageViewShadow(_ imageView:UIImageView) -> UIImageView
    {
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowOpacity = 0.6
        imageView.layer.shadowRadius = 2.0
        imageView.layer.shadowOffset = CGSize.init(width: 3.0, height: 0.0)
        
        return imageView
    }
    
    
    open class func imageViewBorder(_ imageView:UIImageView) -> UIImageView
    {
        imageView.layer.borderColor = UIColor.brown.cgColor
        imageView.layer.borderWidth = 0.5
    
        return imageView
    }
    
    
    open class func burnText2ImageView(image:UIImage, title:String) -> UIImage
    {
        let newImageView = UIImageView(image : image)
        let labelView = UILabel(frame: CGRect(x:25 , y:10 , width: image.size.width*0.7, height: image.size.height*0.7)
        )
        var fontSize = 30.0;
        
        if (title.characters.count > 100) {fontSize = 18.0}
        if (title.characters.count > 150) {fontSize = 16.0}
        if (title.characters.count > 200) {fontSize = 14.0}
        
        labelView.font = UIFont(name:"Times New Roman", size:CGFloat(fontSize))
        labelView.textAlignment = .center
        labelView.lineBreakMode = .byWordWrapping
        labelView.numberOfLines = 5
        labelView.textColor = UIColor(colorLiteralRed: 0.8 , green: 0.8, blue: 0.7, alpha: 1)
        
        labelView.text = title
        
        newImageView.addSubview(labelView)
        UIGraphicsBeginImageContext(newImageView.frame.size)
        newImageView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let watermarkedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return watermarkedImage
    }
    
    
    static let priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        
        formatter.formatterBehavior = .behavior10_4
        formatter.numberStyle = .currency
        
        return formatter
    }()
    
}
