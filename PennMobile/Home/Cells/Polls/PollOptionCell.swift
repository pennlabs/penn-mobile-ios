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
    
    
    var question: String! 
    
    var response: Int!
    
    var totalResponses: Int!
    
    var answered: Bool!
    
    var chosen: Bool! {
        didSet {
            setupCell()
        }
    }
    
    
    
    
    // MARK: - UI Elements
    fileprivate var safeArea: UIView!
    fileprivate var questionLabel: UILabel!
    fileprivate var percentageShadow: UIView!
    
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
        preparePercentageShadowView()
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
    
    //MARK: percentage shadow
    fileprivate func preparePercentageShadowView() {
        percentageShadow = UIView()
        percentageShadow.layer.cornerRadius = 10
        percentageShadow.layer.masksToBounds = true
        
        safeArea.addSubview(percentageShadow)
        
        let maxWidth = CGFloat(0.8) * UIScreen.main.bounds.width
        
        
        
        if self.answered == true {
            let width = CGFloat(self.response / self.totalResponses) * maxWidth
            percentageShadow.backgroundColor = self.chosen ? .blueLighter : .lightGray
            safeArea.addSubview(percentageShadow)
            percentageShadow.snp.makeConstraints {(make) in
                make.leading.equalTo(safeArea).offset(3)
                make.top.equalTo(safeArea).offset(3)
                make.width.equalTo(width)
                make.bottom.equalTo(safeArea).offset(3)
            }
        } else {
            percentageShadow.backgroundColor = .greenLighter
            safeArea.addSubview(percentageShadow)
            percentageShadow.snp.makeConstraints {(make) in
                make.leading.equalTo(safeArea).offset(3)
                make.top.equalTo(safeArea).offset(3)
                make.width.equalTo(maxWidth)
//                make.trailing.equalTo(safeArea).offset(-8)
                make.bottom.equalTo(safeArea).offset(3)
            }
        }
        
    }
    
    // MARK: Labels
    fileprivate func prepareLabels() {
        questionLabel = getQuestionLabel()
        
        percentageShadow.addSubview(questionLabel)
        
        questionLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(percentageShadow).offset(8)
            make.top.equalTo(percentageShadow).offset(3)
            make.trailing.equalTo(percentageShadow).offset(-8)
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

