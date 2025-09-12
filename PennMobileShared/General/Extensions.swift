//
//  Extensions.swift
//
//  Created by Josh Doman on 12/13/16.
//  Copyright © 2016 Josh Doman. All rights reserved.
//

import SwiftUI
import UIKit
import OSLog
import MapKit

extension UIApplication {
    public static var isRunningFastlaneTest: Bool {
        return ProcessInfo().arguments.contains("FASTLANE")
    }
}

public class Padding {
    public static let pad: CGFloat = 14.0
}

public extension UIView {
    var pad: CGFloat { return Padding.pad }
}

extension UIViewController {
    var pad: CGFloat { return Padding.pad }
}

public extension UIView {
    func anchorToTop(_ top: NSLayoutYAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil) {

        anchorWithConstantsToTop(top, left: left, bottom: bottom, right: right, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0)
    }

    func anchorWithConstantsToTop(_ top: NSLayoutYAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil, topConstant: CGFloat = 0, leftConstant: CGFloat = 0, bottomConstant: CGFloat = 0, rightConstant: CGFloat = 0) {

        _ = anchor(top, left: left, bottom: bottom, right: right, topConstant: topConstant, leftConstant: leftConstant, bottomConstant: bottomConstant, rightConstant: rightConstant)
    }

    func
        anchor(_ top: NSLayoutYAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil, topConstant: CGFloat = 0, leftConstant: CGFloat = 0, bottomConstant: CGFloat = 0, rightConstant: CGFloat = 0, widthConstant: CGFloat = 0, heightConstant: CGFloat = 0) -> [NSLayoutConstraint] {
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

public extension UIColor {

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
}

extension UIFont {
    public static let avenirMedium = UIFont.systemFont(ofSize: 21, weight: .regular)
    public static let primaryTitleFont = UIFont.systemFont(ofSize: 21, weight: .semibold)
    public static let secondaryTitleFont = UIFont.systemFont(ofSize: 11, weight: .medium)

    public static let interiorTitleFont = UIFont.systemFont(ofSize: 17, weight: .medium)

    public static let pollsTitleFont = UIFont.systemFont(ofSize: 17, weight: .semibold)

    public static let primaryInformationFont = UIFont.systemFont(ofSize: 14, weight: .semibold)
    public static let secondaryInformationFont = UIFont.systemFont(ofSize: 14, weight: .regular)

    public static let footerDescriptionFont = UIFont.systemFont(ofSize: 10, weight: .regular)
    public static let footerTransitionFont = UIFont.systemFont(ofSize: 10, weight: .semibold)

    public static let gsrTimeIncrementFont = UIFont.systemFont(ofSize: 20, weight: .semibold)

    public static let alertSettingsWarningFont = UIFont.systemFont(ofSize: 30, weight: .bold)

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

public extension Date {
    func minutesFrom(date: Date) -> Int {
        let difference = Calendar.current.dateComponents([.hour, .minute], from: self, to: date)
        if let hour = difference.hour, let minute = difference.minute {
            return hour*60 + minute
        }
        return 0
    }

    func hoursFrom(date: Date) -> Int {
        let difference = Calendar.current.dateComponents([.hour], from: self, to: date)
        return difference.hour ?? 0
    }

    func humanReadableDistanceFrom(_ date: Date) -> String {
        // Opens in 55m
        // Opens at 6pm
        let minutes = minutesFrom(date: date) % 60
        let hours = hoursFrom(date: date)
        var result = ""
        if hours != 0 {
            result += "at \(date.strFormat())"
        } else {
            result += "in \(minutes)m"
        }
        return result
    }

    // returns date in local time
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
        formatter.amSymbol = "am"
        formatter.pmSymbol = "pm"
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

    func add(months: Int) -> Date {
        return Calendar.current.date(byAdding: .month, value: months, to: self)!
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

    var month: Int {
        let values = Calendar.current.dateComponents([Calendar.Component.month], from: self)
        return values.month!
    }

    var year: Int {
        let values = Calendar.current.dateComponents([Calendar.Component.year], from: self)
        return values.year!
    }

    var roundedDownToHalfHour: Date {
        let roundedDownToHour = self.roundedDownToHour
        if roundedDownToHour.minutesFrom(date: self) >= 30 {
            return roundedDownToHour.add(minutes: 30)
        } else {
            return roundedDownToHour
        }
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

    static let weekdayArray = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]

    var dayOfWeek: String {
        let myCalendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        myCalendar.timeZone = TimeZone(abbreviation: "EST")!
        let myComponents = myCalendar.components(.weekday, from: self)
        let weekDay = myComponents.weekday!
        return Date.weekdayArray[weekDay-1]
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

    static var midnightYesterday: Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        let dateStr = formatter.string(from: Date())
        return formatter.date(from: dateStr)!
    }

    static var midnightToday: Date {
        return midnightYesterday.tomorrow
    }

    static var todayString: String {
        return Date.dayOfMonthFormatter.string(from: Date())
    }

    static var startOfSemester: Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: "2025-08-26")!

    }

    static var endOfSemester: Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: "2025-12-18")!
    }
}

