//
//  LaundryAnnouncementHeader.swift
//  PennMobile
//
//  Created by Josh Doman on 8/27/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import UIKit

@objc class LaundryAnnouncementHeader: UITableViewHeaderFooterView, URLOpenable {
    
    private let label: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue-Light", size: 17)
        label.textColor = UIColor.whiteGrey
        label.textAlignment = .center
        label.text = "Oh no! It seems like the new laundry machines have broken this feature. Hang tight for a few weeks while we fix things, and please, don’t let this stop you from doing your laundry. Click here to subscribe to new updates."
        label.numberOfLines = 10
        return label
    }()
    
    private lazy var subscribeButton: UIButton = {
        let b = UIButton()
        b.setTitle("Subscribe", for: .normal)
        b.setTitleColor(UIColor.whiteGrey, for: .normal)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.addTarget(self, action: #selector(handleSubscribe(_:)), for: .touchUpInside)
        return b
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = UIColor.frenchBlue
        
        addSubview(subscribeButton)
        addSubview(label)
        
        subscribeButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        _ = subscribeButton.anchor(bottom: bottomAnchor, bottomConstant: 12)
        
        _ = label.anchor(topAnchor, left: leftAnchor, bottom: subscribeButton.topAnchor, right: rightAnchor, topConstant: 16, leftConstant: 16, bottomConstant: 6, rightConstant: 16)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func handleSubscribe(_ sender: UIButton) {
        open(scheme: "http://eepurl.com/c07CGb")
        GoogleAnalyticsManager.shared.trackEvent(category: "Laundry", action: "Subscribe", label: "Pressed subscribe button", value: 1)
    }
}
