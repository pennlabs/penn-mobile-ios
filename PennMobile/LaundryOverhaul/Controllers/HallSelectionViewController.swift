//
//  HallsSelectionViewController.swift
//  PennMobile
//
//  Created by Zhilei Zheng on 2017/11/5.
//  Copyright © 2017年 PennLabs. All rights reserved.
//

import UIKit

protocol HallSelectionDelegate: class {
    func saveSelection(for halls: [LaundryHall])
}

class HallSelectionViewController: UIViewController, ShowsAlert, Trackable {
    
    weak var delegate: HallSelectionDelegate?
    
    fileprivate let maxNumHalls = 3
    
    var chosenHalls = [LaundryHall]()
    
    // Views
    fileprivate lazy var selectionView: HallSelectionView = {
        let hsv = HallSelectionView(frame: .zero)
        hsv.delegate = self
        return hsv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "\(chosenHalls.count)/\(maxNumHalls) Chosen"
        self.navigationController?.navigationBar.tintColor = UIColor.navRed
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(handleSave))
        
        view.backgroundColor = .white
        
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
        navigationItem.title = "\(chosenHalls.count)/\(maxNumHalls) Chosen"
        selectionView.prepare(with: chosenHalls)
    }
}

extension HallSelectionViewController: HallSelectionViewDelegate {
    func updateSelectedHalls(for halls: [LaundryHall]) {
        navigationItem.title = "\(halls.count)/\(selectionView.maxNumHalls) Chosen"
    }
    
    func handleFailureToLoadDictionary() {
        self.showAlert(withMsg: "Try quitting and restarting the app.", title: "Network API Failed", completion: nil)
    }
}

// Mark: Hall selection
extension HallSelectionViewController {
    @objc fileprivate func handleSave() {
        delegate?.saveSelection(for: selectionView.chosenHalls)
        _ = selectionView.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }

    @objc fileprivate func handleCancel() {
        _ = selectionView.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }
}
