//
//  AllCitiesData.swift
//  YAWA - Yet Another Weather App
//
//  Created by Jai Nijhawan on 12/12/20.
//  Copyright © 2020 Jai Nijhawan. All rights reserved.
//

import Foundation
import RealmSwift

class AllCitiesData: Object  {
  @objc dynamic var city: String?
  @objc dynamic var country: String?
  @objc dynamic var lat: String?
  @objc dynamic var lon: String?
}
