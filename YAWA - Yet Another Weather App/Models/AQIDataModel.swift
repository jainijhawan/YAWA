//
//  AQIDataModel.swift
//  YAWA - Yet Another Weather App
//
//  Created by Jai Nijhawan on 22/08/20.
//  Copyright © 2020 Jai Nijhawan. All rights reserved.
//

import Foundation

// MARK: - AQIDataModel
struct AQIDataModel: Codable {
    let status: String
    let data: DataClass
}

// MARK: - DataClass
struct DataClass: Codable {
    let city, state, country: String
    let location: Location
    let current: Current2
}

// MARK: - Current
struct Current2: Codable {
    let weather: WeatherAQI
    let pollution: Pollution
}

// MARK: - Pollution
struct Pollution: Codable {
    let ts: String
    let aqius: Int
    let mainus: String
    let aqicn: Int
    let maincn: String
}

// MARK: - WeatherAQI
struct WeatherAQI: Codable {
    let ts: String
    let tp, pr, hu: Int
    let ws: Double
    let wd: Int
    let ic: String
}

// MARK: - Location
struct Location: Codable {
    let type: String
    let coordinates: [Double]
}

