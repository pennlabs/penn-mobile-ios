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
    
    lazy var hall1: DiningHallView = {
        let view = DiningHallView()
        view.diningHall = "1920 Commons"
        view.setTimeRemaining(time: 30)
        return view
    }()
    
    lazy var hall2: DiningHallView = {
        let view = DiningHallView()
        view.diningHall = "English House"
        view.setTimeRemaining(time: 55)
        return view
    }()
    
    lazy var hall3: DiningHallView = {
        let view = DiningHallView()
        view.diningHall = "Tortas Frontera"
        view.setTimeRemaining(time: 120)
        return view
    }()
    
    lazy var hall4: DiningHallView = {
        let view = DiningHallView()
        view.diningHall = "New College House"
        view.setTimeRemaining(time: 120)
        return view
    }()
    
    var delegate: DiningHallDelegate? {
        didSet {
            hall1.delegate = delegate
            hall2.delegate = delegate
            hall3.delegate = delegate
            hall4.delegate = delegate
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        width = frame.width
        height = 0.603 * UIScreen.main.bounds.width //frame.height
        
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
    
    func addHall(hall: String) {
        let view = DiningHallView()
        view.diningHall = hall
        view.delegate = delegate
        view.setTimeRemaining(time: 120)
    }

    func handleHall1Pressed() {
        print("hall1")
    }
    
    func handleHall2Pressed() {
        print("hall2")
    }
    
    func handleHall3Pressed() {
        print("hall3")
    }
    
    func handleHall4Pressed() {
        print("hall4")
    }
    
}

class DiningHallView: UIView {
    
    var width: CGFloat? {
        didSet {
            setupView()
        }
    }
    
    var diningHall: String? {
        didSet {
            label.text = diningHall
        }
    }
    
    private let label: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "OpenSans", size: 7.5)
        label.textColor = UIColor(r: 115, g: 115, b: 115)
        return label
    }()
    
    private lazy var button: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Menu", for: .normal)
        button.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 16) //UIFont.systemFont(ofSize: 20)
        button.tintColor = .white
        button.backgroundColor = UIColor(r: 63, g: 81, b: 181)
        button.layer.cornerRadius = 2
        button.layer.masksToBounds = true
        button.addTarget(target, action: #selector(menuPresseed), for: .touchUpInside)
        return button
    }()
    
    private let timer: UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        imageView.image = UIImage(named: "time")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        imageView.tintColor = UIColor(r: 192, g: 57, b: 43)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue", size: 12)
        label.text = "55'"
        label.textColor = UIColor(r: 192, g: 57, b: 43)
        return label
    }()
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    private func setupView() {
        let width = UIScreen.main.bounds.width
        
        addSubview(button)
        addSubview(label)
        addSubview(timer)
        addSubview(timeLabel)
        
        _ = button.anchor(topAnchor, left: nil, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0.168 * width, widthConstant: 0.195 * width, heightConstant: 0)
        
        _ = label.anchor(nil, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: 0.064 * width, bottomConstant: 0, rightConstant: 0.491*width, widthConstant: 0, heightConstant: 0)
        label.centerYAnchor.constraint(equalTo: button.centerYAnchor).isActive = true
        
        _ = timer.anchor(nil, left: button.rightAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 6, bottomConstant: 0, rightConstant: 0, widthConstant: 16, heightConstant: 16)
        timer.centerYAnchor.constraint(equalTo: button.centerYAnchor).isActive = true
        
        _ = timeLabel.anchor(nil, left: timer.rightAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 4, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        timeLabel.centerYAnchor.constraint(equalTo: button.centerYAnchor).isActive = true
        
    }
    
    var delegate: DiningHallDelegate?
    
    func menuPresseed() {
        if let hall = diningHall {
            delegate?.goToDiningHallMenu(for: hall)
        }
    }
    
    func setTimeRemaining(time: Int) {
        if time < 60 {
            timeLabel.isHidden = false
            timer.isHidden = false

            timeLabel.text = "\(time)'"
        } else {
            timeLabel.isHidden = true
            timer.isHidden = true
        }
    }
    
}
