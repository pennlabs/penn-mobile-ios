//
//  RoomCell.swift
//  GSR
//
//  Created by Yagil Burowski on 17/09/2016.
//  Copyright © 2016 Yagil Burowski. All rights reserved.
//

import UIKit

protocol GSRSelectionDelegate {
    func containsTimeSlot(_ timeSlot: GSRTimeSlot) -> Bool
    func validateChoice(for room: GSRRoom, timeSlot: GSRTimeSlot, action: SelectionType) -> Bool
    func handleSelection(for room: GSRRoom, timeSlot: GSRTimeSlot, action: SelectionType)
}

class RoomCell: UITableViewCell {
    static let cellHeight: CGFloat = 90
    static let identifier = "roomCell"
    
    var room: GSRRoom! {
        didSet {
            collectionView.dataSource = self
            collectionView.reloadData()
        }
    }
    
    var delegate: GSRSelectionDelegate!
    
    fileprivate lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 8
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(GSRTimeCell.self, forCellWithReuseIdentifier: GSRTimeCell.identifier)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.delegate = self
        cv.allowsMultipleSelection = true
        return cv
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none

        addSubview(collectionView)
        _ = collectionView.anchor(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 6, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension RoomCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return room.timeSlots.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GSRTimeCell.identifier, for: indexPath) as! GSRTimeCell
        let timeSlot = room.timeSlots[indexPath.row]
        cell.timeSlot = timeSlot
        if delegate.containsTimeSlot(timeSlot) {
            cell.backgroundColor = .informationYellow
        } else {
            cell.backgroundColor = timeSlot.isAvailable ? UIColor.interactionGreen : UIColor.secondaryInformationGrey
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = RoomCell.cellHeight - 12
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let timeSlot = room.timeSlots[indexPath.row]
        return delegate!.validateChoice(for: room, timeSlot: timeSlot, action: SelectionType.add)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        let timeSlot = room.timeSlots[indexPath.row]
        return delegate!.validateChoice(for: room, timeSlot: timeSlot, action: SelectionType.remove)
    }
    
    // MARK: - Collection View Delegate Methods
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let timeSlot = room.timeSlots[indexPath.row]
        delegate?.handleSelection(for: room, timeSlot: timeSlot, action: SelectionType.add)
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = .informationYellow
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let timeSlot = room.timeSlots[indexPath.row]
        delegate?.handleSelection(for: room, timeSlot: timeSlot, action: SelectionType.remove)
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = .interactionGreen
    }
}
