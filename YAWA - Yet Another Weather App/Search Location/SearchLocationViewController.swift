//
//  SearchLocationViewController.swift
//  YAWA - Yet Another Weather App
//
//  Created by Jai Nijhawan on 15/11/20.
//  Copyright © 2020 Jai Nijhawan. All rights reserved.
//

import UIKit
import Magnetic
import SpriteKit
import RealmSwift

class SearchLocationViewController: UIViewController {
  
  // MARK: - IBOutlets
  @IBOutlet weak var magneticView: MagneticView!
  @IBOutlet weak var textfieldViewTopConstraint: NSLayoutConstraint!
  @IBOutlet weak var searchTextfield: UITextField!
  @IBOutlet weak var bgBlurView: UIVisualEffectView!
  @IBOutlet weak var lineView: UIView!
  @IBOutlet weak var lineviewTopConstraint: NSLayoutConstraint!
  @IBOutlet weak var topView: UIView!
  @IBOutlet weak var locationTableView: UITableView!
  @IBOutlet weak var backButton: UIButton!
  
  var magnetic: Magnetic?
  
  let nodes = [Node(text: "Delhi", color: UIColor(red: 0.40, green: 0.76, blue: 0.91, alpha: 1.00), radius: 50),
               Node(text: "Mumbai", color: UIColor(red: 0.85, green: 0.36, blue: 0.39, alpha: 1.00), radius: 50),
               Node(text: "Bangalore", color: UIColor(red: 0.84, green: 0.50, blue: 0.68, alpha: 1.00), radius: 60),
               Node(text: "Hyderabad", color: UIColor(red: 0.36, green: 0.36, blue: 0.36, alpha: 1.00), radius: 60),
               Node(text: "Kolkata", color: UIColor(red: 0.75, green: 0.73, blue: 0.50, alpha: 1.00), radius: 60),
               Node(text: "Chennai", color: UIColor(red: 0.99, green: 0.77, blue: 0.49, alpha: 1.00), radius: 50),
               Node(text: "Gurgaon", color: UIColor(red: 0.92, green: 0.24, blue: 0.28, alpha: 1.00), radius: 60)]
  
  var searchData: [CityData] = [(city: "Delhi", country: "India", lat: "28.6600", lon: "77.2300"),
                                (city: "Mumbai", country: "India", lat: "18.9667", lon: "72.8333"),
                                (city: "Bangalore", country: "India", lat: "12.9699", lon: "77.5980"),
                                (city: "Hyderabad", country: "India", lat: "17.3667", lon: "78.4667"),
                                (city: "Kolkata", country: "India", lat: "22.5411", lon: "88.3378"),
                                (city: "Chennai", country: "India", lat: "13.0825", lon: "80.2750"),
                                (city: "Gurgaon", country: "India", lat: "28.4500", lon: "77.0200")]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    searchTextfield.attributedPlaceholder = NSAttributedString(string: "Search City",
                                                               attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
    magnetic = magneticView.magnetic
    magnetic?.allowsMultipleSelection = false
    magnetic?.backgroundColor = .clear
    magnetic?.magneticDelegate = self
    nodes.forEach { (node) in
      magnetic?.addChild(node)
    }
    locationTableView.alpha = 0
    searchTextfield.delegate = self
  }
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    textfieldViewTopConstraint.constant = 60
    UIView.animate(withDuration: 0.5,
                   delay: 0,
                   usingSpringWithDamping: 0.8,
                   initialSpringVelocity: 8,
                   options: .curveEaseInOut,
                   animations: {
                    self.bgBlurView.alpha = 1
                    self.backButton.alpha = 1
                    self.view.layoutIfNeeded()
                   }, completion: nil)
    
    lineviewTopConstraint.constant = textfieldViewTopConstraint.constant + topView.frame.height
    UIView.animate(withDuration: 1,
                   delay: 0,
                   usingSpringWithDamping: 0.8,
                   initialSpringVelocity: 6,
                   options: .curveEaseInOut,
                   animations: {
                    self.view.layoutIfNeeded()
                   }, completion: nil)
  }
  
  // MARK: - Custom Methods
  func performSearch(textField: UITextField) {
    if textField.text?.count != 0 {
      self.searchData.removeAll()
      for str in citiesData {
        let range = str.city.lowercased().range(of: textField.text ?? "",
                                                options: .caseInsensitive,
                                                range: nil,
                                                locale: nil)
        if range != nil {
          self.searchData.append(str)
        }
      }
    }
    locationTableView.reloadData()
  }
  func hideAllNodes() {
    for node in nodes {
      let scaleAction = SKAction.scale(to: 0, duration: 0.5)
      node.run(scaleAction)
    }
  }
  func animateTableView() {
    hideAllNodes()
    UIView.animate(withDuration: 0.5,
                   delay: 0.5,
                   options: .curveEaseInOut,
                   animations: {
                    self.locationTableView.alpha = 1
                   }, completion: nil)
  }
  
  func presentLocationVC(index: Int, node: Node? = nil) {
    var cityData = searchData[index]
    if node != nil {
      let nodeText = node?.text!
      var newIndex = 0
      for(index, node) in searchData.enumerated() {
        if nodeText == node.city {
          newIndex = index
        }
      }
      cityData = searchData[newIndex]
    }
    guard let currentLocationViewController = storyboard?.instantiateViewController(withIdentifier: "CurrentLocationViewController") as? CurrentLocationViewController else { return }
    currentLocationViewController.viewModel = CurrentLocationViewModel(cityData: cityData)
    if screenHeight < 700 {
      currentLocationViewController.modalPresentationStyle = .fullScreen
    }
    currentLocationViewController.isPresentedFromSearch = true
    self.present(currentLocationViewController, animated: true, completion: nil)
  }
  @IBAction func backTapped(_ sender: Any) {
    textfieldViewTopConstraint.constant = -100
    lineviewTopConstraint.constant = -200
    searchTextfield.endEditing(true)
    UIView.animate(withDuration: 1,
                   delay: 0,
                   usingSpringWithDamping: 0.8,
                   initialSpringVelocity: 8,
                   options: .curveEaseInOut,
                   animations: {
                    self.bgBlurView.alpha = 0
                    self.backButton.alpha = 0
                    self.locationTableView.alpha = 0
                    self.magneticView.alpha = 0
                    self.view.layoutIfNeeded()
                   }, completion: { _ in
                    self.dismiss(animated: false, completion: nil)
                   })
  }
}

extension SearchLocationViewController: MagneticDelegate {
  func magnetic(_ magnetic: Magnetic, didSelect node: Node) {
    let index = nodes.firstIndex(of: node)!
    presentLocationVC(index: index, node: node)
  }
  
  func magnetic(_ magnetic: Magnetic, didDeselect node: Node) {
    
  }
}

extension SearchLocationViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return searchData.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "LocationTableViewCell") as? LocationTableViewCell
    else { return UITableViewCell() }
    cell.cityNameLabel.text = searchData[indexPath.row].city + ", " + searchData[indexPath.row].country
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    presentLocationVC(index: indexPath.row)
  }
}

extension SearchLocationViewController: UITextFieldDelegate {
  func textFieldDidBeginEditing(_ textField: UITextField) {
    animateTableView()
  }
  func textField(_ textField: UITextField,
                 shouldChangeCharactersIn range: NSRange,
                 replacementString string: String) -> Bool {
    performSearch(textField: textField)
    return true
  }
}
