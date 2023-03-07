//
//  LocationTableViewCell.swift
//  YAWA - Yet Another Weather App
//
//  Created by Jai Nijhawan on 05/12/20.
//  Copyright © 2020 Jai Nijhawan. All rights reserved.
//

import UIKit

class LocationTableViewCell: UITableViewCell {

  @IBOutlet weak var cityNameLabel: UILabel!
  override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
