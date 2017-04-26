//
//  BookViewControllerExtension.swift
//  GSR
//
//  Created by Yagil Burowski on 17/09/2016.
//  Copyright © 2016 Yagil Burowski. All rights reserved.
//

import Foundation
import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


enum Selection {
    case remove, add
}

extension BookViewController: CollectionViewProtocol {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        var dataSource = roomData
        
        let room = Array(sortedKeys)[collectionView.tag]
        return dataSource[room]!.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HourCell.identifier,
                                                        for: indexPath) as! HourCell
        
        var dataSource = roomData
        
        let room = Array(sortedKeys)[collectionView.tag]
        let hour = dataSource[room]![indexPath.row]
        
        cell.hour = hour
        cell.tag = hour.id
        
        if ((currentSelection?.contains(hour)) == true) {
            cell.backgroundColor = Colors.blue.color()
        } else {
            cell.backgroundColor = Colors.green.color()
        }
        
        return cell
    }
    
    // MARK: - Collection View Delegate Methods
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        handleSelection(collectionView, indexPath: indexPath, action: Selection.add)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        handleSelection(collectionView, indexPath: indexPath, action: Selection.remove)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return validateChoice(collectionView, indexPath: indexPath)
    }
    
    // MARK: - Validation & Submission methods
    
    internal func validateChoice(_ collectionView: UICollectionView, indexPath: IndexPath) -> Bool{
        if (currentSelection!.count >= 4) {
            showAlert(withMsg: "You can choose a maximum of 4 slots", title: "Can't do that.", completion: nil)
            return false
        } else if (currentSelection!.count == 0) {
            return true
        }
        
        let room = Array(sortedKeys)[collectionView.tag]
        let hour = roomData[room]![indexPath.row]
        
        if (currentSelection?.contains(hour) == true) {
            handleSelection(collectionView, indexPath: indexPath, action: Selection.remove)
            showAlert(withMsg: "You can only choose consecutive times", title: "Can't do that.", completion: nil)
            return false
        }
        
        return isChoiceAllowed(hour)
    }
    
    internal func isChoiceAllowed(_ hour: GSRHour) -> Bool {
        var flag = false
        for selection in currentSelection! {
            flag =                       flag ||
                hour.id == selection.prev?.id ||
                hour.id == selection.next?.id
        }
        return flag
    }
    
    internal func validateSubmission() -> Bool {
        if (currentSelection!.count == 1) {
            return true
        }
        
        for selection in currentSelection! {
            if (isChoiceAllowed(selection) == false) {
                return false
            }
        }
        return true
    }
    
    internal func handleSelection(_ collectionView: UICollectionView, indexPath: IndexPath, action: Selection) {

        var dataSource = roomData

        let cell = collectionView.cellForItem(at: indexPath) as! HourCell
        let room = Array(sortedKeys)[collectionView.tag]
        let hour = dataSource[room]![indexPath.row]
        
        switch action {
        case .add:
            currentSelection?.insert(hour)
            cell.backgroundColor = Colors.blue.color()
            break
        case .remove:
            currentSelection?.remove(hour)
            cell.backgroundColor = Colors.green.color()
            break
        }
    }
    
    internal func getSelectionIds() -> [Int] {
        var ids = [Int]()
        
        for selection in currentSelection! {
            ids.append(selection.id)
        }
        
        return ids
    }
    
    internal func getEmailAndPassword() -> (String?, String?) {
        
        let defaults = UserDefaults.standard
        
        let email = defaults.string(forKey: "email")
        let password = defaults.string(forKey: "password")
        
        return (email, password)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = cellSize - 12
        return CGSize(width: size, height: size)
    }
}

extension BookViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view == rangeSlider || touch.location(in: tableView).y > 0 {
            return false
        }
        return true
    }
}
