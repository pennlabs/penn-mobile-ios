//
//  LaundryCell.swift
//  PennMobile
//
//  Created by Dominic Holmes on 9/30/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import UIKit

protocol LaundryCellDelegate: class {
    func deleteLaundryCell(for hall: LaundryHall)
    func handleMachineCellTapped(for hall: LaundryHall, isWasher: Bool, timeRemaining: Int, _ updateCellIfNeeded: @escaping () -> Void)
}

class LaundryCell: UITableViewCell {
    
    weak var delegate: LaundryCellDelegate?
    
    var room: LaundryHall! {
        didSet {
            roomLabel.text = room.building
            roomFloorLabel.text = room.name
            washerCollectionView?.reloadData()
            dryerCollectionView?.reloadData()
        }
    }
    
    fileprivate var washerCollectionView: UICollectionView?
    fileprivate var dryerCollectionView: UICollectionView?
    
    fileprivate let cellId = "cellId"
    
    fileprivate let bgView: UIView = {
        let bg = UIView()
        /*
        let gradient: CAGradientLayer = CAGradientLayer()
        
        gradient.colors = [UIColor.init(red: 250.0 / 255.0, green: 250.0 / 255.0, blue: 250.0 / 255.0, alpha: 1.0).cgColor,
                           UIColor.init(red: 245.0 / 255.0, green: 245.0 / 255.0, blue: 245.0 / 255.0, alpha: 1.0).cgColor]
        gradient.locations = [0.0 , 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: 500.0, height: 350.0)
        
        bg.layer.insertSublayer(gradient, at: 0)
        
        bg.clipsToBounds = true
        bg.layer.cornerRadius = 15
        bg.layer.masksToBounds = true*/
        
        // corner radius
        bg.layer.cornerRadius = 20
        
        // border
        bg.layer.borderWidth = 0.0
        bg.layer.borderColor = UIColor.black.cgColor
        
        // shadow
        bg.layer.shadowColor = UIColor.black.cgColor
        bg.layer.shadowOffset = CGSize(width: 0, height: 0)
        bg.layer.shadowOpacity = 0.5
        bg.layer.shadowRadius = 2.0
        bg.backgroundColor = UIColor.whiteGrey
        
        return bg
    }()
    
    fileprivate lazy var xButton: UIButton = {
        let xb = UIButton()
        xb.backgroundColor = UIColor.clear
        xb.contentMode = .scaleAspectFill
        xb.clipsToBounds = true
        xb.layer.cornerRadius = 20
        xb.layer.masksToBounds = true
        xb.setBackgroundImage(UIImage(named: "x_button"), for: UIControlState.normal)
        xb.setBackgroundImage(UIImage(named: "x_button_selected"), for: .selected)
        xb.setBackgroundImage(UIImage(named: "x_button_selected"), for: .highlighted)
        xb.addTarget(self, action: #selector(deleteRoom), for: .touchUpInside)
        return xb
    }()
    
    fileprivate let washersDryersView: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()
    
    fileprivate let washerView: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()
    
    fileprivate let washerCollectionViewContainer: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()
    
    fileprivate let dryerView: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()
    
    fileprivate let dryerCollectionViewContainer: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()
    
    fileprivate let roomLabel: UILabel = {
        let label = UILabel()
        label.text = "Laundry Room"
        label.font = UIFont(name: "HelveticaNeue", size: 14)
        label.textColor = .warmGrey
        label.textAlignment = .left
        return label
    }()
    
    fileprivate let roomFloorLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont(name: "HelveticaNeue", size: 24)
        label.textColor = .black
        label.textAlignment = .left
        return label
    }()
    
    fileprivate let washersLabel: UILabel = {
        let label = UILabel()
        label.text = "Washers"
        label.font = UIFont(name: "HelveticaNeue", size: 14)
        label.textColor = .black
        label.layer.cornerRadius = 4
        label.layer.masksToBounds = true
        label.textAlignment = .left
        return label
    }()
    
    fileprivate let dryersLabel: UILabel = {
        let label = UILabel()
        label.text = "Dryers"
        label.font = UIFont(name: "HelveticaNeue", size: 14)
        label.textColor = .black
        label.layer.cornerRadius = 4
        label.layer.masksToBounds = true
        label.textAlignment = .left
        return label
    }()
    
