//
//  LaundryHomeViewController.swift
//  PennMobile
//
//  Created by Dominic Holmes on 10/21/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import UIKit

class LaundryPageView: UIView {

    var pageIndex = 0

    /*
    var room: LaundryRoom! {
        didSet {
        }
    }
    
    private let bgView: UIView = {
        let bg = UIView()
        bg.backgroundColor = .yellow
        return bg
    }()
    
    private let washerView: UIView = {
        let v = UIView()
        v.backgroundColor = .blue
        return v
    }()
    
    private let dryerView: UIView = {
        let v = UIView()
        v.backgroundColor = .green
        return v
    }()
    
    private let washersLabel: UILabel = {
        let label = UILabel()
        label.text = "Washers"
        label.font = UIFont(name: "HelveticaNeue-SemiBold", size: 16)
        label.textColor = .white
        label.layer.cornerRadius = 4
        label.layer.masksToBounds = true
        label.textAlignment = .left
        return label
    }()
    
    private let dryersLabel: UILabel = {
        let label = UILabel()
        label.text = "Dryers"
        label.font = UIFont(name: "HelveticaNeue-SemiBold", size: 16)
        label.textColor = .white
        label.layer.cornerRadius = 4
        label.layer.masksToBounds = true
        label.textAlignment = .left
        return label
    }()
    
    private let numWashersLabel: UILabel = {
        let label = UILabel()
        label.text = "3 open"
        label.font = UIFont(name: "HelveticaNeue-Light", size: 36)
        label.textColor = .white
        label.layer.cornerRadius = 4
        label.layer.masksToBounds = true
        label.textAlignment = .center
        return label
    }()
    
    private let numDryersLabel: UILabel = {
        let label = UILabel()
        label.text = "8 min"
        label.font = UIFont(name: "HelveticaNeue-Light", size: 36)
        label.textColor = .white
        label.layer.cornerRadius = 4
        label.layer.masksToBounds = true
        label.textAlignment = .center
        return label
    }()
    
    private let washersSecondaryLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont(name: "HelveticaNeue-Light", size: 14)
        label.textColor = .white
        label.layer.cornerRadius = 4
        label.layer.masksToBounds = true
        label.textAlignment = .center
        return label
    }()
    
    private let dryersSecondaryLabel: UILabel = {
        let label = UILabel()
        label.text = "until next open"
        label.font = UIFont(name: "HelveticaNeue-Light", size: 14)
        label.textColor = .white
        label.layer.cornerRadius = 4
        label.layer.masksToBounds = true
        label.textAlignment = .center
        return label
    }()
    
    private func setupViews() {
        
        self.addSubview(bgView)
        
        // BackgroundView
        
        bgView.translatesAutoresizingMaskIntoConstraints = false
        bgView.leftAnchor.constraint(
            equalTo: leftAnchor).isActive = true
        bgView.topAnchor.constraint(
            equalTo: topAnchor).isActive = true
        bgView.rightAnchor.constraint(
            equalTo: rightAnchor).isActive = true
        bgView.bottomAnchor.constraint(
            equalTo: bottomAnchor).isActive = true
        
        bgView.addSubview(washersLabel)
        bgView.addSubview(dryersLabel)
        
        
        // Washer View
        bgView.addSubview(washerView)
        _ = washerView.anchor(bgView.topAnchor, left: bgView.leftAnchor, bottom: bgView.bottomAnchor, right: nil,
                              topConstant: 10, leftConstant: 0, bottomConstant: 0, rightConstant: 0,
                              widthConstant: 0, heightConstant: 0)
        washerView.widthAnchor.constraint(
            equalTo: bgView.widthAnchor,
            multiplier: 0.5).isActive = true
        
        // Dryer View
        bgView.addSubview(dryerView)
        _ = dryerView.anchor(bgView.topAnchor, left: nil, bottom: bgView.bottomAnchor, right: bgView.rightAnchor,
                             topConstant: 10, leftConstant: 0, bottomConstant: 0, rightConstant: 0,
                             widthConstant: 0, heightConstant: 0)
        dryerView.widthAnchor.constraint(
            equalTo: bgView.widthAnchor,
            multiplier: 0.5).isActive = true
        
        // "Washers" Label
        washersLabel.translatesAutoresizingMaskIntoConstraints = false
        washersLabel.leadingAnchor.constraint(
            equalTo: washerView.leadingAnchor,
            constant: 25).isActive = true
        washersLabel.topAnchor.constraint(
            equalTo: washerView.topAnchor,
            constant: 10).isActive = true
        
        // "Dryers" Label
        dryersLabel.translatesAutoresizingMaskIntoConstraints = false
        dryersLabel.leadingAnchor.constraint(
            equalTo: dryerView.leadingAnchor,
            constant: 25).isActive = true
        dryersLabel.topAnchor.constraint(
            equalTo: dryerView.topAnchor,
            constant: 10).isActive = true
        
        // Num washers, num dryers
        
        bgView.addSubview(numWashersLabel)
        bgView.addSubview(numDryersLabel)
        
        _ = numWashersLabel.anchor(washersLabel.topAnchor, left: washersLabel.leftAnchor, bottom: nil,
                                   right: nil, topConstant: 22, leftConstant: 0, bottomConstant: 0,
                                   rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        _ = numDryersLabel.anchor(dryersLabel.topAnchor, left: dryersLabel.leftAnchor, bottom: nil,
                                  right: nil, topConstant: 22, leftConstant: 0, bottomConstant: 0,
                                  rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        // Secondary washers/dryers labels
        
        bgView.addSubview(washersSecondaryLabel)
        bgView.addSubview(dryersSecondaryLabel)
        
        _ = washersSecondaryLabel.anchor(numWashersLabel.bottomAnchor, left: numWashersLabel.leftAnchor, bottom: nil,
                                         right: nil, topConstant: -2, leftConstant: 0, bottomConstant: 0,
                                         rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        _ = dryersSecondaryLabel.anchor(numDryersLabel.bottomAnchor, left: numDryersLabel.leftAnchor, bottom: nil,
                                        right: nil, topConstant: -2, leftConstant: 0, bottomConstant: 0,
                                        rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
     */
}
