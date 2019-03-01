//
//  Extensions.swift
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

    // Value to be used for element padding app-wide
    static let padding: CGFloat = 14.0
}

extension UIColor {

    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }

    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")

        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }

    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }

    // --- Deprecated colors ---
    static let warmGrey = UIColor(r: 115, g: 115, b: 115)
    static let whiteGrey = UIColor(r: 248, g: 248, b: 248)
    static let paleTeal = UIColor(r: 149, g: 207, b: 175)
    static let coral = UIColor(r: 242, g: 110, b: 103)
    static let marigold = UIColor(r: 255, g: 193, b: 7)
    static let oceanBlue = UIColor(r: 73, g: 144, b: 226)
    static let frenchBlue = UIColor(r: 63, g: 81, b: 181)

    static let buttonBlue = UIColor(r: 14, g: 122, b: 254)

    static let navRed = UIColor(r: 192, g: 57, b:  43)
    static let navBarGrey = UIColor(r: 247, g: 247, b: 247)

    // --- New colors for homepage redesign ---
    // Greys
    static let primaryTitleGrey = UIColor(r: 63, g: 63, b: 63)
    static let secondaryTitleGrey = UIColor(r: 155, g: 155, b: 155)
    static let allbirdsGrey = UIColor(r: 234, g: 234, b: 234)
    // Colors
    static let navigationBlue = UIColor(r: 74, g: 144, b: 226)
    static let interactionGreen = UIColor(r: 118, g: 191, b: 150)
    static let informationYellow = UIColor(r: 255, g: 193, b: 7)
    static let redingTerminal = UIColor(r: 226, g: 81, b: 82)
    static let secondaryInformationGrey = UIColor(r: 155, g: 155, b: 155)

    static let dataGreen = UIColor(r: 118, g: 191, b: 150)
    static let highlightYellow = UIColor(r: 240, g: 180, b: 0)

    static let spruceHarborBlue = UIColor(r: 41, g: 128, b: 185)

}

extension UIFont {

    static let primaryTitleFont = UIFont(name: "AvenirNext-DemiBold", size: 24)
    static let secondaryTitleFont = UIFont(name: "AvenirNext-DemiBold", size: 10)

    static let interiorTitleFont = UIFont(name: "AvenirNext-Regular", size: 20)

    static let primaryInformationFont = UIFont(name: "AvenirNext-DemiBold", size: 14)
    static let secondaryInformationFont = UIFont(name: "AvenirNext-Regular", size: 14)

    static let footerDescriptionFont = UIFont(name: "AvenirNext-Regular", size: 10)
    static let footerTransitionFont = UIFont(name: "AvenirNext-DemiBold", size: 10)

    static let gsrTimeIncrementFont = UIFont(name: "AvenirNext-DemiBold", size: 20)
}

extension UIBarButtonItem {
    static func itemWith(colorfulImage: UIImage?, color: UIColor, target: AnyObject, action: Selector) -> UIBarButtonItem {
        let button = UIButton(type: .custom)
        button.setImage(colorfulImage?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: .normal)
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
        return Date().localTime
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

    // Formats individual dates to be similar to those used on the Dining Screen
    func strFormat() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(abbreviation: "EST")
        formatter.dateFormat = "h:mma"
        formatter.amSymbol = "a"
        formatter.pmSymbol = "p"
        var timesString = ""

        if self.minutes == 0 {
            formatter.dateFormat = "ha"
        } else {
            formatter.dateFormat = "h:mma"
        }

        let open = formatter.string(from: self)
        timesString += open
        return timesString
    }

    var localTime: Date {
        return self.convert(to: "GMT")
    }

    var minutes: Int {
        let calendar = Calendar.current
        let minutes = calendar.component(.minute, from: self)
        return minutes
    }

    var hour: Int {
        let calendar = Calendar.current
        let minutes = calendar.component(.hour, from: self)
        return minutes
    }

    func add(minutes: Int) -> Date {
        return Calendar.current.date(byAdding: .minute, value: minutes, to: self)!
    }

    func add(seconds: Int) -> Date {
        return Calendar.current.date(byAdding: .second, value: seconds, to: self)!
    }

