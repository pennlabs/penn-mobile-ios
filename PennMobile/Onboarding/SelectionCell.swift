//
//  OnboardingSelectionCell.swift
//  PennMobile
//
//  Created by Josh Doman on 11/11/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import UIKit

protocol SelectionCellDelegate: class {
    func handleCancel()
    func saveSelection(for rooms: [LaundryRoom])
}

class SelectionCell: UICollectionViewCell, RoomSelectionViewDelegate {

    private var selectionView: RoomSelectionView!
    private var navigationBar: NavigationBar!
    
    weak var delegate: SelectionCellDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        
        navigationBar = NavigationBar(frame: .zero)
        navigationBar.customHeight = 44 + UIApplication.shared.statusBarFrame.height
        navigationBar.frame.size = navigationBar.sizeThatFits(CGSize(width: UIScreen.main.bounds.size.width, height: navigationBar.customHeight))
        
        selectionView = RoomSelectionView(frame: .zero)
        selectionView?.delegate = self
        selectionView?.prepare(with: nil)
        
        addSubview(selectionView)
        addSubview(navigationBar)
        
        selectionView.anchorToTop(navigationBar.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor)
        
        let item = UINavigationItem()
        let titleLabel = UILabel(frame: .zero)
        titleLabel.text = "0/\(selectionView.maxNumRooms) Chosen"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        item.titleView = titleLabel
        item.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(handleCancel))
        item.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(handleSave))
        item.leftBarButtonItem?.tintColor = UIColor.navRed
        item.rightBarButtonItem?.tintColor = UIColor.navRed
        navigationBar.pushItem(item, animated: false)        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Need to use titleView (instead of title) to prevent buggy behavior where the title shifts position
    func updateSelectedRooms(for rooms: [LaundryRoom]) {
        let label = navigationBar.topItem?.titleView as! UILabel
        label.text = "\(rooms.count)/\(selectionView.maxNumRooms) Chosen"
        navigationBar.topItem?.titleView = label
    }
    
    func handleCancel() {
        _ = selectionView.resignFirstResponder()
        delegate?.handleCancel()
    }
    
    func handleSave() {
        _ = selectionView.resignFirstResponder()
        delegate?.saveSelection(for: selectionView.chosenRooms)
    }
    
    func handleFailureToLoadDictionary() {
    }
}

class NavigationBar: UINavigationBar {
    
    //set NavigationBar's height
    var customHeight : CGFloat = 64
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: customHeight)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.tintColor = .black
        
        frame = CGRect(x: frame.origin.x, y:  0, width: frame.size.width, height: customHeight)
        
        // title position (statusbar height / 2)
        setTitleVerticalPositionAdjustment(-10, for: UIBarMetrics.default)
        
        for subview in self.subviews {
            var stringFromClass = NSStringFromClass(subview.classForCoder)
            if stringFromClass.contains("BarBackground") {
                subview.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: customHeight)
            }
            
            stringFromClass = NSStringFromClass(subview.classForCoder)
            if stringFromClass.contains("BarContent") {
                subview.frame = CGRect(x: subview.frame.origin.x, y: 20, width: subview.frame.width, height: customHeight - 20)
            }
        }
    }
}
