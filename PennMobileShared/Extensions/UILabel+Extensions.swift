//
//  UILabel+Extensions.swift
//  PennMobileShared
//
//  Created by Josh Doman on 12/13/16.
//  Copyright © 2016 Josh Doman. All rights reserved.
//

import UIKit

public extension UILabel {
    func shrinkUntilFits() {
        self.allowsDefaultTighteningForTruncation = true
        self.adjustsFontSizeToFitWidth = true
        self.minimumScaleFactor = 0.3
        self.numberOfLines = 1
    }
}
