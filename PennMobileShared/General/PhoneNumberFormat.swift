//
//  PhoneNumberFormat.swift
//  PennMobile
//
//  Created by Jordan H on 2/25/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import Foundation

// https://emptytheory.com/2021/08/14/creating-custom-parseable-format-styles-in-ios-15/

/// Parse strategy for `PhoneNumber`
public struct PhoneNumberParseStrategy: ParseStrategy {
    
    /// Creates an instance of the `ParseOutput` type from `value`.
    /// - Parameter value: Value to convert to `PhoneNumber` object
    /// - Returns: `PhoneNumber` object
    public func parse(_ value: String) throws -> Decimal {
        // Strip out to just numerics.  Throw out parentheses, etc. and then convert to an array of characters. Simple version here ignores country codes, localized phone numbers, invalid area codes, etc.
        let maxPhoneNumberLength = 10
        let numericValue = Array(value.filter({ $0.isWholeNumber }).prefix(maxPhoneNumberLength))
        
        // PUll out the phone number components
        var areaCode: String = ""
        var exchange: String = ""
        var number: String = ""
        for i in 0..<numericValue.count {
            switch i {
            case 0...2:
                // Area code
                areaCode.append(numericValue[i])
            case 3...5:
                // Exchange
                exchange.append(numericValue[i])
            default:
                // Number
                number.append(numericValue[i])
            }
        }

        // Output the populated object
        return Decimal(string: areaCode + exchange + number) ?? 0
    }

}

extension FormatStyle where Self == PhoneNumberFormatStyle {
    
    /// Format the given string as a phone number in the format (___) ___-____ or similar
    public static var phoneNumber: PhoneNumberFormatStyle {
        PhoneNumberFormatStyle()
    }
    
}
    
/// Phone number formatting style
public struct PhoneNumberFormatStyle {
    
    /// Pieces of the phone number
    public enum PhoneNumberFormatStyleType: CaseIterable, Codable {
        case parentheses    // Include the parentheses around the area code
        case hyphen         // Include the hyphen in the middle of the phone number
        case space          // Include the space between area code and phone number
        case areaCode       // Area code
        case phoneNumber    // Phone number itself
    }
    
    /// Type of formatting
    public var formatStyleTypes: [PhoneNumberFormatStyleType] = []
    
    /// Placeholder character
    public var placeholder: Character = "_"
    
    /// Constructor w/placeholder optional
    /// - Parameter placeholder: Placeholder to use instead of '_'
    public init(placeholder: Character = "_") {
        self.placeholder = placeholder
    }
    
    /// Constructer to allow extensions to set formatting
    /// - Parameter formatStyleTypes: Format style types
    public init(_ formatStyleTypes: [PhoneNumberFormatStyleType]) {
        self.formatStyleTypes = formatStyleTypes
    }
}

extension PhoneNumberFormatStyle: ParseableFormatStyle {
    
    /// A `ParseStrategy` that can be used to parse this `FormatStyle`'s output
    public var parseStrategy: PhoneNumberParseStrategy {
        return PhoneNumberParseStrategy()
    }

    public func format(_ value: Decimal) -> String {
        
        // Fill out fields with placeholder
        let stringPlaceholder = String(placeholder)
        
        let stringVal = String(describing: value)
        let areaCode = stringVal.prefix(3)
        let exchange = stringVal.dropFirst(3).prefix(3)
        let number = stringVal.dropFirst(6)
        
        let paddedAreaCode = areaCode.padding(toLength: 3, withPad: stringPlaceholder, startingAt: 0)
        let paddedExchange = exchange.padding(toLength: 3, withPad: stringPlaceholder, startingAt: 0)
        let paddedNumber = number.padding(toLength: 4, withPad: stringPlaceholder, startingAt: 0)

        // Get the working style types
        let workingStyleTypes = !formatStyleTypes.isEmpty ? formatStyleTypes : PhoneNumberFormatStyleType.allCases
        
        var output = ""
        if workingStyleTypes.contains(.areaCode) {
            output += workingStyleTypes.contains(.parentheses) ? "(" + paddedAreaCode + ")" : paddedAreaCode
        }
        if workingStyleTypes.contains(.space) && workingStyleTypes.contains(.areaCode) && workingStyleTypes.contains(.phoneNumber) {
            // Without the area code and phone number, no point with space
            output += " "
        }
        if workingStyleTypes.contains(.phoneNumber) {
            output += workingStyleTypes.contains(.hyphen) ? paddedExchange + "-" + paddedNumber : paddedExchange + paddedNumber
        }
        
        // All done
        return output
    }

}

extension PhoneNumberFormatStyle: Codable {
    
    enum CodingKeys: String, CodingKey {
        case formatStyleTypes
        case placeholder
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let newTypes = try? container.decodeIfPresent([PhoneNumberFormatStyleType].self, forKey: .formatStyleTypes) {
            formatStyleTypes = newTypes
        }
        if let newPlaceHolder = try? container.decodeIfPresent(String.self, forKey: .placeholder), let characterPlaceholder = newPlaceHolder.first {
            placeholder = characterPlaceholder
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(formatStyleTypes, forKey: .formatStyleTypes)
        try container.encode(String(placeholder), forKey: .placeholder)
    }
    
}

/// Publicly available format styles to allow fluent build of the style
extension PhoneNumberFormatStyle {
    
    /// Return just the area code (e.g. 617)
    /// - Returns: Format style
    public func areaCode() -> PhoneNumberFormatStyle {
        return getNewFormatStyle(for: .areaCode)
    }
    
    /// Return just the phone number (e.g. 555-1212)
    /// - Returns: Format style
    public func number() -> PhoneNumberFormatStyle {
        return getNewFormatStyle(for: .phoneNumber)
    }
    
    /// Return the space between the area code and phone number
    /// - Returns: Format style
    public func space() -> PhoneNumberFormatStyle {
        return getNewFormatStyle(for: .space)
    }

    /// Return the parentheses around the area code
    /// - Returns: Format style
    public func parentheses() -> PhoneNumberFormatStyle {
        return getNewFormatStyle(for: .parentheses)
    }

    /// Return the hyphen in the middle of the phone number
    /// - Returns: Format style
    public func hyphen() -> PhoneNumberFormatStyle {
        return getNewFormatStyle(for: .hyphen)
    }
    
    /// Get a new phone number format style
    /// - Parameter newType: New type
    /// - Returns: Format style
    private func getNewFormatStyle(for newType: PhoneNumberFormatStyleType) -> PhoneNumberFormatStyle {
        if !formatStyleTypes.contains(newType) {
            var newTypes = formatStyleTypes
            newTypes.append(newType)
            return PhoneNumberFormatStyle(newTypes)
        }
        // If the user duplicated the type, just return that type
        return self
    }

}
