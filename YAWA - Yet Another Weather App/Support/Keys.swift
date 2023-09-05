//
//  Keys.swift
//  YAWA
//
//  Created by Jai Nijhawan on 07/03/23.
//  Copyright © 2023 Jai Nijhawan. All rights reserved.
//

import Foundation

var OPENWEATHERAPIKEY: String = {
    return FirebaseManager.getVlaueFor(key: "OPENWEATHERAPIKEY") ?? ""
}()

var AQIAPIKEY: String = {
    return FirebaseManager.getVlaueFor(key: "AQIAPIKEY") ?? ""
}()
