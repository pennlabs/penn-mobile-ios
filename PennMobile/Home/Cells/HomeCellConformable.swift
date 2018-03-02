//
//  HomeCellProtocol.swift
//  PennMobile
//
//  Created by Josh Doman on 3/1/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

protocol HomeCellDelegate {}

protocol HomeCellConformable where Self: UITableViewCell {
    static var identifier: String { get set }
    static var cellHeight: CGFloat { get set }
    
    var item: HomeViewModelItem? { get set }
    var delegate: HomeCellDelegate! { get set }
    
    var cardView: UIView! { get }
}

// - MARK: Prepare
extension HomeCellConformable {
    func prepareHomeCell() {
        self.backgroundColor = UIColor.white
        self.selectionStyle = .none
        prepareCardView()
        prepareTypeLabel()
    }
    
    fileprivate func prepareCardView() {
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 15.0
        cardView.layer.borderWidth = 1.0
        cardView.layer.borderColor = UIColor.clear.cgColor
        
        // Shadows
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        cardView.layer.shadowOpacity = 0.25
        cardView.layer.shadowRadius = 4.0
        
        addSubview(cardView)
        cardView.anchorWithConstantsToTop(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor,
                                          topConstant: 20, leftConstant: 20, bottomConstant: 20, rightConstant: 20)
    }
    
    fileprivate func prepareTypeLabel() {
        let typeLabel = UILabel()
        
        if let item = item {
            typeLabel.font = UIFont.systemFont(ofSize: 10)
            typeLabel.text = item.title
        }
        
        addSubview(typeLabel)
        typeLabel.anchorWithConstantsToTop(topAnchor, left: leftAnchor, bottom: nil, right: nil, topConstant: 4, leftConstant: 8, bottomConstant: 0, rightConstant: 0)
    }
}
