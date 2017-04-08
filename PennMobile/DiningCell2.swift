//
//  DiningCell.swift
//  PennMobile
//
//  Created by Josh Doman on 3/7/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

//import UIKit
//
//class DiningCell2: UITableViewCell {
//    
//    internal static let HallHeight: CGFloat = 32
//    internal static let InnerWidth: CGFloat = 15
//    internal static let Padding: CGFloat = 25
//    internal static let HeaderHeight: CGFloat = 50
//    
//    private let header: UILabel = {
//        let label = UILabel()
//        label.font = UIFont(name: "HelveticaNeue-Light", size: 20)
//        label.text = "Eat at one of these locations"
//        label.textColor = UIColor(r: 115, g: 115, b: 115)
//        label.backgroundColor = .white
//        return label
//    }()
//    
//    private lazy var collectionView: UICollectionView = {
//        let layout = UICollectionViewFlowLayout()
//        layout.minimumLineSpacing = DiningCell2.InnerWidth //decreases gap between cells
//        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        cv.backgroundColor = UIColor(r: 248, g: 248, b: 248)
//        cv.dataSource = self
//        cv.delegate = self
//        cv.allowsSelection = false
//        cv.isScrollEnabled = false
//        cv.contentInset = UIEdgeInsets(top: DiningCell2.Padding, left: 0, bottom: DiningCell2.Padding, right: 0)
//        cv.register(DiningHallCell.self, forCellWithReuseIdentifier: self.diningCell)
//        return cv
//    }()
//    
//    internal var diningHalls: [String]! {
//        get {
//            return delegate.getDiningHalls().sorted(by: { (hall1, hall2) -> Bool in
//                let time1 = getTimeRemainingForHall(hall1)
//                if time1 == 0 {
//                    return false
//                }
//                
//                let time2 = getTimeRemainingForHall(hall2)
//                
//                if time2 == 0 {
//                    return true
//                }
//                
//                return time1 < time2
//            })
//        }
//    }
//    
//    var delegate: DiningCellDelegate!
//    
//    internal let diningCell = "diningCell"
//    
//    required init(coder aDecoder: NSCoder) {
//        fatalError("init(coder:)")
//    }
//    
//    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        
//        selectionStyle = UITableViewCellSelectionStyle.none
//        
//        addSubview(header)
//        addSubview(collectionView)
//        
//        _ = header.anchor(topAnchor, left: leftAnchor, bottom: topAnchor, right: rightAnchor, topConstant: 0, leftConstant: 16, bottomConstant: -DiningCell2.HeaderHeight, rightConstant: 0, widthConstant: 0, heightConstant: DiningCell2.HeaderHeight)
//        
//        _ = collectionView.anchorToTop(header.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor)
//    }
//    
//    public static func calculateCellHeight(numberOfCells: Int) -> CGFloat {
//        if numberOfCells <= 0 { return 0 }
//        
//        let numberOfCells = CGFloat(numberOfCells)
//        
//        let t1 = 2 * Padding
//        let t2 = HallHeight * numberOfCells
//        let t3 = InnerWidth * (numberOfCells - 1)
//        
//        return t1 + t2 + t3 + HeaderHeight
//    }
//    
//    internal func handleMenuPressed(for diningHall: String) {
//        print(diningHall)
//    }
//    
//    //TODO sync up the API
//    internal func getTimeRemainingForHall(_ hall: String) -> Int {
//        if hall == "1920 Commons" {
//            return 30
//        } else if hall == "English House" {
//            return 55
//        } else if hall == "Tortas Frontera"{
//            return 0
//        } else if hall == "New College House" {
//            return 0
//        } else {
//            return 120
//        }
//    }
//    
//    //updates the times for all cells
//    public func updateTimesForAll() {
//        for index in 0...(collectionView.numberOfItems(inSection: 0) - 1) {
//            let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as! DiningHallCell
//            cell.setTimeRemaining(time: getTimeRemainingForHall(cell.diningHall))
//        }
//    }
//    
//    public func reloadData() {
//        collectionView.reloadData()
//    }
//}
//
//extension DiningCell2: UICollectionViewDataSource {
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return 1
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return diningHalls.count
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let diningHall = diningHalls[indexPath.item]
//        
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: diningCell, for: indexPath) as! DiningHallCell
//        cell.diningHall = diningHall
//        cell.delegate = delegate
//        cell.setTimeRemaining(time: getTimeRemainingForHall(diningHall))
//        return cell
//    }
//}
//
//extension DiningCell2: UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: frame.width, height: DiningCell.HallHeight)
//    }
//}
//
////protocol DiningCellDelegate {
////    func handleMenuPressed(for diningHall: String)
////    func getDiningHalls() -> [String]
////}
//
//private class DiningHallCell: UICollectionViewCell {
//    
//    var diningHall: String! {
//        didSet {
//            label.text = diningHall
//        }
//    }
//    
//    var delegate: DiningCellDelegate!
//    
//    private let label: UILabel = {
//        let label = UILabel()
//        label.font = UIFont(name: "OpenSans", size: 7.5)
//        label.textColor = UIColor(r: 115, g: 115, b: 115)
//        return label
//    }()
//    
//    private lazy var button: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("Menu", for: .normal)
//        button.titleLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 14)
//        button.tintColor = .white
//        button.backgroundColor = UIColor(r: 63, g: 81, b: 181)
//        button.layer.cornerRadius = 2
//        button.layer.masksToBounds = true
//        return button
//    }()
//    
//    private let timer: UIImageView = {
//        let imageView = UIImageView()
//        imageView.isUserInteractionEnabled = true
//        imageView.image = UIImage(named: "time")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
//        imageView.tintColor = UIColor(r: 192, g: 57, b: 43)
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        return imageView
//    }()
//    
//    private let timeLabel: UILabel = {
//        let label = UILabel()
//        label.font = UIFont(name: "HelveticaNeue", size: 12)
//        label.text = "55'"
//        label.textColor = UIColor(r: 192, g: 57, b: 43)
//        return label
//    }()
//    
//    required init(coder aDecoder: NSCoder) {
//        fatalError("init(coder:)")
//    }
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupView()
//    }
//    
//    private func setupView() {
//        addSubview(button)
//        addSubview(label)
//        addSubview(timer)
//        addSubview(timeLabel)
//        
//        _ = button.anchor(topAnchor, left: nil, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 60, widthConstant: 70, heightConstant: 0)
//        
//        _ = label.anchor(nil, left: leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 30, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
//        label.centerYAnchor.constraint(equalTo: button.centerYAnchor).isActive = true
//        
//        _ = timer.anchor(nil, left: button.rightAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 6, bottomConstant: 0, rightConstant: 0, widthConstant: 17, heightConstant: 14)
//        timer.centerYAnchor.constraint(equalTo: button.centerYAnchor).isActive = true
//        
//        _ = timeLabel.anchor(nil, left: timer.rightAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 2, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
//        timeLabel.centerYAnchor.constraint(equalTo: button.centerYAnchor).isActive = true
//        
//    }
//    
//    func menuPresseed() {
//        delegate.handleMenuPressed(for: diningHall)
//    }
//    
//    func setTimeRemaining(time: Int) {
//        if time > 0 && time < 60 {
//            timeLabel.isHidden = false
//            timer.isHidden = false
//            
//            timeLabel.text = "\(time)'"
//        } else {
//            timeLabel.isHidden = true
//            timer.isHidden = true
//        }
//        
//        setIsOpen(isOpen: time > 0)
//    }
//    
//    private func setIsOpen(isOpen: Bool) {
//        if isOpen {
//            label.textColor = UIColor(r: 115, g: 115, b: 115)
//            button.backgroundColor = UIColor(r: 63, g: 81, b: 181)
//            button.setTitle("Menu", for: .normal)
//
//            button.addTarget(self, action: #selector(menuPresseed), for: .touchUpInside)
//        } else {
//            label.textColor = UIColor(r: 212, g: 212, b: 212)
//            button.backgroundColor = UIColor(r: 242, g: 110, b: 103)
//            button.setTitle("Closed", for: .normal)
//            
//            timeLabel.isHidden = true
//            timer.isHidden = true
//            
//            button.removeTarget(self, action: #selector(menuPresseed), for: .touchUpInside)
//        }
//    }
//
//    
//}