    fileprivate let numWashersLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont(name: "HelveticaNeue", size: 16)
        label.textColor = .warmGrey
        label.layer.cornerRadius = 4
        label.layer.masksToBounds = true
        label.textAlignment = .right
        return label
    }()
    
    fileprivate let numDryersLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont(name: "HelveticaNeue", size: 16)

        label.textColor = .warmGrey
        label.layer.cornerRadius = 4
        label.layer.masksToBounds = true
        label.textAlignment = .right
        return label
    }()
    
    fileprivate let borderView: UIView = {
        let bv = UIView()
        bv.backgroundColor = .lightGray
        return bv
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupViews() {
        
        addSubview(bgView)
        
        // BackgroundImageView
        _ = bgView.anchor(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor,
                          topConstant: 10, leftConstant: 10, bottomConstant: 10, rightConstant: 10,
                          widthConstant: 0, heightConstant: 0)
        
        bgView.addSubview(roomLabel)
        bgView.addSubview(roomFloorLabel)
        bgView.addSubview(washersDryersView)
        bgView.addSubview(borderView)
        bgView.addSubview(washerView)
        /*
        bgView.addSubview(washerLoadingSpinner)
        bgView.addSubview(dryerLoadingSpinner)*/
        bgView.addSubview(washerCollectionViewContainer)
        washerCollectionView = generateCollectionView(washerCollectionViewContainer.frame)
        bgView.addSubview(washerCollectionView!)
        
        bgView.addSubview(dryerView)
        bgView.addSubview(dryerCollectionViewContainer)
        dryerCollectionView = generateCollectionView(dryerCollectionViewContainer.frame)
        bgView.addSubview(dryerCollectionView!)
        
        bgView.addSubview(washersLabel)
        bgView.addSubview(dryersLabel)
        
        bgView.addSubview(numWashersLabel)
        bgView.addSubview(numDryersLabel)
        
        // X Button
        bgView.addSubview(xButton)
        xButton.translatesAutoresizingMaskIntoConstraints = false
        
        xButton.heightAnchor.constraint(
            equalTo: bgView.widthAnchor,
            multiplier: 0.07).isActive = true
        xButton.widthAnchor.constraint(
            equalTo: xButton.heightAnchor).isActive = true
        xButton.trailingAnchor.constraint(
            equalTo: bgView.trailingAnchor,
            constant: -15).isActive = true
        xButton.centerYAnchor.constraint(
            equalTo: roomFloorLabel.centerYAnchor).isActive = true
        
        // WashersDryersView
        _ = washersDryersView.anchor(bgView.topAnchor, left: bgView.leftAnchor,
                                     bottom: bgView.bottomAnchor, right: bgView.rightAnchor,
                                     topConstant: 70, leftConstant: 0, bottomConstant: 10, rightConstant: 0,
                                     widthConstant: 0, heightConstant: 0)
        
        _ = borderView.anchor(nil, left: washersDryersView.leftAnchor,
                              bottom: washersDryersView.topAnchor, right: washersDryersView.rightAnchor,
                              topConstant: 0, leftConstant: 10, bottomConstant: 0, rightConstant: 10,
                              widthConstant: 0, heightConstant: 1)
        
        // Washer View
        _ = washerView.anchor(washersDryersView.topAnchor, left: washersDryersView.leftAnchor,
                              bottom: nil, right: washersDryersView.rightAnchor,
                              topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0,
                              widthConstant: 0, heightConstant: 0)
        washerView.heightAnchor.constraint(
            equalTo: washersDryersView.heightAnchor,
            multiplier: 0.5).isActive = true
        
        // Washer Collection View
        _ = washerCollectionView!.anchor(washerView.topAnchor, left: washerView.leftAnchor,
                                         bottom: washerView.bottomAnchor, right: washerView.rightAnchor,
                                         topConstant: 20, leftConstant: 0, bottomConstant: 0, rightConstant: 0,
                                         widthConstant: 0, heightConstant: 0)
        
        // Dryer View
        _ = dryerView.anchor(nil, left: washersDryersView.leftAnchor,
                             bottom: washersDryersView.bottomAnchor, right: washersDryersView.rightAnchor,
                             topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0,
                             widthConstant: 0, heightConstant: 0)
        dryerView.heightAnchor.constraint(
            equalTo: washersDryersView.heightAnchor,
            multiplier: 0.5).isActive = true
        
        // Dryer Collection View
        _ = dryerCollectionView!.anchor(dryerView.topAnchor, left: dryerView.leftAnchor,
                                        bottom: dryerView.bottomAnchor, right: dryerView.rightAnchor,
                                        topConstant: 10, leftConstant: 0, bottomConstant: 0, rightConstant: 0,
                                        widthConstant: 0, heightConstant: 0)
        
        /*
        // Loading spinners
        washerLoadingSpinner.translatesAutoresizingMaskIntoConstraints = false
        washerLoadingSpinner.leadingAnchor.constraint(
            equalTo: washerCollectionView!.leadingAnchor,
            constant: 20).isActive = true
        washerLoadingSpinner.centerYAnchor.constraint(
            equalTo: washerCollectionView!.centerYAnchor).isActive = true
        
        dryerLoadingSpinner.translatesAutoresizingMaskIntoConstraints = false
        dryerLoadingSpinner.leadingAnchor.constraint(
            equalTo: dryerCollectionView!.leadingAnchor,
            constant: 20).isActive = true
        dryerLoadingSpinner.centerYAnchor.constraint(
            equalTo: dryerCollectionView!.centerYAnchor).isActive = true*/
        
        
        // Building Floor Label
        roomFloorLabel.translatesAutoresizingMaskIntoConstraints = false
        roomFloorLabel.leadingAnchor.constraint(
            equalTo: bgView.leadingAnchor,
            constant: 20).isActive = true
        roomFloorLabel.topAnchor.constraint(
            equalTo: bgView.topAnchor,
            constant: 10).isActive = true
        
        // Room Label (Building name)
        roomLabel.translatesAutoresizingMaskIntoConstraints = false
        roomLabel.leadingAnchor.constraint(
            equalTo: bgView.leadingAnchor,
            constant: 20).isActive = true
        roomLabel.topAnchor.constraint(
            equalTo: roomFloorLabel.bottomAnchor,
            constant: 3).isActive = true
        
        
        // "Washers" Label
        washersLabel.translatesAutoresizingMaskIntoConstraints = false
        washersLabel.leadingAnchor.constraint(
            equalTo: washerView.leadingAnchor,
            constant: 20).isActive = true
        washersLabel.topAnchor.constraint(
            equalTo: washerView.topAnchor,
            constant: 8).isActive = true
        
        // "Num Washers" Label
        numWashersLabel.translatesAutoresizingMaskIntoConstraints = false
        numWashersLabel.trailingAnchor.constraint(
            equalTo: washerView.trailingAnchor,
            constant: -10).isActive = true
        numWashersLabel.centerYAnchor.constraint(
            equalTo: washersLabel.centerYAnchor,
            constant: 0).isActive = true
        
        // "Dryers" Label
        dryersLabel.translatesAutoresizingMaskIntoConstraints = false
        dryersLabel.leadingAnchor.constraint(
            equalTo: dryerView.leadingAnchor,
            constant: 20).isActive = true
        dryersLabel.topAnchor.constraint(
            equalTo: dryerView.topAnchor,
            constant: 2).isActive = true
        
        // "Num Dryers" Label
        numDryersLabel.translatesAutoresizingMaskIntoConstraints = false
        numDryersLabel.trailingAnchor.constraint(
            equalTo: dryerView.trailingAnchor,
            constant: -10).isActive = true
        numDryersLabel.centerYAnchor.constraint(
            equalTo: dryersLabel.centerYAnchor,
            constant: 0).isActive = true
        
    }
    
    
}