public extension LazyMapCollection {
    func toArray() -> [Element] {
        return Array(self)
    }
}

public extension UIViewController {
    var isVisible: Bool {
        return self.isViewLoaded && self.view.window != nil
    }
}

public extension DateFormatter {
    static var yyyyMMdd: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter
    }
    
    static var iso8601: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }

    static var iso8601Full: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }
}

public extension JSONDecoder.DateDecodingStrategy {
    static let iso8601Full = custom { decoder -> Date in
        let container = try decoder.singleValueContainer()
        let dateString = try container.decode(String.self)
        
        if let date = DateFormatter.iso8601Full.date(from: dateString) {
            return date
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date format")
        }
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

public extension Optional {
    /// Unwraps an optional and throws an error if it is nil.
    ///
    /// https://www.avanderlee.com/swift/unwrap-or-throw/
    func unwrap(orThrow error: Error) throws -> Wrapped {
        if let self {
            return self
        } else {
            throw error
        }
    }
}

public extension UILabel {
    func shrinkUntilFits() {
        self.allowsDefaultTighteningForTruncation = true
        self.adjustsFontSizeToFitWidth = true
        self.minimumScaleFactor = 0.3
        self.numberOfLines = 1
    }
}

public extension Sequence where Element: Sendable {
    /// Maps an array to an array of transformed values, fetched asynchronously in parallel.
    func asyncMap<T: Sendable>(_ transform: @escaping @Sendable (Element) async throws -> T) async rethrows -> [T] {
        try await withThrowingTaskGroup(of: T.self) { group in
            forEach { element in
                group.addTask {
                    try await transform(element)
                }
            }

            return try await group.reduce(into: []) { $0.append($1) }
        }
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

public extension String {
    // https://stackoverflow.com/questions/34262863/how-to-calculate-height-of-a-string
    func dynamicHeight(font: UIFont, width: CGFloat) -> CGFloat {
        let calString = NSString(string: self)
        let textSize = calString.boundingRect(with: CGSize(width: width, height: CGFloat(MAXFLOAT)), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): font]), context: nil)
        return textSize.height
    }

    func getMatches(for pattern: String) -> [String] {
        let regex = try! NSRegularExpression(pattern: pattern)
        let result = regex.matches(in: self, range: NSMakeRange(0, self.utf16.count))
        var matches = [String]()
        for res in result {
            let r = res.range(at: 1)
            let start = self.index(self.startIndex, offsetBy: r.location)
            let end = self.index(self.startIndex, offsetBy: r.location + r.length)
            matches.append(String(self[start..<end]))
        }
        return matches
    }

    func removingRegexMatches(pattern: String, replaceWith: String = "") -> String {
        let regex = try! NSRegularExpression(pattern: pattern)
        let range = NSMakeRange(0, self.count)
        return regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: replaceWith)
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

    // https://sarunw.com/posts/how-to-compare-two-app-version-strings-in-swift/
    func versionCompare(_ otherVersion: String) -> ComparisonResult {
        let versionDelimiter = "."

        var versionComponents = self.components(separatedBy: versionDelimiter) // <1>
        var otherVersionComponents = otherVersion.components(separatedBy: versionDelimiter)

        let zeroDiff = versionComponents.count - otherVersionComponents.count // <2>

        if zeroDiff == 0 { // <3>
            // Same format, compare normally
            return self.compare(otherVersion, options: .numeric)
        } else {
            let zeros = Array(repeating: "0", count: abs(zeroDiff)) // <4>
            if zeroDiff > 0 {
                otherVersionComponents.append(contentsOf: zeros) // <5>
            } else {
                versionComponents.append(contentsOf: zeros)
            }
            return versionComponents.joined(separator: versionDelimiter)
                .compare(otherVersionComponents.joined(separator: versionDelimiter), options: .numeric) // <6>
        }
    }
    
    static func getPostString(params: [String: Any]) -> String {
        let characterSet = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789")
        let parameterArray = params.map { key, value -> String in
            let escapedKey = key.addingPercentEncoding(withAllowedCharacters: characterSet) ?? ""
            if let strValue = value as? String {
                let escapedValue = strValue.addingPercentEncoding(withAllowedCharacters: characterSet) ?? ""
                return "\(escapedKey)=\(escapedValue)"
            } else if let arr = value as? [Any] {
                let str = arr.map { String(describing: $0).addingPercentEncoding(withAllowedCharacters: characterSet) ?? "" }.joined(separator: ",")
                return "\(escapedKey)=\(str)"
            } else {
                return "\(escapedKey)=\(value)"
            }
        }
        let encodedParams = parameterArray.joined(separator: "&")
        return encodedParams
    }

    // https://stackoverflow.com/questions/37048759/swift-display-html-data-in-a-label-or-textview
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return nil }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return nil
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}

// slicing Penn Events API image source urls
public extension String {
    //https://stackoverflow.com/questions/31725424/swift-get-string-between-2-strings-in-a-string
    func slice(from: String, to: String) -> String? {
        return (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                String(self[substringFrom..<substringTo])
            }
        }
    }
}

