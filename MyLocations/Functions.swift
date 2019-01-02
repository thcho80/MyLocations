//
//  Functions.swift
//  MyLocations
//
//  Created by human on 2019. 1. 2..
//  Copyright © 2019년 com.humantrion. All rights reserved.
//

import Foundation

let applicationDocumentsDirectory: URL  = {
    
    let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let documentDirectory = urls[0]

    return documentDirectory
}()


