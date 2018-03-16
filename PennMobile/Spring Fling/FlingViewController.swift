//
//  FlingViewController.swift
//  PennMobile
//
//  Created by Josh Doman on 3/10/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation
import SimpleImageViewer

final class FlingTableViewModel: ModularTableViewModel {}

final class FlingViewController: GenericViewController {
    
    var tableView: ModularTableView!
    
    // For Map Zoom
    fileprivate var mapImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Spring Fling"
        prepareTableView()
        prepareMapImageView()
        prepareMapBarButton()
        setPerformers()
    }
}

// MARK: - Map Image
extension FlingViewController {
    fileprivate func prepareMapBarButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Map", style: .done, target: self, action: #selector(handleMapButtonPressed(_:)))
    }
    
    fileprivate func prepareMapImageView() {
        let image = UIImage(named: "Fling_Map")
        mapImageView = UIImageView(image: image)
        mapImageView.contentMode = .scaleAspectFill
        mapImageView.isHidden = true
        
        let widthToHeightRatio = CGFloat(1062/632)
        let width: CGFloat = 4
        let height = widthToHeightRatio * width
        
        view.addSubview(mapImageView)
        _ = mapImageView.anchor(tableView.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, topConstant: -height, leftConstant: 0, bottomConstant: 0, rightConstant: 30, widthConstant: width, heightConstant: height)
    }
    
    @objc fileprivate func handleMapButtonPressed(_ sender: Any?) {
        let configuration = ImageViewerConfiguration { config in
            config.imageView = mapImageView
        }
        
        let imageViewerController = ImageViewerController(configuration: configuration)
        present(imageViewerController, animated: true)
    }
}

// MARK: - Prepare TableView
extension FlingViewController {
    func prepareTableView() {
        tableView = ModularTableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        
        view.addSubview(tableView)
        
        tableView.anchorToTop(nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor)
        if #available(iOS 11.0, *) {
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        } else {
            tableView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 0).isActive = true
            tableView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.bottomAnchor, constant: 0).isActive = true
        }
        
        HomeItemTypes.instance.registerCells(for: tableView)
    }
}

// MARK: - Performers
extension FlingViewController {
    func setPerformers() {
        let performer1 = FlingPerformer.getDefaultPerformer()
        let performer2 = FlingPerformer.getDefaultPerformer()
        let performer3 = FlingPerformer.getDefaultPerformer()
        
        let performers = [performer1, performer2, performer3]
        let items = performers.map { (performer) -> HomeFlingCellItem in
            return HomeFlingCellItem(performer: performer)
        }
        let model = FlingTableViewModel()
        model.items = items
        tableView.model = model
        tableView.reloadData()
    }
}
