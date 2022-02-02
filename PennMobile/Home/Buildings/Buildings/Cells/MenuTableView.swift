//
//  MenuTableView.swift
//  PennMobile
//
//  Created by Dominic Holmes on 8/9/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

class MenuTableView: UITableView {
    override var contentSize:CGSize {
        didSet {
            self.invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize {
        self.layoutIfNeeded()
        return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
    }
}
