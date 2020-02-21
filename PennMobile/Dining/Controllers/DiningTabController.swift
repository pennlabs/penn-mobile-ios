//
//  DiningTabController.swift
//  PennMobile
//
//  Created by Elizabeth Powell on 2/8/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import Foundation
import XLPagerTabStrip

class DiningTabController: ButtonBarPagerTabStripViewController {
    
    fileprivate var ownContainerView: UIScrollView!
    fileprivate var barView: ButtonBarView!
    
    override func viewDidLoad() {
        settings.style.buttonBarBackgroundColor = .uiBackground
        settings.style.buttonBarItemBackgroundColor = .uiBackground
        settings.style.selectedBarBackgroundColor = .baseLabsBlue
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemsShouldFillAvailableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
        settings.style.selectedBarHeight = 0
        edgesForExtendedLayout = []
          
        let barView = ButtonBarView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        self.barView = barView
        let separatorLine = UIView()
        separatorLine.backgroundColor = UIColor.grey1
        let containerView = UIScrollView()
        self.ownContainerView = containerView
        self.view.addSubview(barView)
        self.view.addSubview(separatorLine)
        self.view.addSubview(ownContainerView)
        self.buttonBarView = self.barView
        self.containerView = containerView
        
        _ = barView.anchor(self.view.safeAreaLayoutGuide.topAnchor, left: self.view.leftAnchor, bottom: nil, right: self.view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 50)
        _ = separatorLine.anchor(barView.bottomAnchor, left: self.view.leftAnchor, bottom: nil, right: self.view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 1)
        _ = ownContainerView.anchor(separatorLine.bottomAnchor, left: self.view.leftAnchor, bottom: self.view.safeAreaLayoutGuide.bottomAnchor, right: self.view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        self.ownContainerView.isHidden = true
        
        super.viewDidLoad()
        
        changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = .labelPrimary
            newCell?.label.textColor = .baseBlue
        }
        
        view.backgroundColor = .uiBackground
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let topSpace:CGFloat?
        if #available(iOS 11.0, *) {
            topSpace = self.view.safeAreaInsets.top
        } else {
            topSpace = self.topLayoutGuide.length
        }
        if let topSpace = topSpace, topSpace > 0 {
            self.ownContainerView.isHidden = false
        }
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let child1 = DiningViewController()
        let child2: UIViewController!
        if #available(iOS 13, *) {
            child2 = DiningStatisticsViewController()
        } else {
            // TODO: Implement a controller with a message prompting iOS 13. Also be sure to give it a pagertabstrip extension.
            child2 = UIViewController()
        }

        return [child1, child2]
    }
}

extension DiningViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Locations")
    }
}

@available(iOS 13, *)
extension DiningStatisticsViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Statistics")
    }
}
