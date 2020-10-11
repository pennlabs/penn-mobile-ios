//
//  HomeCellSafeArea.swift
//  PennMobile
//
//  Created by Dominic Holmes on 3/7/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import UIKit
import SnapKit

class HomeCellSafeArea: UIView {
    
    // Must be called after being added to a view
    func prepare() {
        let inside = self.superview ?? UIView()
        self.snp.makeConstraints { (make) in
            make.leading.equalTo(inside).offset(pad)
            make.top.equalTo(inside).offset(pad)
            make.trailing.equalTo(inside).offset(-pad)
            make.bottom.equalTo(inside).offset(-pad)
        }
    }
    
}
