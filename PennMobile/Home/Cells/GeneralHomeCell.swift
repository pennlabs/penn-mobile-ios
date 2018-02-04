//
//  AbstractHomeCell.swift
//  PennMobile
//
//  Created by Josh Doman on 1/17/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation
import UIKit

protocol GeneralHomeCellDelegate: TransitionDelegate {}

class GeneralHomeCell: UITableViewCell {
    
    var item: HomeViewModelItem? {
        didSet {
            guard let item = item else { return }
            setupCell(for: item)
        }
    }
    
    var delegate: GeneralHomeCellDelegate!
    
    fileprivate var typeLabel: UILabel!
    fileprivate var cardView: UIView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        prepareBackground()
        prepareTypeLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup and Prepare UI Elements
extension GeneralHomeCell {
    fileprivate func prepareBackground() {
        backgroundColor = UIColor.whiteGrey
        
        cardView = UIView()

        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 15.0
        
        // Shadows
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        cardView.layer.shadowOpacity = 0.25
        cardView.layer.shadowRadius = 4.0
        
        addSubview(cardView)
        cardView.anchorWithConstantsToTop(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor,
                                          topConstant: 10, leftConstant: 10, bottomConstant: 10, rightConstant: 10)
    }
    
    fileprivate func prepareTypeLabel() {
        typeLabel = UILabel()
        typeLabel.font = UIFont.systemFont(ofSize: 10)
        
        addSubview(typeLabel)
        typeLabel.anchorWithConstantsToTop(topAnchor, left: leftAnchor, bottom: nil, right: nil, topConstant: 4, leftConstant: 8, bottomConstant: 0, rightConstant: 0)
    }
    
    fileprivate func setupCell(for item: HomeViewModelItem) {
        typeLabel.text = item.title
    }
}
