//
//  EmptyView.swift
//  PennMobile
//
//  Created by Josh Doman on 5/14/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import UIKit

class EmptyView: UIView {
    
    private let label: UILabel = {
        let lbl = UILabel()
        lbl.text = "No results found"
        lbl.textColor = UIColor.warmGrey
        lbl.font = UIFont.helvetica?.withSize(24)
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        
        addSubview(label)
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -40).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
