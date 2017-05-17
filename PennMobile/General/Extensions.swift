//
//  Extensions.swift
//  WillYou
//
//  Created by Josh Doman on 12/13/16.
//  Copyright © 2016 Josh Doman. All rights reserved.
//

import UIKit

extension UIView {
    
    @available(iOS 9.0, *)
    func anchorToTop(_ top: NSLayoutYAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil) {
        
        anchorWithConstantsToTop(top, left: left, bottom: bottom, right: right, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0)
    }
    
    @available(iOS 9.0, *)
    func anchorWithConstantsToTop(_ top: NSLayoutYAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil, topConstant: CGFloat = 0, leftConstant: CGFloat = 0, bottomConstant: CGFloat = 0, rightConstant: CGFloat = 0) {
        
        _ = anchor(top, left: left, bottom: bottom, right: right, topConstant: topConstant, leftConstant: leftConstant, bottomConstant: bottomConstant, rightConstant: rightConstant)
    }
    
    @available(iOS 9.0, *)
    func anchor(_ top: NSLayoutYAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil, topConstant: CGFloat = 0, leftConstant: CGFloat = 0, bottomConstant: CGFloat = 0, rightConstant: CGFloat = 0, widthConstant: CGFloat = 0, heightConstant: CGFloat = 0) -> [NSLayoutConstraint] {
        translatesAutoresizingMaskIntoConstraints = false
        
        var anchors = [NSLayoutConstraint]()
        
        if let top = top {
            anchors.append(topAnchor.constraint(equalTo: top, constant: topConstant))
        }
        
        if let left = left {
            anchors.append(leftAnchor.constraint(equalTo: left, constant: leftConstant))
        }
        
        if let bottom = bottom {
            anchors.append(bottomAnchor.constraint(equalTo: bottom, constant: -bottomConstant))
        }
        
        if let right = right {
            anchors.append(rightAnchor.constraint(equalTo: right, constant: -rightConstant))
        }
        
        if widthConstant > 0 {
            anchors.append(widthAnchor.constraint(equalToConstant: widthConstant))
        }
        
        if heightConstant > 0 {
            anchors.append(heightAnchor.constraint(equalToConstant: heightConstant))
        }
        
        anchors.forEach({$0.isActive = true})
        
        return anchors
    }
    
}

extension UIColor {
    
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
    
    static let warmGrey = UIColor(r: 115, g: 115, b: 115)
    static let whiteGrey = UIColor(r: 248, g: 248, b: 248)
    static let paleTeal = UIColor(r: 149, g: 207, b: 175)
    static let coral = UIColor(r: 242, g: 110, b: 103)
    static let marigold = UIColor(r: 255, g: 193, b: 7)
    static let oceanBlue = UIColor(r: 73, g: 144, b: 226)
    static let frenchBlue = UIColor(r: 63, g: 81, b: 181)
    
    static let buttonBlue = UIColor(r: 14, g: 122, b: 254)
    
    static let navRed = UIColor(r: 192, g: 57, b:  43)
}

extension UIBarButtonItem {
    static func itemWith(colorfulImage: UIImage?, color: UIColor, target: AnyObject, action: Selector) -> UIBarButtonItem {
        let button = UIButton(type: .custom)
        button.setImage(colorfulImage?.withRenderingMode(UIImageRenderingMode.alwaysTemplate), for: .normal)
        button.tintColor = color
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        button.addTarget(target, action: action, for: .touchUpInside)
        
        let barButtonItem = UIBarButtonItem(customView: button)
        return barButtonItem
    }
}

extension Date {
    func minutesFrom(date: Date) -> Int {
        let difference = Calendar.current.dateComponents([.hour, .minute], from: self, to: date)
        if let hour = difference.hour, let minute = difference.minute {
            return hour*60 + minute
        }
        return 0
    }
    
    //returns date in local time
    static var currentLocalDate: Date {
        get {
            return Date().localTime
        }
    }
    
    func convert(to timezone: String) -> Date {
        var nowComponents = DateComponents()
        let calendar = Calendar.current
        nowComponents.year = Calendar.current.component(.year, from: self)
        nowComponents.month = Calendar.current.component(.month, from: self)
        nowComponents.day = Calendar.current.component(.day, from: self)
        nowComponents.hour = Calendar.current.component(.hour, from: self)
        nowComponents.minute = Calendar.current.component(.minute, from: self)
        nowComponents.second = Calendar.current.component(.second, from: self)
        nowComponents.timeZone = TimeZone(abbreviation: timezone)!
        return calendar.date(from: nowComponents)! as Date
    }
    
    var localTime: Date {
        return self.convert(to: "GMT")
    }
    
    var minutes: Int {
        let calendar = Calendar.current
        let minutes = calendar.component(.minute, from: self)
        return minutes
    }
    
    func add(minutes: Int) -> Date {
        return Calendar.current.date(byAdding: .minute, value: minutes, to: self)!
    }
    
    var roundedDownToHour: Date {
        return self.add(minutes: -self.minutes)
    }
    
    private var ends11_59: Bool {
        return minutes == 59
    }
        
    var dayOfWeek: String {
        let weekdayArray = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        let myCalendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        let myComponents = myCalendar.components(.weekday, from: self)
        let weekDay = myComponents.weekday!
        return weekdayArray[weekDay-1]
    }
    
    func adjustFor11_59() -> Date {
        if ends11_59 {
            return self.add(minutes: 1)
        }
        return self
    }
    
    func dateIn(days: Int) -> Date {
        let start = Calendar.current.startOfDay(for: self)
        return Calendar.current.date(byAdding: .day, value: days, to: start)!
    }
    
    var tomorrow: Date {
        return self.dateIn(days: 1)
    }
}

extension LazyMapCollection  {
    
    func toArray() -> [Element]{
        return Array(self)
    }
}

extension UIViewController {
    var isVisible: Bool {
        return self.isViewLoaded && self.view.window != nil
    }
}

public extension Collection {
    /// Return a copy of `self` with its elements shuffled
    func shuffle() -> [Generator.Element] {
        var list = Array(self)
        list.shuffleInPlace()
        return list
    }
    
    func random() -> Generator.Element? {
        return shuffle().first
    }
}

public extension MutableCollection where Index == Int {
    /// Shuffle the elements of `self` in-place.
    mutating func shuffleInPlace() {
        // empty and single-element collections don't shuffle
        if count < 2 { return }
        
        for i in startIndex ..< endIndex - 1 {
            let j = Int(arc4random_uniform(UInt32(endIndex - i))) + i
            guard i != j else { continue }
            swap(&self[i], &self[j])
        }
    }
}
