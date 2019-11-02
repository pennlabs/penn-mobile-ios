//
//  HallsSelectionViewController.swift
//  PennMobile
//
//  Created by Zhilei Zheng on 2017/11/5.
//  Copyright © 2017年 PennLabs. All rights reserved.
//

import UIKit

protocol RoomSelectionVCDelegate: class {
    func saveSelection(for rooms: [LaundryRoom])
}

class RoomSelectionViewController: UIViewController, ShowsAlert, Trackable {
    
    weak var delegate: RoomSelectionVCDelegate?
    
    fileprivate let maxNumHalls = 3
    
    var chosenRooms = [LaundryRoom]()
    
    // Views
    fileprivate lazy var selectionView: RoomSelectionView = {
        let hsv = RoomSelectionView(frame: .zero)
        hsv.delegate = self
        return hsv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "\(chosenRooms.count)/\(maxNumHalls) Chosen"
        self.navigationController?.navigationBar.tintColor = UIColor.navigation
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(handleSave))
        
        view.backgroundColor = .uiBackground
        
        view.addSubview(selectionView)
        selectionView.anchorToTop(nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
        if #available(iOS 11.0, *) {
            selectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        } else {
            selectionView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 0).isActive = true
        }
        
        trackScreen("Hall Selection")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "\(chosenRooms.count)/\(maxNumHalls) Chosen"
        selectionView.prepare(with: chosenRooms)
    }
}

extension RoomSelectionViewController: RoomSelectionViewDelegate {
    func updateSelectedRooms(for rooms: [LaundryRoom]) {
        navigationItem.title = "\(rooms.count)/\(selectionView.maxNumRooms) Chosen"
    }
    
    func handleFailureToLoadDictionary() {
        self.showAlert(withMsg: "Try quitting and restarting the app.", title: "Network API Failed", completion: nil)
    }
}

// Mark: Hall selection
extension RoomSelectionViewController {
    @objc fileprivate func handleSave() {
        let rooms = selectionView.chosenRooms
        delegate?.saveSelection(for: rooms)
        _ = selectionView.resignFirstResponder()
        UserDBManager.shared.saveLaundryPreferences(for: rooms)
        dismiss(animated: true, completion: nil)
    }

    @objc fileprivate func handleCancel() {
        _ = selectionView.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }
}
