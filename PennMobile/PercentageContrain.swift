//
//  PercentageContrain.swift
//  PennMobile
//
//  Created by Victor Chien on 2/11/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import Foundation

class PercentageContrain {

    var width: CGFloat!
    var height: CGFloat!

    init (w: CGFloat, h: CGFloat) {
        self.width = w
        self.height = h
    }

    func getConstraintX(percent: CGFloat) -> CGFloat{
        return width * (percent/100)
    }
    
    func getConstraintY(percent: CGFloat) -> CGFloat{
        return height * (percent/100)
    }
}
