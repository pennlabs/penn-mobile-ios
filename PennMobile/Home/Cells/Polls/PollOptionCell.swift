//
//  PollsCell.swift
//  PennMobile
//
//  Created by Lucy Yuewei Yuan on 9/27/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import UIKit
import SnapKit

class PollOptionCell: UITableViewCell {
    
    static let identifier = "pollOptionCell"
    static let cellHeight: CGFloat = 110
    
    var question: String! {
        didSet {
            setupCell()
        }
    }
    
    var response: Int! {
        didSet {
            setupCell()
        }
    }
    
    
    // MARK: - UI Elements
    fileprivate var safeArea: UIView!
    fileprivate var questionLabel: UILabel!

    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        prepareSafeArea()
        prepareUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup Cell
extension PollOptionCell {
    fileprivate func setupCell() {
        backgroundColor = .clear
        self.questionLabel.text = self.question
        
        
    }
    
}

// MARK: - Initialize and Layout UI Elements
extension PollOptionCell {
    
    fileprivate func prepareUI() {
        self.accessoryType = .disclosureIndicator
        prepareLabels()
    }
    
    // MARK: Safe Area
    fileprivate func prepareSafeArea() {
        safeArea = UIView()
        addSubview(safeArea)
        
        safeArea.snp.makeConstraints { (make) in
            make.leading.equalTo(self).offset(pad)
            make.trailing.equalTo(self).offset(-pad * 2)
            make.top.equalTo(self).offset(pad)
            make.bottom.equalTo(self).offset(-pad)
        }
    }
    
    
    // MARK: Labels
    fileprivate func prepareLabels() {
        questionLabel = getQuestionLabel()
        
        addSubview(questionLabel)
        
        questionLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(safeArea).offset(8)
            make.top.equalTo(safeArea).offset(3)
            make.trailing.equalTo(safeArea).offset(-8)
        }
    }
}

// MARK: - Define UI Elements
extension PollOptionCell {
    
    fileprivate func getQuestionLabel() -> UILabel {
        let label = UILabel()
        label.font = .interiorTitleFont
        label.textColor = .labelPrimary
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }
    
}

