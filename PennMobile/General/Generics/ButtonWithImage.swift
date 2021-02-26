//
//  ButtonWithImage.swift
//  PennMobile
//
//  Created by Raunaq Singh on 11/8/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import Foundation

class ButtonWithImage: UIButton {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if imageView != nil {
            imageEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
            titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        }
    }
}
