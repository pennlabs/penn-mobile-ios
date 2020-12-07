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
    static let cellHeight: CGFloat = 90
    
    
    var question: String! 
    
    var response: Int!
    
    var totalResponses: Int!
    
    var answered: Bool! {
        didSet {
            setupCell()
        }
    }
    
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
        
        if self.answered == true {
            let maxWidth = CGFloat(0.8) * UIScreen.main.bounds.width
            let width = CGFloat(self.response) / CGFloat(self.totalResponses) * maxWidth
            percentageShadow.snp.updateConstraints {(make) in
                make.width.equalTo(width)
            }
            
            let anim = UIViewPropertyAnimator(duration: 0.5, curve: .easeInOut) {
                self.percentageShadow.backgroundColor = self.chosen ? .blueLighter : .lightGray
                self.percentageShadow.superview!.layoutIfNeeded()
            }
            
            anim.startAnimation()
        }
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
        
        percentageShadow.backgroundColor = .greenLighter
        safeArea.addSubview(percentageShadow)
        percentageShadow.snp.makeConstraints {(make) in
            make.leading.equalTo(safeArea)
            make.top.equalTo(safeArea)
            make.width.equalTo(maxWidth)
            make.bottom.equalTo(safeArea)
        }
        
    }
    
    // MARK: Labels
    fileprivate func prepareLabels() {
        questionLabel = getQuestionLabel()
        
        safeArea.addSubview(questionLabel)
        
        questionLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(safeArea).offset(15)
            make.trailing.equalTo(safeArea).offset(-20)
            make.centerY.equalToSuperview()
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
        label.numberOfLines = 2
        return label
    }
    
}

