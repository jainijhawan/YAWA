//
//  IBInspectable.swift
//  XamIdea Student
//
//  Created by Vaishali Gera on 31/08/17.
//  Copyright © 2017 Grappus. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
  
  @IBInspectable var cornerRadius: CGFloat {
    get {
      return layer.cornerRadius
    }
    set {
      layer.cornerRadius = newValue
      layer.masksToBounds = newValue > 0
    }
  }
  
  @IBInspectable var borderWidth: CGFloat {
    get {
      return layer.borderWidth
    }
    set {
      layer.borderWidth = newValue
    }
  }
  
  @IBInspectable var borderColor: UIColor? {
    get {
      return UIColor(cgColor: layer.borderColor!)
    }
    set {
      layer.borderColor = newValue?.cgColor
    }
  }
  
//  @IBInspectable var shadowColor: UIColor? {
//    set {
//      layer.shadowColor = newValue!.cgColor
//    }
//    get {
//      if let color = layer.shadowColor {
//        return UIColor(cgColor:color)
//      }
//      else {
//        return nil
//      }
//    }
//  }
  
  /* The opacity of the shadow. Defaults to 0. Specifying a value outside the
   * [0,1] range will give undefined results. Animatable. */
//  @IBInspectable var shadowOpacity: Float {
//    set {
//      layer.shadowOpacity = newValue
//    }
//    get {
//      return layer.shadowOpacity
//    }
//  }
  
  /* The shadow offset. Defaults to (0, -3). Animatable. */
//  @IBInspectable var shadowOffset: CGPoint {
//    set {
//      layer.shadowOffset = CGSize(width: newValue.x, height: newValue.y)
//    }
//    get {
//      return CGPoint(x: layer.shadowOffset.width, y:layer.shadowOffset.height)
//    }
//  }
  
  /* The blur radius used to create the shadow. Defaults to 3. Animatable. */
//  @IBInspectable var shadowRadius: CGFloat {
//    set {
//      layer.shadowRadius = newValue
//    }
//    get {
//      return layer.shadowRadius
//    }
//    
//  }
  
}

extension NSLayoutConstraint {
  /**
   Change multiplier constraint
   
   - parameter multiplier: CGFloat
   - returns: NSLayoutConstraint
   */
  func setMultiplier(multiplier:CGFloat) -> NSLayoutConstraint {
    
    NSLayoutConstraint.deactivate([self])
    
    let newConstraint = NSLayoutConstraint(
        item: firstItem as Any,
        attribute: firstAttribute,
        relatedBy: relation,
        toItem: secondItem,
        attribute: secondAttribute,
        multiplier: multiplier,
        constant: constant)
    
    newConstraint.priority = priority
    newConstraint.shouldBeArchived = self.shouldBeArchived
    newConstraint.identifier = self.identifier
    
    NSLayoutConstraint.activate([newConstraint])
    return newConstraint
  }
}

extension UILabel {
  
  func isTruncated() -> Bool {
    
    if let string = self.text {
      
      let size: CGSize = (string as NSString).boundingRect(
        with: CGSize(width: self.frame.size.width, height: CGFloat.greatestFiniteMagnitude),
        options: NSStringDrawingOptions.usesLineFragmentOrigin,
        attributes: [NSAttributedString.Key.font: self.font ?? UIFont.systemFont(ofSize: 10)],
        context: nil).size
      
      return (size.height > self.bounds.size.height)
    }
    return false
  }
}

extension UIView{
    func rotate() {
        let rotation : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = NSNumber(value: Double.pi * 2)
        rotation.duration = 100
        rotation.isCumulative = true
        rotation.repeatCount = Float.greatestFiniteMagnitude
        self.layer.add(rotation, forKey: "rotationAnimation")
    }
}
extension UIColor {
    static var random: UIColor {
        return UIColor(red: .random(in: 0...1),
                       green: .random(in: 0...1),
                       blue: .random(in: 0...1),
                       alpha: 1.0)
    }
}
public enum HTTPMethod: String {
    case options = "OPTIONS"
    case get     = "GET"
    case head    = "HEAD"
    case post    = "POST"
    case put     = "PUT"
    case patch   = "PATCH"
    case delete  = "DELETE"
    case trace   = "TRACE"
    case connect = "CONNECT"
}

extension Date {
    func dayOfWeek() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self).capitalized
        // or use capitalized(with: locale) if you want
    }
}

extension Double {
  func getTempInCelcius() -> String {
    return String(format: "%.0f", self - 273.15)
  }
}

extension String {
    func capitalizingFirstLetter() -> String {
      return prefix(1).uppercased() + self.lowercased().dropFirst()
    }

    mutating func capitalizeFirstLetter() {
      self = self.capitalizingFirstLetter()
    }
}

extension Int {
  func getWeekDay() -> String {
    return Date(timeIntervalSince1970: Double(self)).dayOfWeek() ?? ""
  }
}

extension UIColor {
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }

        return nil
    }
}
