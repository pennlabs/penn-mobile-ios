//
//  GSRTabController.swift
//  PennMobile
//
//  Created by Josh Doman on 4/6/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation
import XLPagerTabStrip

class GSRTabController: ButtonBarPagerTabStripViewController {

    fileprivate var ownContainerView: UIScrollView!
    fileprivate var barView: ButtonBarView!
    fileprivate var separatorLine: UIView!

    override func viewDidLoad() {
        settings.style.buttonBarBackgroundColor = .uiBackground
        settings.style.buttonBarItemBackgroundColor = .uiBackground
        settings.style.selectedBarBackgroundColor = .baseLabsBlue
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemsShouldFillAvailableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
        settings.style.selectedBarHeight = 0
        // edgesForExtendedLayout = []

//        let barView = ButtonBarView(frame: CGRect(x: 0.0, y: (88 + 0.0), width: self.view.bounds.width, height: 50.0), collectionViewLayout: UICollectionViewFlowLayout())
//        self.barView = barView
//        let separatorLine = UIView(frame: CGRect(x: 0.0, y: (88 + 50.0), width: self.view.bounds.width, height: 1.0))
//        separatorLine.backgroundColor = UIColor.grey1
//        let containerView = UIScrollView(frame: CGRect(x: 0, y: (88 + 51.0), width: self.view.bounds.width, height: self.view.bounds.height - (88+50.0) - 66.0))
//        self.ownContainerView = containerView
//        self.view.addSubview(barView)
//        self.view.addSubview(separatorLine)
//        self.view.addSubview(ownContainerView)
//        self.buttonBarView = self.barView
//        self.containerView = containerView

        let barView = ButtonBarView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        self.barView = barView
        separatorLine = UIView()
        separatorLine.backgroundColor = UIColor.grey1
        let containerView = UIScrollView()
        self.ownContainerView = containerView
        self.view.addSubview(barView)
        self.view.addSubview(separatorLine)
        self.view.addSubview(ownContainerView)
        self.buttonBarView = self.barView
        self.containerView = containerView
        self.title = "Study Room Booking"
        self.tabBarController?.title = "GSR"
        self.tabBarItem.title = "GSR"

        _ = barView.anchor(self.view.safeAreaLayoutGuide.topAnchor, left: self.view.leftAnchor, bottom: nil, right: self.view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 50)
        _ = separatorLine.anchor(barView.bottomAnchor, left: self.view.leftAnchor, bottom: nil, right: self.view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 1)
        _ = ownContainerView.anchor(separatorLine.bottomAnchor, left: self.view.leftAnchor, bottom: self.view.safeAreaLayoutGuide.bottomAnchor, right: self.view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)

        super.viewDidLoad()

        changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, _: CGFloat, changeCurrentIndex: Bool, _: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = .labelPrimary
            newCell?.label.textColor = .baseBlue
        }

        view.backgroundColor = .uiBackground
    }

    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let child1 = GSRLocationsController()
        let child2 = GSRReservationsController()

        if UserDefaults.standard.gsrGroupsEnabled() {
            let child3 = GSRGroupController()
            return [child1, child2, child3]
        }

        return [child1, child2]
    }
}

extension GSRLocationsController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Book")
    }
}

extension GSRReservationsController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Reservations")
    }
}

extension GSRGroupController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Groups")
    }
}
