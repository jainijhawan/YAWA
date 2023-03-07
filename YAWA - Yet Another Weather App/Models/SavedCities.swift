//
//  SavedCities.swift
//  YAWA - Yet Another Weather App
//
//  Created by Jai Nijhawan on 06/12/20.
//  Copyright © 2020 Jai Nijhawan. All rights reserved.
//

import Foundation
import RealmSwift

class SavedCities: Object  {
  @objc dynamic var cityName: String?
  @objc dynamic var lat: String?
  @objc dynamic var lon: String?
}
