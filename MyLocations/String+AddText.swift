//
//  String+AddText.swift
//  MyLocations
//
//  Created by human on 2019. 1. 3..
//  Copyright © 2019년 com.humantrion. All rights reserved.
//

import Foundation

extension String {
    
    mutating func addText(text:String?, withSeparator separator:String = ""){
        if let text = text {
            if !isEmpty {
                self += separator
            }
            self += text
        }
    }
}
