//
//  CurrentLocationViewModel.swift
//  YAWA - Yet Another Weather App
//
//  Created by Jai Nijhawan on 08/08/20.
//  Copyright © 2020 Jai Nijhawan. All rights reserved.
//

import Foundation

protocol CurrentLocationViewModeling {
  // MARK: - Input
  var weatherData: WeatherDataModel? { get set }
  var weeklyCellModels: [DayWeatherCollectionViewCellModel] { get set }
  var hourlyCellModels: [HourlyWeatherCollectionViewCellModel] { get set }
  
  // MARK: - Output
  var cityData: CityData? { get set }
}

class CurrentLocationViewModel: CurrentLocationViewModeling {
  // MARK: - Input
  var weatherData: WeatherDataModel?
  var weeklyCellModels = [DayWeatherCollectionViewCellModel]()
  var hourlyCellModels = [HourlyWeatherCollectionViewCellModel]()
  
  // MARK: - Output
  var cityData: CityData?
  
  init(cityData: CityData? = nil) {
    self.cityData = cityData
  }
  
    func getCurrentCityData(lat: Double, lon: Double, completion: @escaping ((_ data: WeatherDataModel) -> Void)) {
        APIManager.sharedManager.getCurrentCityData(lat: lat, lon: lon) {(success, data) in
            guard success,
                  let weatherData = data else { return }
            DispatchQueue.main.async {
                self.weatherData = weatherData
                self.createWeeklyCellModels(data: weatherData)
                self.createHourlyCellModels(data: weatherData)
                completion(weatherData)
            }
        }
    }
  
    func getCurrentCityAQI(lat: Double, lon: Double, completion: @escaping ((_ data: AQIDataModel) -> Void)) {
        APIManager.sharedManager.getCurrentCityAQI(lat: lat, lon: lon) { (success, data) in
            guard success,
                  let aqiData = data else { return }
            DispatchQueue.main.async {
                completion(aqiData)
            }
        }
    }
  
  func createHourlyCellModels(data: WeatherDataModel) {
    let dateFormatterPrint = DateFormatter()
    dateFormatterPrint.dateFormat = "ha"
    var models = [HourlyWeatherCollectionViewCellModel]()
    for index in 0...24 {
      let date = Date(timeIntervalSince1970: TimeInterval(data.hourly[index].dt))
      let timeString = dateFormatterPrint.string(from: date)
      let id = data.hourly[index].weather.first?.id
      let temp = data.hourly[index].temp.getTempInCelcius()
      
      if timeString == "1AM" {
        models.append(HourlyWeatherCollectionViewCellModel(time: "",
                                                           id: 0,
                                                           temprature: "",
                                                           index: index))
      }
      let model = HourlyWeatherCollectionViewCellModel(time: timeString,
                                                       id: id!,
                                                       temprature: temp + "°",
                                                       index: index)
      models.append(model)
    }
    hourlyCellModels = models
  }
  
  func createWeeklyCellModels(data: WeatherDataModel) {
    var models = [DayWeatherCollectionViewCellModel]()
    var firstDesc = ""
    var secondDesc = ""
    var desc = [(first: String, second: String)]()
    var minMax = [(first: String, second: String)]()
    var days = [(first: String, second: String)]()
    var ids = [(first: Int, second: Int)]()
    
    for (index, weeklyData) in data.daily.enumerated() {
      if index.isMultiple(of: 2) && index < 7 {
        firstDesc = weeklyData.weather.first!.main
        secondDesc = data.daily[index+1].weather.first!.main
        let id1 = Int(data.daily[index].weather[0].id)
        let id2 = Int(data.daily[index+1].weather[0].id)
        desc.append((first: firstDesc, second: secondDesc))
        minMax.append((first: "Min: \(weeklyData.temp.min.getTempInCelcius()) Max:\(weeklyData.temp.max.getTempInCelcius())",
                       second: "Min: \(data.daily[index+1].temp.min.getTempInCelcius()) Max:\(data.daily[index+1].temp.max.getTempInCelcius())"))
        days.append((first: weeklyData.dt.getWeekDay(), second: data.daily[index+1].dt.getWeekDay()))
        ids.append((id1, second: id2))
      }
    }
    for index in 0...3 {
      models.append(DayWeatherCollectionViewCellModel(firstDayMinMaxLabel: minMax[index].first,
                                                          firstDayDayLabel: days[index].first,
                                                          firstDayDescription: desc[index].first,
                                                          secondDayMinMaxLabel: minMax[index].second,
                                                          secondDayDayLabel: days[index].second,
                                                          secondViewDescription: desc[index].second,
                                                          firstId: ids[index].first,
                                                          secondId: ids[index].second))
    }
    
    weeklyCellModels = models
  }
  
}
