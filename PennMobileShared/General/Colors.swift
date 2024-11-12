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

public extension UIColor {

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

public extension UIColor {

    // for getting a lighter variant (using a multiplier)
    func borderColor(multiplier: CGFloat) -> UIColor {
        let rgba = self.rgba
        return UIColor(red: rgba.red * multiplier, green: rgba.green * multiplier, blue: rgba.blue * multiplier, alpha: rgba.alpha)
    }

    var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        // returns rgba colors.
        return (red, green, blue, alpha)
    }
}

import SwiftUI

public extension Color {
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
    static let baseDarkBlue = Color("baseDarkBlue")
    static let baseLabsBlue = Color("baseLabsBlue")

    // MARK: - Neutral Palette
    static let grey1 = Color("grey1")
    static let grey2 = Color("grey2")
    static let grey3 = Color("grey3")
    static let grey4 = Color("grey4")
    static let grey5 = Color("grey5")
    static let grey6 = Color("grey6")
    static let grey7 = Color("grey7")

    // MARK: - Secondary Palette
    static let baseBlue = Color("baseBlue")
    static let baseGreen = Color("baseGreen")
    static let baseOrange = Color("baseOrange")
    static let basePurple = Color("basePurple")
    static let baseRed = Color("baseRed")
    static let baseYellow = Color("baseYellow")

    // MARK: - Extended Palette
    static let blueLight = Color("blueLight")
    static let blueLighter = Color("blueLighter")
    static let blueDark = Color("blueDark")
    static let blueDarker = Color("blueDarker")

    static let greenLight = Color("greenLight")
    static let greenLighter = Color("greenLighter")
    static let greenDark = Color("greenDark")
    static let greenDarker = Color("greenDarker")

    static let orangeLight = Color("orangeLight")
    static let orangeLighter = Color("orangeLighter")
    static let orangeDark = Color("orangeDark")
    static let orangeDarker = Color("orangeDarker")

    static let purpleLight = Color("purpleLight")
    static let purpleLighter = Color("purpleLighter")
    static let purpleDark = Color("purpleDark")
    static let purpleDarker = Color("purpleDarker")

    static let redLight = Color("redLight")
    static let redLighter = Color("redLighter")
    static let redDark = Color("redDark")
    static let redDarker = Color("redDarker")

    static let yellowLight = Color("yellowLight")
    static let yellowLighter = Color("yellowLighter")
    static let yellowDark = Color("yellowDark")
    static let yellowDarker = Color("yellowDarker")
}
