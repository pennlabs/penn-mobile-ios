//
//  HomeCellHeader.swift
//  PennMobile
//
//  Created by Dominic Holmes on 3/6/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import UIKit
import SnapKit

class HomeCellHeader: UIView {
    
    static let height: CGFloat = 63

    var secondaryTitleLabel: UILabel!
    var primaryTitleLabel: UILabel!
    private var dividerLine: UIView!
    
    // Must be called after being added to a view
    func prepare() {
        prepareHeader(inside: self.superview ?? UIView())
        prepareTitleLabels()
        prepareDividerLine()
    }
    
    // MARK: Header
    private func prepareHeader(inside safeArea: UIView) {
        self.snp.makeConstraints { (make) in
            make.leading.equalTo(safeArea)
            make.top.equalTo(safeArea)
            make.trailing.equalTo(safeArea)
            make.height.equalTo(HomeCellHeader.height)
        }
    }

    // MARK: Labels
    private func prepareTitleLabels() {
        secondaryTitleLabel = getSecondaryLabel()
        primaryTitleLabel = getPrimaryLabel()

        addSubview(secondaryTitleLabel)
        addSubview(primaryTitleLabel)
        
        secondaryTitleLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(self)
            make.top.equalTo(self).offset(3)
        }
        
        primaryTitleLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(self)
            make.top.equalTo(secondaryTitleLabel.snp.bottom).offset(4)
        }
    }

    // MARK: Divider Line
    private func prepareDividerLine() {
        dividerLine = getDividerLine()
        addSubview(dividerLine)
        dividerLine.snp.makeConstraints { (make) in
            make.leading.equalTo(self)
            make.trailing.equalTo(self)
            make.bottom.equalTo(self)
            make.height.equalTo(2)
        }
    }
    
    // MARK: - Lable Definitions
    private func getSecondaryLabel() -> UILabel {
        let label = UILabel()
        label.font = .secondaryTitleFont
        label.textColor = .labelSecondary
        label.textAlignment = .left
        return label
    }

    private func getPrimaryLabel() -> UILabel {
        let label = UILabel()
        label.font = .primaryTitleFont
        label.textColor = .labelPrimary
        label.textAlignment = .left
        return label
    }

    private func getDividerLine() -> UIView {
        let view = UIView()
        view.backgroundColor = .grey5
        view.layer.cornerRadius = 2.0
        return view
    }
}
