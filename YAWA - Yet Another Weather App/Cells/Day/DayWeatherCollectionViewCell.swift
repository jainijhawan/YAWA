//
//  DayWeatherCollectionViewCell.swift
//  YAWA - Yet Another Weather App
//
//  Created by Jai Nijhawan on 17/07/20.
//  Copyright © 2020 Jai Nijhawan. All rights reserved.
//

import UIKit

class DayWeatherCollectionViewCell: UICollectionViewCell {
  @IBOutlet weak var firstDayView: UIView!
  @IBOutlet weak var secondDayView: UIView!
  @IBOutlet weak var firstDayViewWidthConstraint: NSLayoutConstraint!
  @IBOutlet weak var secondDayViewWidthConstraint: NSLayoutConstraint!
  
  @IBOutlet weak var firstDayMinMaxLabel: UILabel!
  @IBOutlet weak var firstDayDayLabel: UILabel!
  @IBOutlet weak var firstDayDescription: UILabel!
  @IBOutlet weak var firstDayImageView: UIImageView!
  
  @IBOutlet weak var secondDayMinMaxLabel: UILabel!
  @IBOutlet weak var secondDayDayLabel: UILabel!
  @IBOutlet weak var secondViewDescription: UILabel!
  @IBOutlet weak var secondDayImageView: UIImageView!
  
  var viewModel: DayWeatherCollectionViewCellModel? {
    didSet {
      firstDayMinMaxLabel.text = viewModel?.firstDayMinMaxLabel 
      firstDayDayLabel.text = viewModel?.firstDayDayLabel
      firstDayDescription.text = viewModel?.firstDayDescription
      
      secondDayMinMaxLabel.text = viewModel?.secondDayMinMaxLabel
      secondDayDayLabel.text = viewModel?.secondDayDayLabel
      secondViewDescription.text = viewModel?.secondViewDescription
      if let png1 = getPNGFromCurrentWeatherID(id: viewModel!.firstId),
         let png2 = getPNGFromCurrentWeatherID(id: viewModel!.secondId) {
        firstDayImageView.image = png1
        secondDayImageView.image = png2
        setLabelColor(labels: [firstDayMinMaxLabel,
                               firstDayDayLabel,
                               firstDayDescription],
                      id: viewModel!.firstId)
        setLabelColor(labels: [secondDayMinMaxLabel,
                               secondDayDayLabel,
                               secondViewDescription],
                      id: viewModel!.secondId)
      }
    }
  }
  func setLabelColor(labels: [UILabel], id: Int) {
    if id == 800 || id > 801 {
      labels.forEach { $0.textColor = darkYellowColor }
    } else {
      labels.forEach { $0.textColor = darkBlueColor }
    }

  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
//    firstDayViewWidthConstraint.constant = screenWidth*0.4
//    secondDayViewWidthConstraint.constant = screenWidth*0.4
    layoutIfNeeded()
  }
  
}
