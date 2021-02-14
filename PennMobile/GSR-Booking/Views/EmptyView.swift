//
//  EmptyView.swift
//  PennMobile
//
//  Created by Josh Doman on 6/6/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import UIKit

class EmptyView: UIView {
    
    private let label: UILabel = {
        let l = UILabel()
        l.font = UIFont(name: "HelveticaNeue", size: 24)
        l.text = "No results found"
        l.textColor = UIColor.labelSecondary
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        
        addSubview(label)
        
        label.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -60).isActive = true
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
