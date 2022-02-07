//
//  HomeCellProtocol.swift
//  PennMobile
//
//  Created by Josh Doman on 3/1/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

protocol HomeCellDelegate: ModularTableViewCellDelegate,
    LaundryMachineCellTappable,
    DiningCellSelectable,
    GSRBookingSelectable,
    URLSelectable,
    ReservationCellDelegate,
    BuildingMapSelectable,
    CourseRefreshable,
    CourseLoginable,
    FeatureNavigatable,
    GSRInviteSelectable{}

protocol HomeCellConformable: ModularTableViewCell where Self: UITableViewCell {
    var cardView: UIView! { get }
}

// - MARK: Prepare
extension HomeCellConformable {
    func prepareHomeCell() {
        self.backgroundColor = .clear
        self.selectionStyle = .none
        prepareCardView()
    }

    fileprivate func prepareCardView() {
        cardView.backgroundColor = .uiCardBackground
        cardView.layer.cornerRadius = 14.0
        cardView.layer.borderWidth = 1.0
        cardView.layer.borderColor = UIColor.clear.cgColor

        // Shadows
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        cardView.layer.shadowOpacity = 0.25
        cardView.layer.shadowRadius = 4.0

        addSubview(cardView)
        cardView.anchorWithConstantsToTop(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor,
                                          topConstant: HomeViewController.cellSpacing, leftConstant: HomeViewController.edgeSpacing, bottomConstant: 0, rightConstant: HomeViewController.edgeSpacing)
    }
}
