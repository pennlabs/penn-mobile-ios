//
//  UIApplication+Extensions.swift
//  PennMobileShared
//
//  Created by Josh Doman on 12/13/16.
//  Copyright © 2016 Josh Doman. All rights reserved.
//

import UIKit

extension UIApplication {
    public static var isRunningFastlaneTest: Bool {
        return ProcessInfo().arguments.contains("FASTLANE")
    }
}
