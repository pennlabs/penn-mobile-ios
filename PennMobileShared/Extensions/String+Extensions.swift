//
//  String+Extensions.swift
//  PennMobileShared
//
//  Created by Josh Doman on 12/13/16.
//  Copyright © 2016 Josh Doman. All rights reserved.
//

import UIKit

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

public extension String {
    static func customFormat(minFractionDigits: Int = 0, maxFractionDigits: Int = 1, _ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = minFractionDigits
        formatter.maximumFractionDigits = maxFractionDigits
        return formatter.string(from: NSNumber(value: value)) ?? ""
    }
}
