//
//  Constants.swift
//  YAWA - Yet Another Weather App
//
//  Created by Jai Nijhawan on 10/07/20.
//  Copyright © 2020 Jai Nijhawan. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

typealias CityData = (city: String,
                      country: String,
                      lat: String,
                      lon: String)

let screenRect = UIScreen.main.bounds
let screenWidth = screenRect.size.width
let screenHeight = screenRect.size.height

let darkYellowColor = UIColor(red: 0.60, green: 0.52, blue: 0.11, alpha: 1.00)
let darkBlueColor = UIColor(red: 0.15, green: 0.45, blue: 0.59, alpha: 1.00)
let aboutWebViewUrl = "https://rachitkhurana.github.io/yawa/index.html"

let realmObject = try! Realm()

var citiesData: [CityData] = []

func urlGenerator(lat: Double, lon: Double) -> URL? {
  let urlString = "https://api.openweathermap.org/data/2.5/onecall?lat=\(lat)&lon=\(lon)&appid=\(OPENWEATHERAPIKEY)"

  guard let url = URL(string: urlString)
    else { return nil }
    return url
}

func aqiUrlGenerator(lat: Double, lon: Double) -> URL? {
  let urlString = "https://api.airvisual.com/v2/nearest_city?lat=\(lat)&lon=\(lon)&key=\(AQIAPIKEY)"
    //http://api.airvisual.com/v2/nearest_city?lat={{LATITUDE}}&lon={{LONGITUDE}}&key={{YOUR_API_KEY}}
    
  guard let url = URL(string: urlString)
    else { return nil }
    return url
}

func getGIFFromCurrentWeatherID(id: Int) -> UIImage? {
  var name = ""
  switch id {
  case 200...202:
    name = "Thunderstorm-Rain.gif"
  case 210...221:
    name = "Thunderstorm.gif"
  case 230...232:
    name = "Thunderstorm-Rain.gif"
  case 300...599:
    name = "Rain.gif"
  case 600...601:
    name = "Snow.gif"
  case 611...622:
    name = "Hailstorm.gif"
  case 700...799:
    name = "Mist.gif"
  case 800:
    name = "Sun.gif"
  case 801:
    name = "Cloud-levitate.gif"
  case 802...899:
    name = "Sun-Cloud.gif"
  default:
    name = "Sun.gif"
  }
  return try! UIImage(gifName: name)
}

func getPNGFromCurrentWeatherID(id: Int) -> UIImage? {
    var name = ""
    switch id {
    case 200...202:
      name = "Thunderstorm + Rain"
    case 210...221:
      name = "Thunderstorm"
    case 230...232:
      name = "Thunderstorm + Rain"
    case 300...599:
      name = "Rain"
    case 600...601:
      name = "Snow"
    case 611...622:
      name = "Rain Heavy"
    case 700...799:
      name = "Mist"
    case 800:
      name = "Sun"
    case 801:
      name = "Cloud"
    case 802...899:
      name = "Sun + Cloud"
    default:
      name = "Sun.gif"
    }
    return UIImage(named: name)
  }

func getCurrentDate() -> String {
  let date = Date()
  let dateFormatterPrint = DateFormatter()
  dateFormatterPrint.dateFormat = "MMM d, yyyy"
  let result = dateFormatterPrint.string(from: date)
  return result
}

func getAQIColorTextAndBG(aqi: Int) -> (UIColor, String, String) {
  var rgb: (CGFloat, CGFloat, CGFloat) = (0, 0, 0)
  var comment = ""
  var bg = ""
  switch aqi {
  case 0...50:
    rgb = (1, 152, 102)
    comment = "It's Good !"
    bg = "bg1"
  case 51...100:
    rgb = (255, 215, 0)
    comment = "It's Moderate !"
    bg = "bg2"
  case 101...150:
    rgb = (255, 153, 51)
    comment = "It's Unhealthy !"
    bg = "bg3"
  case 151...200:
    rgb = (247, 0, 1)
    comment = "Still Unhealthy !"
    bg = "bg4"
  case 201...300:
    rgb = (102, 0, 153)
    comment = "Very Unhealthy !"
    bg = "bg5"
  case 300...999:
    rgb = (126, 0, 35)
    comment = "It's Hazardous !"
    bg = "bg6"
  default:
    rgb = (0, 0, 0)
  }
  return (UIColor(red: rgb.0/255, green: rgb.1/255, blue: rgb.2/255, alpha: 1.0), comment, bg)
}

func calculateCelsius(fahrenheit: Double) -> Double {
    var celsius: Double
    celsius = (fahrenheit - 32) * 5 / 9
    return celsius
}

func calculateFahrenheit(celsius: Double) -> Double {
    var fahrenheit: Double
    fahrenheit = celsius * 9 / 5 + 32
    return fahrenheit
}

func tempInFahrenheit(text: String?) -> String {
  if let temp = Double(text!) {
    let tempFar = calculateFahrenheit(celsius: temp)
    let x = String(format: "%.0f", tempFar)
    return x
  } else {
    return ""
  }
}

func tempInCelcius(text: String?) -> String {
  if let temp = Double(text!) {
    let tempFar = calculateCelsius(fahrenheit: temp)
    let x = String(format: "%.0f", tempFar)
    return x
  } else {
    return ""
  }
}