// Source: https://stackoverflow.com/questions/26845307/generate-random-alphanumeric-string-in-swift/33860834
public extension String {
    static func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map { _ in letters.randomElement()! })
    }
}

extension NSMutableAttributedString {
    @discardableResult func bold(_ text: String, size: CGFloat) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: size, weight: .bold)]
        let boldString = NSMutableAttributedString(string: text, attributes: attrs)
        append(boldString)
        return self
    }

    @discardableResult func weighted(_ text: String, weight: UIFont.Weight, size: CGFloat) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: size, weight: weight)]
        let boldString = NSMutableAttributedString(string: text, attributes: attrs)
        append(boldString)
        return self
    }

    @discardableResult public func weightedColored(_ text: String, weight: UIFont.Weight, color: UIColor, size: CGFloat) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: size, weight: weight), NSAttributedString.Key.foregroundColor: color]
        let boldString = NSMutableAttributedString(string: text, attributes: attrs)
        append(boldString)
        return self
    }

    @discardableResult func colored(_ text: String, color: UIColor) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [NSAttributedString.Key.foregroundColor: color]
        let colorString = NSMutableAttributedString(string: text, attributes: attrs)
        append(colorString)
        return self
    }

    @discardableResult func normal(_ text: String) -> NSMutableAttributedString {
        let normal = NSAttributedString(string: text)
        append(normal)
        return self
    }
}

// Decodes .json data for SwiftUI Previews
// https://www.hackingwithswift.com/books/ios-swiftui/using-generics-to-load-any-kind-of-codable-data
public extension Bundle {
    func decode<T: Codable>(_ file: String, dateFormat: String? = nil) -> T {
        guard let url = self.url(forResource: file, withExtension: nil) else {
            fatalError("unable to find data")
        }

        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load \(file) from bundle")
        }

        let decoder = JSONDecoder()

        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat

        decoder.dateDecodingStrategy = .formatted(formatter)

        guard let decoded = try? decoder.decode(T.self, from: data) else {
            fatalError("Data does not conform to desired structure")
        }

        return decoded
    }
}

public extension URL {
    mutating func appendQueryItem(name: String, value: String?) {
        guard var urlComponents = URLComponents(string: absoluteString) else { return }

        var queryItems: [URLQueryItem] = urlComponents.queryItems ?? []
        let queryItem = URLQueryItem(name: name, value: value)

        queryItems.append(queryItem)

        urlComponents.queryItems = queryItems

        self = urlComponents.url!
    }

    var queryParameters: [String: String] {
        guard
            let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
            let queryItems = components.queryItems else { return [:] }
        return queryItems.reduce(into: [String: String]()) { (result, item) in
            result[item.name] = item.value
        }
    }
}

public extension JSONDecoder {
    convenience init(keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy) {
        self.init()
        self.keyDecodingStrategy = keyDecodingStrategy
        self.dateDecodingStrategy = dateDecodingStrategy
    }
}

public extension Logger {
    init(category: String) {
        self.init(subsystem: Bundle.main.bundleIdentifier ?? "Penn Mobile", category: category)
    }
}

public extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

extension CLLocationCoordinate2D: @retroactive Identifiable {
    public var id: String {
        return "\(latitude)-\(longitude)"
    }
}

public extension Data {
   mutating func append(_ string: String) {
      if let data = string.data(using: .utf8) {
         append(data)
      }
   }
}

/// This is used to get the current navigation path in a readable format. For example, if SomePage is a Codable enum
/// that is the type of the values used in any NavigationLink, then calling asList(of: SomePage.self) will return
/// the current NavigationPath as [SomePage] (but optional in case of failure)
/// This is very jank, so if someone else knows a better way, PLEASE change this.
public extension NavigationPath {
    func getData() -> Data? {
        guard let representation = self.codable else { return nil }
        let encoder = JSONEncoder()
        return try? encoder.encode(representation)
    }
    
    func asList<R: Decodable>(of type: R.Type) -> [R]? {
        guard let data = getData() else { return nil }
        let decoder = JSONDecoder()
        guard let pageArray = try? decoder.decode([String].self, from: data) else { return nil }
        let output: [R] = pageArray.compactMap {
            guard let data = $0.data(using: .utf8) else { return nil }
            return try? decoder.decode(type, from: data)
        }
        return output
    }
    
    func contains<R: Decodable & Equatable>(_ page: R) -> Bool {
        return asList(of: R.self)?.contains(page) ?? false
    }
    
    mutating func removeAll() {
        self.removeLast(self.count)
    }
}

public extension String {
    static func customFormat(minFractionDigits: Int = 0, maxFractionDigits: Int = 1, _ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = minFractionDigits
        formatter.maximumFractionDigits = maxFractionDigits
        return formatter.string(from: NSNumber(value: value)) ?? ""
    }
}

public extension UserDefaults {
    static let group = UserDefaults(suiteName: Storage.appGroupID)!
}
