//
//  HomePollsCellFooter.swift
//  PennMobile
//
//  Created by Lucy Yuewei Yuan on 10/18/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import UIKit
import SnapKit

class HomePollsCellFooter: UIView {
    
    static let height: CGFloat = 16
    var noteLabel: UILabel!
    private var dividerLine: UIView!
//    
    // Must be called after being added to a view
    func prepare() {
        prepareFooter(inside: self.superview ?? UIView())
        prepareNoteLabel()
        prepareDividerLine()
    }
    
    // MARK: Footer
    private func prepareFooter(inside safeArea: UIView) {
        self.snp.makeConstraints { (make) in
            make.leading.equalTo(safeArea)
            make.bottom.equalTo(safeArea)
            make.trailing.equalTo(safeArea)
            make.height.equalTo(HomePollsCellFooter.height)
        }
    }

    // MARK: Labels
    private func prepareNoteLabel() {
        
        noteLabel = getNoteLabel()

        addSubview(noteLabel)
        
        noteLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(self)
            make.bottom.equalTo(self).offset(3)
            make.trailing.equalTo(self)
        }
    }

    // MARK: Divider Line
    private func prepareDividerLine() {
        dividerLine = getDividerLine()
        addSubview(dividerLine)
        dividerLine.snp.makeConstraints { (make) in
            make.leading.equalTo(self)
            make.trailing.equalTo(self)
            make.top.equalTo(self)
            make.height.equalTo(2)
        }
    }


    private func getNoteLabel() -> UILabel {
        let label = UILabel()
        label.font = .footerDescriptionFont
        label.textColor = .labelSecondary
        label.textAlignment = .left
        label.text = "Penn Mobile anonymously shares info with the organization."
        label.numberOfLines = 1
        return label
    }

    private func getDividerLine() -> UIView {
        let view = UIView()
        view.backgroundColor = .grey5
        view.layer.cornerRadius = 2.0
        return view
    }
}
