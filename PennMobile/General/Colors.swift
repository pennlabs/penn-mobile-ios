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
    
    /*static let warmGrey = UIColor(r: 115, g: 115, b: 115)
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
    static let spruceHarborBlue = UIColor(r: 41, g: 128, b: 185)*/
    
    // MARK: - Primary Palette
    static var baseDarkBlue = UIColor(named: "baseDarkBlue")
    static var baseLabsBlue = UIColor(named: "baseLabsBlue")
    
    // MARK: - Neutral Palette
    static var baseGrey = UIColor(named: "baseGrey") // base grey = grey50
    static var grey10 = UIColor(named: "grey10")
    static var grey20 = UIColor(named: "grey20")
    static var grey40 = UIColor(named: "grey40")
    static var grey60 = UIColor(named: "grey60")
    static var grey80 = UIColor(named: "grey80")
    static var grey90 = UIColor(named: "grey90")
    static var grey100 = UIColor(named: "grey100")
    
    // MARK: - Secondary Palette
    static var baseBlue = UIColor(named: "baseBlue")
    static var baseGreen = UIColor(named: "baseGreen")
    static var baseOrange = UIColor(named: "baseOrange")
    static var basePurple = UIColor(named: "basePurple")
    static var baseRed = UIColor(named: "baseRed")
    static var baseYellow = UIColor(named: "baseYellow")
    
    // MARK: - Extended Palette
    static var blueLight = UIColor(named: "blueLighter")
    static var blueLighter = UIColor(named: "blueLighter")
    static var blueDark = UIColor(named: "blueDark")
    static var blueDarker = UIColor(named: "blueDarker")
    
    static var greenLight = UIColor(named: "greenLighter")
    static var greenLighter = UIColor(named: "greenLighter")
    static var greenDark = UIColor(named: "greenDark")
    static var greenDarker = UIColor(named: "greenDarker")

    static var orangeLight = UIColor(named: "orangeLighter")
    static var orangeLighter = UIColor(named: "orangeLighter")
    static var orangeDark = UIColor(named: "orangeDark")
    static var orangeDarker = UIColor(named: "orangeDarker")

    static var purpleLight = UIColor(named: "purpleLighter")
    static var purpleLighter = UIColor(named: "purpleLighter")
    static var purpleDark = UIColor(named: "purpleDark")
    static var purpleDarker = UIColor(named: "purpleDarker")
    
    static var redLight = UIColor(named: "redLight")
    static var redLighter = UIColor(named: "redLighter")
    static var redDark = UIColor(named: "redDark")
    static var redDarker = UIColor(named: "redDarker")

    static var yellowLight = UIColor(named: "yellowLighter")
    static var yellowLighter = UIColor(named: "yellowLighter")
    static var yellowDark = UIColor(named: "yellowDark")
    static var yellowDarker = UIColor(named: "yellowDarker")
    
}
