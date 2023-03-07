//
//  APIManager.swift
//  YAWA - Yet Another Weather App
//
//  Created by Jai Nijhawan on 08/08/20.
//  Copyright © 2020 Jai Nijhawan. All rights reserved.
//

import Foundation
class APIManager {
  
  // MARK: - Variables
  static let sharedManager = APIManager()
  
  func getCurrentCityData(lat: Double,
                          lon: Double,
                          completion: @escaping (Bool, WeatherDataModel?)->Void) {
      guard let url = urlGenerator(lat: lat, lon: lon) else { return }
      URLSession.shared.dataTask(with: URLRequest(url: url)) { data, response, error in
          if let data = data {
              if let weatherData = try? JSONDecoder().decode(WeatherDataModel.self, from: data) {
                  completion(true, weatherData)
              } else {
                  print("Invalid Response")
                  completion(false, nil)
              }
          } else if let error = error {
              print("HTTP Request Failed \(error)")
              completion(false, nil)
          }
      }.resume()
  }
    
  func getCurrentCityAQI(lat: Double,
                         lon: Double,
                         completion: @escaping (Bool, AQIDataModel?)->Void) {
      guard let url = aqiUrlGenerator(lat: lat, lon: lon) else { return }
      URLSession.shared.dataTask(with: URLRequest(url: url)) { data, response, error in
          if let data = data {
              if let weatherData = try? JSONDecoder().decode(AQIDataModel.self, from: data) {
                  completion(true, weatherData)
              } else {
                  print("Invalid Response")
                  completion(false, nil)
              }
          } else if let error = error {
              print("HTTP Request Failed \(error)")
              completion(false, nil)
          }
      }.resume()
  }
}
