//
//  JWTabBarItem.swift
//  JW_TabBarController
//
//  Created by Jacob Wagstaff on 8/18/17.
//  Copyright © 2017 Jacob Wagstaff. All rights reserved.
//
import UIKit

public enum TabBarItemType{
    case icon
    case label
}

class TabBarItem: UIButton {
    var type : TabBarItemType = .icon
    var containerButton = UIButton()
    var iconView = UIImageView()
    var label = UILabel()
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    func setupTabBarItem(type: TabBarItemType){
        self.type = type
        configureSubviews()
        configureLayout()
    }
    
    fileprivate func configureSubviews(){
        iconView.contentMode = .center
        iconView.clipsToBounds = true
        
        label.textAlignment = .center
        
        backgroundColor = .clear
    }
    
    fileprivate func configureLayout(){
        switch type{
        case .icon:
            addAutoLayoutSubview(containerButton)
            containerButton.addAutoLayoutSubview(iconView)
            
            iconView.fillSuperview()
            containerButton.fillSuperview()
        case .label:
            addAutoLayoutSubview(containerButton)
            containerButton.addAutoLayoutSubview(iconView)
            containerButton.addAutoLayoutSubview(label)
            
            NSLayoutConstraint.activate([
                iconView.topAnchor.constraint(equalTo: topAnchor, constant: 2),
                iconView.leftAnchor.constraint(equalTo: leftAnchor),
                iconView.rightAnchor.constraint(equalTo: rightAnchor),
                iconView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.65),
                
                label.bottomAnchor.constraint(equalTo: bottomAnchor),
                label.leftAnchor.constraint(equalTo: leftAnchor),
                label.rightAnchor.constraint(equalTo: rightAnchor),
                label.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.35),
                
                ])
            containerButton.fillSuperview()
        }
        
    }
}
