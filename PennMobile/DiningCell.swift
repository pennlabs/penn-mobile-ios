//
//  DiningCell.swift
//  PennMobile
//
//  Created by Josh Doman on 2/18/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import UIKit

protocol DiningHallDelegate {
    func goToDiningHallMenu(for hall: String)
    func getDiningHallArray() -> [String]
}

class DiningCell: UITableViewCell {
    
    private var height: CGFloat!
    private var width: CGFloat!
    
    private static let HallHeight: CGFloat = 30
    private static let InnerWidth: CGFloat = 15
    private static let Padding: CGFloat = 25
    private static let HeaderHeight: CGFloat = 50
    
    private let header: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue-Light", size: 20)
        label.text = "Eat at one of these locations"
        label.textColor = UIColor(r: 115, g: 115, b: 115)
        label.backgroundColor = .white
        return label
    }()
    
    private let body: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 248, g: 248, b: 248)
        return view
    }()
    
    var delegate: DiningHallDelegate? {
        didSet {
            for hall in halls {
                hall.delegate = delegate
            }
            addHallsToView()
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        width = frame.width
        height = 0.603 * UIScreen.main.bounds.width //frame.height
        
        selectionStyle = UITableViewCellSelectionStyle.none
        
        addSubview(header)
        addSubview(body)
        
        _ = header.anchor(topAnchor, left: leftAnchor, bottom: topAnchor, right: rightAnchor, topConstant: 0, leftConstant: 16, bottomConstant: -DiningCell.HeaderHeight, rightConstant: 0, widthConstant: 0, heightConstant: DiningCell.HeaderHeight)
        
        _ = body.anchorToTop(header.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor)
    }
    
    private var selectedHalls: [String]? {
        get {
            return delegate?.getDiningHallArray()
        }
    }
    
    private var halls: [DiningHallView] = [DiningHallView]()
    private var hallDictionary: [String: DiningHallView] = [String: DiningHallView]()
    
    private func createHall(hall: String) -> DiningHallView {
        let view = DiningHallView()
        view.diningHall = hall
        view.delegate = delegate
        view.setTimeRemaining(time: 120)
        
        halls.append(view)
        
        return view
    }
    
    private func addHallsToView() {
        //check if halls are the same
        if selectedHallsAreTheSame() {
            return
        }
        
        removeHallsFromView()
        
        guard let selectedHalls = selectedHalls else { return }
        
        for hall in selectedHalls {
            let hallView = createHall(hall: hall)
            hallDictionary[hall] = hallView
        }
        
        var anchor: NSLayoutYAxisAnchor = body.topAnchor
        var topConstant = DiningCell.Padding
        
        for hall in halls {
            body.addSubview(hall)
            
            _ = hall.anchor(anchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: topConstant, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: DiningCell.HallHeight)
            
            anchor = hall.bottomAnchor
            topConstant = DiningCell.InnerWidth
        }
        
        layoutIfNeeded()
        
        updateTimesForAll()
    }
    
    private func selectedHallsAreTheSame() -> Bool {
        if let selectedHalls = selectedHalls {
            if selectedHalls.count != halls.count { return false }

            for hall in halls {
                if let diningHall = hall.diningHall {
                    if !selectedHalls.contains(diningHall) { return false }
                }
            }
        }
        
        return true
    }
    
    private func removeHallsFromView() {
        hallDictionary.removeAll()
        for hall in halls {
            hall.removeFromSuperview()
        }
        halls.removeAll()
    }
    
    public func updateTimesForAll() {
        for hall in halls {
            if let diningHall = hall.diningHall {
                let time = getTimeRemainingForHall(diningHall)
                hall.setTimeRemaining(time: time)
            }
        }
    }
    
    //TODO sync up the API
    private func getTimeRemainingForHall(_ hall: String) -> Int {
        if hall == "1920 Commons" {
            return 30
        } else if hall == "English House" {
            return 55
        } else if hall == "Tortas Frontera"{
            return 120
        } else if hall == "New College House" {
            return 0
        } else {
            return 120
        }
    }
    
    public static func calculateCellHeight(numberOfCells: Int) -> CGFloat {
        if numberOfCells <= 0 { return 0 }
        
        let numberOfCells = CGFloat(numberOfCells)
        
        let t1 = 2 * Padding
        let t2 = HallHeight * numberOfCells
        let t3 = InnerWidth * (numberOfCells - 1)
        
        return t1 + t2 + t3 + HeaderHeight
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
        button.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 14)
        button.tintColor = .white
        button.backgroundColor = UIColor(r: 63, g: 81, b: 181)
        button.layer.cornerRadius = 2
        button.layer.masksToBounds = true
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
        if time > 0 && time < 60 {
            timeLabel.isHidden = false
            timer.isHidden = false

            timeLabel.text = "\(time)'"
        } else {
            timeLabel.isHidden = true
            timer.isHidden = true
        }
        
        setIsOpen(isOpen: time > 0)
    }
    
    private func setIsOpen(isOpen: Bool) {
        if isOpen {
            label.textColor = UIColor(r: 115, g: 115, b: 115)
            button.backgroundColor = UIColor(r: 63, g: 81, b: 181)
            button.setTitle("Menu", for: .normal)
            
            button.addTarget(self, action: #selector(menuPresseed), for: .touchUpInside)
        } else {
            label.textColor = UIColor(r: 212, g: 212, b: 212)
            button.backgroundColor = UIColor(r: 242, g: 110, b: 103)
            button.setTitle("Closed", for: .normal)
            
            timeLabel.isHidden = true
            timer.isHidden = true
            
            button.removeTarget(self, action: #selector(menuPresseed), for: .touchUpInside)
        }
    }
    
}