    func add(milliseconds: Int) -> Date {
        let millisecondsSince1970 = Int((self.timeIntervalSince1970 * 1000.0).rounded())
        return Date(timeIntervalSince1970: TimeInterval((milliseconds + millisecondsSince1970) / 1000))
    }

    var roundedDownToHour: Date {
        let comp: DateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour], from: self)
        return Calendar.current.date(from: comp)!
        // return self.add(minutes: -self.minutes)
    }

    var roundUpToHourIfNeeded: Date {
        if minutes > 0 {
            return self.add(minutes: 60 - self.minutes)
        } else {
            return self
        }
    }

    static var currentDayOfWeek: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE" // Monday, Friday, etc.
        return dateFormatter.string(from: Date())
    }

    var dayOfWeek: String {
        let weekdayArray = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        let myCalendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        myCalendar.timeZone = TimeZone(abbreviation: "EST")!
        let myComponents = myCalendar.components(.weekday, from: self)
        let weekDay = myComponents.weekday!
        return weekdayArray[weekDay-1]
    }

    var integerDayOfWeek: Int {
        let myCalendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        let myComponents = myCalendar.components(.weekday, from: self)
        return myComponents.weekday! - 1
    }

    static let dayOfMonthFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        df.timeZone = TimeZone(abbreviation: "EST")
        return df
    }()

    var dateStringsForCurrentWeek: [String] {
        var dateStrings = [String]()
        let formatter = Date.dayOfMonthFormatter
        let currentDayOfWeek = Date().integerDayOfWeek
        for day in 0 ..< 7 {
            dateStrings.append(formatter.string(from: Date().add(minutes: 1440 * (day - currentDayOfWeek))))
        }
        return dateStrings
    }

    var adjustedFor11_59: Date {
        if self.minutes == 59 {
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

    var isToday: Bool {
        return Calendar.current.isDateInToday(self)
    }

    static func midnight(for dateStr: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.date(from: dateStr)!
    }

    static var midnightYesterday: Date  {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        let dateStr = formatter.string(from: Date())
        return formatter.date(from: dateStr)!
    }

    static var midnightToday: Date {
        return midnightYesterday.tomorrow
    }
}

extension LazyMapCollection  {
    func toArray() -> [Element] {
        return Array(self)
    }
}

extension UIViewController {
    var isVisible: Bool {
        return self.isViewLoaded && self.view.window != nil
    }
}

extension DateFormatter {
    static var yyyyMMdd: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter
    }
}

public extension Collection {
    /// Return a copy of `self` with its elements shuffled
    func shuffle() -> [Iterator.Element] {
        var list = Array(self)
        list.shuffleInPlace()
        return list
    }

    var random: Iterator.Element? {
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
            self.swapAt(i, j)
        }
    }
}


extension Optional {
    func nullUnwrap() -> Any {
        return self == nil ? "null" : self!
    }
}

extension UILabel {
    func shrinkUntilFits() {
        self.allowsDefaultTighteningForTruncation = true
        self.adjustsFontSizeToFitWidth = true
        self.minimumScaleFactor = 0.3
        self.numberOfLines = 1
    }
}

extension Dictionary where Key == String, Value == String {

    /// Build string representation of HTTP parameter dictionary of keys and objects
    ///
    /// This percent escapes in compliance with RFC 3986
    ///
    /// http://www.ietf.org/rfc/rfc3986.txt
    ///
    /// - returns: String representation in the form of key1=value1&key2=value2 where the keys and values are percent escaped

    func stringFromHttpParameters() -> String {
        let parameterArray = map { key, value -> String in
            let escapedKey = key.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? ""
            let escapedValue: String = value.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? ""
            return "\(escapedKey)=\(escapedValue)"
        }

        return parameterArray.joined(separator: "&")
    }

}

extension String {
    // https://stackoverflow.com/questions/34262863/how-to-calculate-height-of-a-string
    func dynamicHeight(font: UIFont, width: CGFloat) -> CGFloat{
        let calString = NSString(string: self)
        let textSize = calString.boundingRect(with: CGSize(width: width, height: CGFloat(MAXFLOAT)), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): font]), context: nil)
        return textSize.height
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}
