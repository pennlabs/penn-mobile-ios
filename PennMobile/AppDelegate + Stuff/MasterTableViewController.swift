//
//  MasterTableViewController.swift
//  PennMobile
//
//  Created by Josh Doman on 5/3/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import UIKit

class ControllerSettings: NSObject {
    
    static let shared = ControllerSettings()
    
    let vcDictionary: [String: UIViewController] = {
        var dict = [String: UIViewController]()
        dict["Dining"] = DiningViewController()
        dict["Study Room Booking"] = BookViewController()
        dict["Laundry"] = LaundryTableViewController()
        dict["News"] = NewsViewController()
        dict["Emergency"] = EmergencyController()
        dict["About"] = AboutViewController()
        return dict
    }()
    
    var viewControllers: [UIViewController] {
        let orderedArr = self.displayNames
        var arr = [UIViewController]()
        for title in orderedArr {
            arr.append(ControllerSettings.shared.viewController(for: title))
        }
        return arr
    }
    
    var displayNames: [String] {
        if let savedArr = UserDefaults.standard.stringArray(forKey: "Controller settings") {
            return savedArr
        }
        return vcDictionary.keys.toArray()
    }
    
    func viewController(for title: String) -> UIViewController {
        return vcDictionary[title] ?? UIViewController()
    }
    
    var firstController: UIViewController {
        return viewControllers.first!
    }
}

class MasterTableViewController: UITableViewController {
    
    fileprivate var viewControllerArray = ControllerSettings.shared.viewControllers
    fileprivate var displayNameArray = ControllerSettings.shared.displayNames
    
    fileprivate let cellID = "cellID"
    fileprivate var selectedIndex: IndexPath {
        get {
            for vc in viewControllerArray {
                if vc.isViewLoaded && vc.view.window != nil { //viewController is visible
                    return IndexPath(row: viewControllerArray.index(of: vc)!, section: 0)
                }
            }
            return IndexPath(row: 0, section: 0)
        }
    }
    
    fileprivate var initialIndexPath: IndexPath? //for movable cell
    fileprivate var cellSnapshot: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        revealViewController().frontViewController.view.isUserInteractionEnabled = false
        revealViewController().view.addGestureRecognizer(revealViewController().panGestureRecognizer())
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        revealViewController().frontViewController.view.isUserInteractionEnabled = true
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewControllerArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        cell.textLabel?.text = displayNameArray[indexPath.row]
        cell.backgroundColor = .clear
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.isHighlighted = true
        
        let viewController = viewControllerArray[indexPath.row]
        if viewController.isViewLoaded && viewController.view.window != nil { //viewController is visible
            revealViewController().setFrontViewPosition(FrontViewPosition.left, animated: true)
            return
        }
        
        let navController = UINavigationController(rootViewController: viewControllerArray[indexPath.row])
        revealViewController().pushFrontViewController(navController, animated: true)
        tableView.cellForRow(at: selectedIndex)?.isHighlighted = false
    }
}

// MARK: setup tableview

extension MasterTableViewController {
    fileprivate func loadTableView() {
        tableView.tableFooterView = UIView() //removes empty lines
        tableView.bounces = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        addLongPressGesture() //enables long press to reorder cells
    }
}

// MARK: code for drag and drop cells
// source: https://github.com/Task-Hero/TaskHero-iOS/blob/master/TaskHero/HomeViewController.swift

extension MasterTableViewController {
    
    func addLongPressGesture() {
        let longpress = UILongPressGestureRecognizer(target: self, action: #selector(onLongPressGesture(sender:)))
        tableView.addGestureRecognizer(longpress)
    }
    
    func onLongPressGesture(sender: UILongPressGestureRecognizer) {
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
                swap(&viewControllerArray[indexPath!.row], &viewControllerArray[initialIndexPath!.row]) //swap controllers
                swap(&displayNameArray[indexPath!.row], &displayNameArray[initialIndexPath!.row]) //swap display names
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
            UserDefaults.standard.set(displayNameArray, forKey: "Controller settings")
        }
    }
    
    func snapshotOfCell(inputView: UIView) -> UIView {
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
