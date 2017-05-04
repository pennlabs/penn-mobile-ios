//
//  Colors.swift
//  GSR
//
//  Created by Yagil Burowski on 17/09/2016.
//  Copyright © 2016 Yagil Burowski. All rights reserved.
//

import Foundation
import UIKit

enum Colors {
    case green, blue
    
    func color() -> UIColor {
        switch self {
        case .green:
            return UIColor(red: 216/255, green: 247/255, blue: 195/255, alpha: 1.0)
        case .blue:
            return UIColor(red: 63/255, green: 215/255, blue: 249/255, alpha: 1.0)
        }
    }
}
