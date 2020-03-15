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
    
    static let height : CGFloat = 63.0
    
    fileprivate var firstLetterLbl: UILabel!
    
    var name: String! {
        didSet {
            if let lbl = firstLetterLbl {
                lbl.text = String(self.name.prefix(1).uppercased())
            }
        }
    }
    
    var groupColor: UIColor! {
        didSet {
            backgroundColor = groupColor
        }
    }
    
    init() {
        super.init(frame: CGRect.zero)
        prepareUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
}

// MARK - PREPARE UI
extension GSRGroupIconView {
    
    fileprivate func prepareUI() {
        prepareFirstLetterLbl()
        prepareConstraints()
    }
    
    fileprivate func prepareFirstLetterLbl() {
        layer.cornerRadius = GSRGroupIconView.height / 2
        layer.masksToBounds = true
        firstLetterLbl = UILabel()
        addSubview(firstLetterLbl)
        firstLetterLbl.textColor = UIColor.white
        firstLetterLbl.textAlignment = .center
        firstLetterLbl.font = UIFont.systemFont(ofSize: 38, weight: .bold)
        firstLetterLbl.translatesAutoresizingMaskIntoConstraints = false
        firstLetterLbl.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        firstLetterLbl.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }
    
    fileprivate func prepareConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 70).isActive = true
        widthAnchor.constraint(equalToConstant: 70).isActive = true
        layer.cornerRadius = 35
        layer.masksToBounds = true
    }
}
