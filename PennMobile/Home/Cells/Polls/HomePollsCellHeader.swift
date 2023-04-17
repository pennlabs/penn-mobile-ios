//
//  HomeCellHeader.swift
//  PennMobile
//
//  Created by Dominic Holmes on 3/6/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import UIKit
import SnapKit

class HomePollsCellHeader: UIView {

    var secondaryTitleLabel: UILabel!
    var primaryTitleLabel: UILabel!
    var voteCountLabel: UILabel!
    private var dividerLine: UIView!

    // Must be called after being added to a view
    func prepare() {
        prepareHeader(inside: self.superview ?? UIView())
        prepareTitleLabels()
        prepareVoteCountLabel()
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
            make.trailing.equalTo(self)
        }
    }
    func prepareVoteCountLabel() {
        voteCountLabel = getVoteCountLabel()
        addSubview(voteCountLabel)
        voteCountLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(self)
            make.top.equalTo(primaryTitleLabel.snp.bottom).offset(3)
            make.trailing.equalTo(self)
        }
    }
    private func getVoteCountLabel() -> UILabel {
        let label = UILabel()
        label.font = .secondaryTitleFont
        label.textColor = .labelSecondary
        label.textAlignment = .left
        return label
    }

    // MARK: Divider Line
    private func prepareDividerLine() {
        dividerLine = getDividerLine()
        addSubview(dividerLine)
        dividerLine.snp.makeConstraints { (make) in
            make.leading.equalTo(self)
            make.trailing.equalTo(self)
            make.top.equalTo(voteCountLabel.snp.top).offset(15)
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
        label.font = .pollsTitleFont
        label.textColor = .labelPrimary
        label.textAlignment = .left
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        return label
    }

    private func getDividerLine() -> UIView {
        let view = UIView()
        view.backgroundColor = .grey5
        view.layer.cornerRadius = 2.0
        return view
    }
}
