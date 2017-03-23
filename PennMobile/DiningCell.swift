//
//  DiningCell2.swift
//  PennMobile
//
//  Created by Josh Doman on 3/8/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import UIKit

struct DiningHall {
    let name: String
    var timeRemaining: Int
}

class DiningCell: GenericHomeCell {
    
    internal static let HallHeight: CGFloat = 32
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
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = DiningCell.InnerWidth //decreases gap between cells
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor(r: 248, g: 248, b: 248)
        cv.dataSource = self
        cv.delegate = self
        cv.allowsSelection = false
        cv.isScrollEnabled = false
        cv.contentInset = UIEdgeInsets(top: DiningCell.Padding, left: 0, bottom: DiningCell.Padding, right: 0)
        cv.register(DiningHallCell.self, forCellWithReuseIdentifier: self.diningCell)
        return cv
    }()
    
    internal var diningHalls: [DiningHall]! {
        get {
            return delegate.getDiningHalls().sorted(by: { (hall1, hall2) -> Bool in
                let time1 = hall1.timeRemaining
                if time1 == 0 {
                    return false
                }
                
                let time2 = hall2.timeRemaining
                
                if time2 == 0 {
                    return true
                }
                
                return time1 < time2
            })
        }
    }
    
    var delegate: DiningCellDelegate!
    
    internal let diningCell = "diningCell"
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
                
        addSubview(header)
        addSubview(collectionView)
        
        _ = header.anchor(topAnchor, left: leftAnchor, bottom: topAnchor, right: rightAnchor, topConstant: 0, leftConstant: 16, bottomConstant: -DiningCell.HeaderHeight, rightConstant: 0, widthConstant: 0, heightConstant: DiningCell.HeaderHeight)
        
        _ = collectionView.anchorToTop(header.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor)
    }
    
    public static func calculateCellHeight(numberOfCells: Int) -> CGFloat {
        if numberOfCells <= 0 { return 0 }
        
        let numberOfCells = CGFloat(numberOfCells)
        
        let t1 = 2 * Padding
        let t2 = HallHeight * numberOfCells
        let t3 = InnerWidth * (numberOfCells - 1)
        
        return t1 + t2 + t3 + HeaderHeight
    }
    
    internal func handleMenuPressed(for diningHall: String) {
        print(diningHall)
    }
    
    public override func reloadData() {
        collectionView.reloadData()
    }
}

extension DiningCell: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return diningHalls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let diningHall = diningHalls[indexPath.item]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: diningCell, for: indexPath) as! DiningHallCell
        cell.diningHall = diningHall
        cell.delegate = delegate
        cell.setTimeRemaining(time: diningHall.timeRemaining)
        return cell
    }
}

extension DiningCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: frame.width, height: DiningCell.HallHeight)
    }
}

protocol DiningCellDelegate {
    func handleMenuPressed(for diningHall: DiningHall)
    func getDiningHalls() -> [DiningHall]
}

private class DiningHallCell: UICollectionViewCell {
    
    var diningHall: DiningHall! {
        didSet {
            label.text = diningHall.name
        }
    }
    
    var delegate: DiningCellDelegate!
    
    private let label: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "OpenSans", size: 7.5)
        label.textColor = UIColor(r: 115, g: 115, b: 115)
        return label
    }()
    
    private lazy var button: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Menu", for: .normal)
        button.titleLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 14)
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
        addSubview(button)
        addSubview(label)
        addSubview(timer)
        addSubview(timeLabel)
        
        _ = button.anchor(topAnchor, left: nil, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 60, widthConstant: 70, heightConstant: 0)
        
        _ = label.anchor(nil, left: leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 30, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        label.centerYAnchor.constraint(equalTo: button.centerYAnchor).isActive = true
        
        _ = timer.anchor(nil, left: button.rightAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 6, bottomConstant: 0, rightConstant: 0, widthConstant: 17, heightConstant: 14)
        timer.centerYAnchor.constraint(equalTo: button.centerYAnchor).isActive = true
        
        _ = timeLabel.anchor(nil, left: timer.rightAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 2, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        timeLabel.centerYAnchor.constraint(equalTo: button.centerYAnchor).isActive = true
        
    }
    
    func menuPresseed() {
        delegate.handleMenuPressed(for: diningHall)
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
            button.reversesTitleShadowWhenHighlighted = true
            
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
