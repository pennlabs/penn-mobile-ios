//
//  EmptyView.swift
//  PennMobile
//
//  Created by Josh Doman on 6/6/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import UIKit

class EmptyView: UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .red
        selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
