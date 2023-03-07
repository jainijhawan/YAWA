//
//  APIManager.swift
//  YAWA - Yet Another Weather App
//
//  Created by Jai Nijhawan on 08/08/20.
//  Copyright © 2020 Jai Nijhawan. All rights reserved.
//

import Foundation
import Alamofire

class APIManager {
  
  // MARK: - Variables
  static let sharedManager = APIManager()
  let session = URLSession.shared
  
  func getCurrentCityData(lat: Double,
                          lon: Double,
                          completion: @escaping (Bool,Any?)->Void) {
    let url = urlGenerator(lat: lat, lon: lon)!
    Alamofire.request(url, method: .get,
                      encoding: JSONEncoding.default)
      .validate()
      .responseJSON(completionHandler: { (response) in
      switch response.result {
      case .success( _):
        let decoder = JSONDecoder()
        let data = try? decoder.decode(WeatherDataModel.self, from: response.data!)
        completion(true, data)
        break
      case .failure( _):
        break
      }
    }
    )
  }
  func getCurrentCityAQI(lat: Double,
                         lon: Double,
                         completion: @escaping (Bool,Any?)->Void) {
    let url = aqiUrlGenerator(lat: lat, lon: lon)!
    Alamofire.request(url, method: .get,
                      encoding: JSONEncoding.default)
      .validate()
      .responseJSON(completionHandler: { (response) in
        switch response.result {
        case .success( _):
          let decoder = JSONDecoder()
          let data = try? decoder.decode(AQIDataModel.self, from: response.data!)
          completion(true, data)
          break
        case .failure( _):
          break
        }
      }
    )
  }
}