// Mark: CollectionView Delegate and Datasource

extension LaundryCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    fileprivate func generateCollectionView(_ frame: CGRect) -> UICollectionView {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: frame, collectionViewLayout: flowLayout)
        collectionView.register(LaundryMachineCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.clear
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == washerCollectionView {
            let numItems = room.numWasherOpen + room.numWasherRunning + room.numWasherOffline + room.numWasherOutOfOrder
            if numItems == 0 {
                numWashersLabel.text = ""
            } else {
                numWashersLabel.text = "\(room.numWasherOpen) of \(numItems) open"
            }
            return numItems
        } else if collectionView == dryerCollectionView {
            let numItems = room.numDryerOpen + room.numDryerRunning + room.numDryerOffline + room.numDryerOutOfOrder
            if numItems == 0 {
                numDryersLabel.text = ""
            } else {
                numDryersLabel.text = "\(room.numDryerOpen) of \(numItems) open"
            }
            return numItems
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath as IndexPath) as! LaundryMachineCell
        
        cell.backgroundColor = UIColor.clear
        cell.bgImageColor = UIColor.clear
        cell.isUnderNotification = false
        cell.timerText = ""
        
        guard let room = room else { return cell }
        
        if collectionView == washerCollectionView {
            if (indexPath.row < room.numWasherRunning) {
                cell.bgImage = UIImage(named: "washer_busy")
                if indexPath.row < room.remainingTimeWashers.count {
                    let time = room.remainingTimeWashers[indexPath.row]
                    cell.timerText = "\(time)"
                    cell.isUnderNotification = room.isUnderNotification(isWasher: true, timeRemaining: time)
                }
            } else if (indexPath.row < room.numWasherOpen + room.numWasherRunning) {
                cell.bgImage = UIImage(named: "washer_open")
            } else {
                cell.bgImage = UIImage(named: "washer_broken")
            }
        } else {
            if (indexPath.row < room.numDryerRunning) {
                cell.bgImage = UIImage(named: "dryer_busy")
                if indexPath.row < room.remainingTimeDryers.count {
                    let time = room.remainingTimeDryers[indexPath.row]
                    cell.timerText = "\(time)"
                    cell.isUnderNotification = room.isUnderNotification(isWasher: false, timeRemaining: time)
                }
            } else if (indexPath.row < room.numDryerOpen + room.numDryerRunning) {
                cell.bgImage = UIImage(named: "dryer_open")
            } else {
                cell.bgImage = UIImage(named: "dryer_broken")
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 55, height: 55)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 20, bottom: 5, right: 5)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Uncomment to handle notifications
//        let isWasher = collectionView == washerCollectionView
//        let timeArray = isWasher ? room.remainingTimeWashers : room.remainingTimeDryers
//
//        if indexPath.item < timeArray.count {
//            delegate?.handleMachineCellTapped(for: room, isWasher: isWasher, timeRemaining: timeArray[indexPath.item]) {
//                collectionView.reloadData()
//            }
//        }
    }
    
    func reloadCollectionViews() {
        washerCollectionView?.reloadData()
        dryerCollectionView?.reloadData()
    }
}

// Mark: Delete cell
extension LaundryCell {
    @objc fileprivate func deleteRoom() {
        delegate?.deleteLaundryCell(for: room)
    }
}
