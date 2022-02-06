//
//  CELoginController.swift
//  PennMobile
//
//  Created by Josh Doman on 10/3/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation
import WebKit

class CampusExpressLoginController: PennLoginController {
        
    override var urlStr: String {
        return "https://prod.campusexpress.upenn.edu/mainmenu.jsp"
    }
}
