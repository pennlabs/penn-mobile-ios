//
//  Colors.swift
//  PennMobile
//
//  Created by Dominic Holmes on 10/23/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import UIKit

/*
These colors correspond with color themes defined in Assets.xcassets. Each color variable has a dark and light variant, which the system automatically switches depending on the UI mode (light or dark). They are defined in the Asset catalog to avoid backward compatibility issues with pre-iOS 13 versions. Defining them here would result in verbose code and lots of #ifavailible statements.
*/

extension UIColor {

    // MARK: - UI Palette
    static let navigation = UIColor(named: "navigation")!
    static let uiCardBackground = UIColor(named: "uiCardBackground")!
    static let uiGroupedBackground = UIColor(named: "uiGroupedBackground")!
    static let uiGroupedBackgroundSecondary = UIColor(named: "uiGroupedBackgroundSecondary")!
    static let uiBackground = UIColor(named: "uiBackground")!
    static let uiBackgroundSecondary = UIColor(named: "uiBackgroundSecondary")!
    static let labelPrimary = UIColor(named: "labelPrimary")!
    static let labelSecondary = UIColor(named: "labelSecondary")!
    static let labelTertiary = UIColor(named: "labelTertiary")!
    static let labelQuaternary = UIColor(named: "labelQuaternary")!

    // MARK: - Primary Palette
    static let baseDarkBlue = UIColor(named: "baseDarkBlue")!
    static let baseLabsBlue = UIColor(named: "baseLabsBlue")!

    // MARK: - Neutral Palette
    static let grey1 = UIColor(named: "grey1")!
    static let grey2 = UIColor(named: "grey2")!
    static let grey3 = UIColor(named: "grey3")!
    static let grey4 = UIColor(named: "grey4")!
    static let grey5 = UIColor(named: "grey5")!
    static let grey6 = UIColor(named: "grey6")!

    // MARK: - Secondary Palette
    static let baseBlue = UIColor(named: "baseBlue")!
    static let baseGreen = UIColor(named: "baseGreen")!
    static let baseOrange = UIColor(named: "baseOrange")!
    static let basePurple = UIColor(named: "basePurple")!
    static let baseRed = UIColor(named: "baseRed")!
    static let baseYellow = UIColor(named: "baseYellow")!

    // MARK: - Extended Palette
    static let blueLight = UIColor(named: "blueLight")!
    static let blueLighter = UIColor(named: "blueLighter")!
    static let blueDark = UIColor(named: "blueDark")!
    static let blueDarker = UIColor(named: "blueDarker")!

    static let greenLight = UIColor(named: "greenLight")!
    static let greenLighter = UIColor(named: "greenLighter")!
    static let greenDark = UIColor(named: "greenDark")!
    static let greenDarker = UIColor(named: "greenDarker")!

    static let orangeLight = UIColor(named: "orangeLight")!
    static let orangeLighter = UIColor(named: "orangeLighter")!
    static let orangeDark = UIColor(named: "orangeDark")!
    static let orangeDarker = UIColor(named: "orangeDarker")!

    static let purpleLight = UIColor(named: "purpleLight")!
    static let purpleLighter = UIColor(named: "purpleLighter")!
    static let purpleDark = UIColor(named: "purpleDark")!
    static let purpleDarker = UIColor(named: "purpleDarker")!

    static let redLight = UIColor(named: "redLight")!
    static let redLighter = UIColor(named: "redLighter")!
    static let redDark = UIColor(named: "redDark")!
    static let redDarker = UIColor(named: "redDarker")!

    static let yellowLight = UIColor(named: "yellowLight")!
    static let yellowLighter = UIColor(named: "yellowLighter")!
    static let yellowDark = UIColor(named: "yellowDark")!
    static let yellowDarker = UIColor(named: "yellowDarker")!
}

extension UIColor {

    //for getting a lighter variant (using a multiplier)
    func borderColor(multiplier: CGFloat) -> UIColor {
        let rgba = self.rgba
        return UIColor(red: rgba.red * multiplier , green: rgba.green * multiplier, blue: rgba.blue * multiplier, alpha: rgba.alpha)
    }

    var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        //returns rgba colors.
        return (red, green, blue, alpha)
    }
}

import SwiftUI

@available(iOS 14, *)
extension Color {
    // MARK: - UI Palette
    static let navigation = Color("navigation")
    static let uiCardBackground = Color("uiCardBackground")
    static let uiGroupedBackground = Color("uiGroupedBackground")
    static let uiGroupedBackgroundSecondary = Color("uiGroupedBackgroundSecondary")
    static let uiBackground = Color("uiBackground")
    static let uiBackgroundSecondary = Color("uiBackgroundSecondary")
    static let labelPrimary = Color("labelPrimary")
    static let labelSecondary = Color("labelSecondary")
    static let labelTertiary = Color("labelTertiary")
    static let labelQuaternary = Color("labelQuaternary")

    // MARK: - Primary Palette
    static var baseDarkBlue = Color("baseDarkBlue")
    static let baseLabsBlue = Color("baseLabsBlue")

    // MARK: - Neutral Palette
    static var grey1 = Color("grey1")
    static var grey2 = Color("grey2")
    static var grey3 = Color("grey3")
    static var grey4 = Color("grey4")
    static var grey5 = Color("grey5")
    static var grey6 = Color("grey6")

    // MARK: - Secondary Palette
    static var baseBlue = Color("baseBlue")
    static var baseGreen = Color("baseGreen")
    static var baseOrange = Color("baseOrange")
    static var basePurple = Color("basePurple")
    static var baseRed = Color("baseRed")
    static var baseYellow = Color("baseYellow")

    // MARK: - Extended Palette
    static var blueLight = Color("blueLighter")
    static var blueLighter = Color("blueLighter")
    static var blueDark = Color("blueDark")
    static var blueDarker = Color("blueDarker")

    static var greenLight = Color("greenLighter")
    static var greenLighter = Color("greenLighter")
    static var greenDark = Color("greenDark")
    static var greenDarker = Color("greenDarker")

    static var orangeLight = Color("orangeLighter")
    static var orangeLighter = Color("orangeLighter")
    static var orangeDark = Color("orangeDark")
    static var orangeDarker = Color("orangeDarker")

    static var purpleLight = Color("purpleLighter")
    static var purpleLighter = Color("purpleLighter")
    static var purpleDark = Color("purpleDark")
    static var purpleDarker = Color("purpleDarker")

    static var redLight = Color("redLight")
    static var redLighter = Color("redLighter")
    static var redDark = Color("redDark")
    static var redDarker = Color("redDarker")

    static var yellowLight = Color("yellowLighter")
    static var yellowLighter = Color("yellowLighter")
    static var yellowDark = Color("yellowDark")
    static var yellowDarker = Color("yellowDarker")
}
