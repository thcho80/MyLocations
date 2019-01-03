//
//  UIImage+Resize.swift
//  MyLocations
//
//  Created by human on 2019. 1. 3..
//  Copyright © 2019년 com.humantrion. All rights reserved.
//

import UIKit

extension UIImage {
    
    func resizedImageWithBounds(bounds:CGSize)->UIImage {
        
        let horizontalRatio = bounds.width / size.width
        let verticalRatio = bounds.height / size.height
        let ratio = min(horizontalRatio, verticalRatio)
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        
        UIGraphicsBeginImageContextWithOptions(newSize, true, 0)
        draw(in: CGRect(origin: CGPoint.zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}
