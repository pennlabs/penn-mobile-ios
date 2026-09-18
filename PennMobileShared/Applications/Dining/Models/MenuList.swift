//
//  MenuList.swift
//  PennMobile
//
//  Created by CHOI Jongmin on 26/6/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import Foundation

public struct MenuList: Codable {
    public static let directory = "diningMenus.json"

    public let menus: [DiningMenu]
    
    public init(menus: [DiningMenu]) {
        self.menus = menus
    }
}
