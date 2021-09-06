//
//  RoomCell.swift
//  GSR
//
//  Created by Yagil Burowski on 17/09/2016.
//  Copyright © 2016 Yagil Burowski. All rights reserved.
//

import UIKit

protocol GSRSelectionDelegate {
    func handleSelection(for id: Int)
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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none

        addSubview(collectionView)
        _ = collectionView.anchor(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 6, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func resetSelection() {
        collectionView.indexPathsForSelectedItems?.forEach { collectionView.deselectItem(at: $0, animated: true) }
    }
    
    func getSelectTimes() -> [GSRTimeSlot] {
        (collectionView.indexPathsForSelectedItems ?? []).map( {
            return room.availability[$0.item]
        })
    }
}

extension RoomCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return room.availability.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GSRTimeCell.identifier, for: indexPath) as! GSRTimeCell
        let timeSlot = room.availability[indexPath.row]
        cell.timeSlot = timeSlot
        cell.backgroundColor = timeSlot.isAvailable ? UIColor.baseGreen : UIColor.labelSecondary
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = RoomCell.cellHeight - 12
        return CGSize(width: size, height: size)
    }
    
    //only enable selection for available rooms
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let timeSlot = room.availability[indexPath.row]
        return timeSlot.isAvailable
    }
    
    // Deselect this time slot and all select ones that follow it
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = UIColor.baseGreen
        
        collectionView.indexPathsForSelectedItems?.forEach {
            if $0.item > indexPath.item {
                collectionView.deselectItem(at: $0, animated: true)
                collectionView.reloadItems(at: [$0])
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate.handleSelection(for: room.id)
        
        let indexPaths = (collectionView.indexPathsForSelectedItems ?? []).sorted(by: {$0.item < $1.item})
        
        for i in 1..<indexPaths.count {
            if (indexPaths[i].item - indexPaths[i-1].item != 1) {
                let deselectIndexPath = indexPaths.filter({ $0 != indexPath })
                deselectIndexPath.forEach({ collectionView.deselectItem(at: $0, animated: true)})
                collectionView.reloadItems(at: deselectIndexPath)
                return
            }
        }
    }
}
