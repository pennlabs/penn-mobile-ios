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
            //titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: (imageView?.frame.width)!)
            //imageEdgeInsets = UIEdgeInsets(top: 5, left: (bounds.width - 35), bottom: 5, right: 5)
            imageEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
            titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
            
        }
    }
}
