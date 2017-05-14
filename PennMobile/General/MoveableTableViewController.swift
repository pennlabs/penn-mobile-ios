//
//  MoveableTableViewController.swift
//  PennMobile
//
//  Created by Josh Doman on 5/13/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import UIKit

protocol MoveableDelegate {
    func rowMoved(from sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
}

class MoveableTableViewController: UITableViewController {
    public typealias FinishedMovingCallback = () -> Void
    
    fileprivate var longpress: UILongPressGestureRecognizer!
    fileprivate var initialIndexPath: IndexPath? //for movable cell
    fileprivate var cellSnapshot: UIView?
    fileprivate var finishedMovingCallback: FinishedMovingCallback?
    
    internal var isMoveable: Bool = false {
        didSet {
            if isMoveable {
                addLongPressGesture()
            } else {
                tableView.removeGestureRecognizer(longpress)
                longpress = nil
            }
        }
    }
    
    internal var moveDelegate: MoveableDelegate?
    
    internal func setFinishedMovingCell(_ callback: FinishedMovingCallback?) {
        self.finishedMovingCallback = callback
    }
}

// MARK: code for drag and drop cells
// source: https://github.com/Task-Hero/TaskHero-iOS/blob/master/TaskHero/HomeViewController.swift

extension MoveableTableViewController {
    
    fileprivate func addLongPressGesture() {
        if longpress == nil {
            longpress = UILongPressGestureRecognizer(target: self, action: #selector(onLongPressGesture(sender:)))
            tableView.addGestureRecognizer(longpress)
        }
    }
    
    @objc fileprivate func onLongPressGesture(sender: UILongPressGestureRecognizer) {
        let locationInView = sender.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: locationInView)
        
        if sender.state == .began {
            if indexPath != nil {
                initialIndexPath = indexPath
                let cell = tableView.cellForRow(at: indexPath!)
                cellSnapshot = snapshotOfCell(inputView: cell!)
                var center = cell?.center
                cellSnapshot?.center = center!
                cellSnapshot?.alpha = 0.0
                tableView.addSubview(cellSnapshot!)
                
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    center?.y = locationInView.y
                    self.cellSnapshot?.center = center!
                    self.cellSnapshot?.transform = (self.cellSnapshot?.transform.scaledBy(x: 1.05, y: 1.05))!
                    self.cellSnapshot?.alpha = 0.99
                    cell?.alpha = 0.0
                }, completion: { (finished) -> Void in
                    if finished {
                        cell?.isHidden = true
                    }
                })
            }
        } else if sender.state == .changed {
            var center = cellSnapshot?.center
            center?.y = locationInView.y
            cellSnapshot?.center = center!
            
            if ((indexPath != nil) && (indexPath != initialIndexPath)) {
                moveDelegate?.rowMoved(from: initialIndexPath!, to: indexPath!)
                tableView.moveRow(at: initialIndexPath!, to: indexPath!)
                initialIndexPath = indexPath
            }
        } else if sender.state == .ended {
            let cell = tableView.cellForRow(at: initialIndexPath!)
            cell?.isHidden = false
            cell?.alpha = 0.0
            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                self.cellSnapshot?.center = (cell?.center)!
                self.cellSnapshot?.transform = CGAffineTransform.identity
                self.cellSnapshot?.alpha = 0.0
                cell?.alpha = 1.0
            }, completion: { (finished) -> Void in
                if finished {
                    self.initialIndexPath = nil
                    self.cellSnapshot?.removeFromSuperview()
                    self.cellSnapshot = nil
                }
            })
            finishedMovingCallback?()
        }
    }
    
    fileprivate func snapshotOfCell(inputView: UIView) -> UIView {
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
        inputView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let cellSnapshot = UIImageView(image: image)
        cellSnapshot.layer.masksToBounds = false
        cellSnapshot.layer.cornerRadius = 0.0
        cellSnapshot.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
        cellSnapshot.layer.shadowRadius = 5.0
        cellSnapshot.layer.shadowOpacity = 0.4
        return cellSnapshot
    }
}
