//
//  UIViewController+Extensions.swift
//  PennMobileShared
//
//  Created by Josh Doman on 12/13/16.
//  Copyright © 2016 Josh Doman. All rights reserved.
//

import UIKit

extension UIViewController {
    var pad: CGFloat { return Padding.pad }
}

public extension UIViewController {
    var isVisible: Bool {
        return self.isViewLoaded && self.view.window != nil
    }
}
