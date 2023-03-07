//
//  HourlyWeatherCollectionViewCell.swift
//  YAWA - Yet Another Weather App
//
//  Created by Jai Nijhawan on 12/11/20.
//  Copyright © 2020 Jai Nijhawan. All rights reserved.
//

import UIKit

class HourlyWeatherCollectionViewCell: UICollectionViewCell {
    
  @IBOutlet weak var dataStackView: UIStackView!
  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var weatherImage: UIImageView!
  @IBOutlet weak var tempratureLabel: UILabel!
  //Next Day Outlets
  @IBOutlet weak var nextDayView: UIView!
  @IBOutlet weak var nextDayLabel: UILabel!
  
  var viewModel: HourlyWeatherCollectionViewCellModel? {
    didSet {
      if viewModel?.index == 0 {
        timeLabel.text = "NOW"
      } else {
        timeLabel.text = viewModel?.time
      }
      weatherImage.image = getPNGFromCurrentWeatherID(id: viewModel!.id)
      tempratureLabel.text = viewModel?.temprature
      if viewModel?.id == 0 {
        nextDayView.alpha = 1
        dataStackView.alpha = 0
      } else {
        nextDayView.alpha = 0
        dataStackView.alpha = 1
      }
    }
  }
}
