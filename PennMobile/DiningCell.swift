//
//  DiningCell.swift
//  PennMobile
//
//  Created by Josh Doman on 2/18/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import UIKit

class DiningCell: UITableViewCell {
    
    var height: CGFloat!
    var width: CGFloat!
    
    lazy var hall1: UIView = {
        let view = self.createRow(hall: "1920 Commons")
        return view
    }()
    
    lazy var hall2: UIView = {
        let view = self.createRow(hall: "English House")
        return view
    }()
    
    lazy var hall3: UIView = {
        let view = self.createRow(hall: "Tortas Frontera")
        return view
    }()
    
    lazy var hall4: UIView = {
        let view = self.createRow(hall: "New College House")
        return view
    }()
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        width = frame.width
        height = 0.603 * UIScreen.main.bounds.width //frame.height
        print(height)
        print(width)
        
        setupCell()
    }
    
    func setupCell() {
        backgroundColor = UIColor(r: 248, g: 248, b: 248)
        
        addSubview(hall1)
        addSubview(hall2)
        addSubview(hall3)
        addSubview(hall4)
        
        _ = hall1.anchor(topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 0.13 * height, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0.131 * height)
        
        _ = hall2.anchor(hall1.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 0.067 * height, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0.131 * height)
        
        _ = hall3.anchor(hall2.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 0.067 * height, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0.131 * height)
        
        _ = hall4.anchor(hall3.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 0.067 * height, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0.131 * height)
    }
    
    func createRow(hall: String) -> UIView {
        let bar = UIView()
        
        let label = UILabel()
        label.text = hall
        label.font = UIFont(name: "OpenSans", size: 7.5)
        label.textColor = UIColor(r: 115, g: 115, b: 115)
        
        let button = UIButton(type: .system)
        button.setTitle("Menu", for: .normal)
        button.titleLabel?.font = UIFont(name: "OpenSans-Light", size: 5) //UIFont.systemFont(ofSize: 20)
        button.tintColor = .white
        button.backgroundColor = UIColor(r: 63, g: 81, b: 181)
        button.layer.cornerRadius = 2
        button.layer.masksToBounds = true
        
        bar.addSubview(button)
        bar.addSubview(label)
        
        
        
        _ = button.anchor(bar.topAnchor, left: nil, bottom: bar.bottomAnchor, right: bar.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0.168 * width, widthConstant: 0.195 * width, heightConstant: 0)
        
        _ = label.anchor(nil, left: bar.leftAnchor, bottom: nil, right: bar.rightAnchor, topConstant: 0, leftConstant: 0.064 * width, bottomConstant: 0, rightConstant: 0.491*width, widthConstant: 0, heightConstant: 0)
        label.centerYAnchor.constraint(equalTo: button.centerYAnchor).isActive = true
        
        return bar
    }
    
}
