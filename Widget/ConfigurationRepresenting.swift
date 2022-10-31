//
//  ConfigurationIntent.swift
//  PennMobile
//
//  Created by Anthony Li on 10/31/22.
//  Copyright © 2022 PennLabs. All rights reserved.
//

import Foundation

protocol ConfigurationRepresenting {
    associatedtype Configuration
    
    var configuration: Configuration { get }
}
