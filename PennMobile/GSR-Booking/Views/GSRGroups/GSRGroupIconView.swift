//
//  GSRGroupIconView.swift
//  PennMobile
//
//  Created by Rehaan Furniturewala on 12/8/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import UIKit

class GSRGroupIconView: UIView {
    //creates a circular icon with color and letter for icon
    
    fileprivate var firstLetterLbl: UILabel!
    var name: String! {
        didSet {
            if let lbl = firstLetterLbl {
                lbl.text = String(self.name.prefix(1))
            }
        }
    }
    
    init() {
        super.init(frame: CGRect.zero)
        prepareUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

// MARK - PREPARE UI
extension GSRGroupIconView {
    
    fileprivate func prepareUI() {
        prepareFirstLetterLbl()
    }
    
    fileprivate func prepareFirstLetterLbl() {
        firstLetterLbl = UILabel()
        addSubview(firstLetterLbl)
        firstLetterLbl.textColor = UIColor.white
        firstLetterLbl.textAlignment = .center
        firstLetterLbl.font = UIFont.systemFont(ofSize: 38, weight: .bold)
        _ = firstLetterLbl.anchor(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
}
