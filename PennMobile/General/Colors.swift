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
    static var baseDarkBlue = UIColor(named: "baseDarkBlue")!
    static let baseLabsBlue = UIColor(named: "baseLabsBlue")!
    
    // MARK: - Neutral Palette
    static var grey1 = UIColor(named: "grey1")!
    static var grey2 = UIColor(named: "grey2")!
    static var grey3 = UIColor(named: "grey3")!
    static var grey4 = UIColor(named: "grey4")!
    static var grey5 = UIColor(named: "grey5")!
    static var grey6 = UIColor(named: "grey6")!
    
    // MARK: - Secondary Palette
    static var baseBlue = UIColor(named: "baseBlue")!
    static var baseGreen = UIColor(named: "baseGreen")!
    static var baseOrange = UIColor(named: "baseOrange")!
    static var basePurple = UIColor(named: "basePurple")!
    static var baseRed = UIColor(named: "baseRed")!
    static var baseYellow = UIColor(named: "baseYellow")!
    
    // MARK: - Extended Palette
    static var blueLight = UIColor(named: "blueLighter")!
    static var blueLighter = UIColor(named: "blueLighter")!
    static var blueDark = UIColor(named: "blueDark")!
    static var blueDarker = UIColor(named: "blueDarker")!
    
    static var greenLight = UIColor(named: "greenLighter")!
    static var greenLighter = UIColor(named: "greenLighter")!
    static var greenDark = UIColor(named: "greenDark")!
    static var greenDarker = UIColor(named: "greenDarker")!

    static var orangeLight = UIColor(named: "orangeLighter")!
    static var orangeLighter = UIColor(named: "orangeLighter")!
    static var orangeDark = UIColor(named: "orangeDark")!
    static var orangeDarker = UIColor(named: "orangeDarker")!

    static var purpleLight = UIColor(named: "purpleLighter")!
    static var purpleLighter = UIColor(named: "purpleLighter")!
    static var purpleDark = UIColor(named: "purpleDark")!
    static var purpleDarker = UIColor(named: "purpleDarker")!
    
    static var redLight = UIColor(named: "redLight")!
    static var redLighter = UIColor(named: "redLighter")!
    static var redDark = UIColor(named: "redDark")!
    static var redDarker = UIColor(named: "redDarker")!

    static var yellowLight = UIColor(named: "yellowLighter")!
    static var yellowLighter = UIColor(named: "yellowLighter")!
    static var yellowDark = UIColor(named: "yellowDark")!
    static var yellowDarker = UIColor(named: "yellowDarker")!
    
}
