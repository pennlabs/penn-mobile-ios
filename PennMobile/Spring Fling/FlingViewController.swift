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
    
    fileprivate var performersTableView: ModularTableView!
    fileprivate var scheduleTableView: UITableView!
    fileprivate var model: FlingTableViewModel!
    fileprivate var headerToolbar: UIToolbar!
    
    // For Map Zoom
    fileprivate var mapImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Spring Fling"
        
        setupNavBar()
        prepareScheduleTableView()
        preparePerformersTableView()
        prepareMapImageView()
        prepareMapBarButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !scheduleTableView.isHidden {
            performersTableView.isHidden = true
        }
        self.fetchViewModel {
            // TODO: do something when fetch has completed
            print("Done!")
        }
    }
}

// MARK: - Initialize and layout views
extension FlingViewController: HairlineRemovable {
    fileprivate func setupNavBar() {
        //removes hairline from bottom of navbar
        if let navbar = navigationController?.navigationBar {
            removeHairline(from: navbar)
        }
        
        let width = view.frame.width
        let headerHeight = navigationController?.navigationBar.frame.height ?? 44
        
        headerToolbar = UIToolbar(frame: CGRect(x: 0, y: 64, width: width, height: headerHeight))
        headerToolbar.backgroundColor = navigationController?.navigationBar.backgroundColor
        
        let newsSwitcher = UISegmentedControl(items: ["Schedule", "Performers"])
        newsSwitcher.center = CGPoint(x: width/2, y: 64 + headerToolbar.frame.size.height/2)
        newsSwitcher.tintColor = UIColor.navRed
        newsSwitcher.selectedSegmentIndex = 0
        newsSwitcher.isUserInteractionEnabled = true
        newsSwitcher.addTarget(self, action: #selector(switchTabMode(_:)), for: .valueChanged)
        
        view.addSubview(headerToolbar)
        view.addSubview(newsSwitcher)
    }
    
    internal func switchTabMode(_ segment: UISegmentedControl) {
        scheduleTableView.isHidden = !scheduleTableView.isHidden
        performersTableView.isHidden = !performersTableView.isHidden
        
        if performersTableView.isHidden && scheduleTableView.isHidden {
            scheduleTableView.isHidden = false
        }
    }
}

// MARK: - Networking
extension FlingViewController {
    func fetchViewModel(_ completion: @escaping () -> Void) {
        FlingNetworkManager.instance.fetchModel { (model) in
            guard let model = model else { return }
            DispatchQueue.main.async {
                self.setPerformersTableViewModel(model)
                self.performersTableView.reloadData()
                self.fetchCellSpecificData {
                    // TODO: do something when done fetching cell specific data
                }
                completion()
            }
        }
    }
    
    func fetchCellSpecificData(_ completion: (() -> Void)? = nil) {
        guard let items = model.items as? [HomeCellItem] else { return }
        HomeAsynchronousAPIFetching.instance.fetchData(for: items, singleCompletion: { (item) in
            DispatchQueue.main.async {
                let row = items.index(where: { (thisItem) -> Bool in
                    thisItem.equals(item: item)
                })!
                let indexPath = IndexPath(row: row, section: 0)
                self.performersTableView.reloadRows(at: [indexPath], with: .none)
            }
        }) {
            DispatchQueue.main.async {
                completion?()
            }
        }
    }
    
    
    func setPerformersTableViewModel(_ model: FlingTableViewModel) {
        self.model = model
        self.model.delegate = self
        performersTableView.model = self.model
    }
}

// MARK: - ModularTableViewDelegate
extension FlingViewController: ModularTableViewModelDelegate {
    
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
        _ = mapImageView.anchor(performersTableView.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, topConstant: -height, leftConstant: 0, bottomConstant: 0, rightConstant: 30, widthConstant: width, heightConstant: height)
    }
    
    @objc fileprivate func handleMapButtonPressed(_ sender: Any?) {
        let configuration = ImageViewerConfiguration { config in
            config.imageView = mapImageView
        }
        
        let imageViewerController = ImageViewerController(configuration: configuration)
        present(imageViewerController, animated: true)
    }
}

// MARK: - Prepare TableViews
extension FlingViewController {
    func prepareScheduleTableView() {
        scheduleTableView = UITableView()
        scheduleTableView.backgroundColor = .clear

        view.addSubview(scheduleTableView)

        scheduleTableView.anchorToTop(nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor)
        if #available(iOS 11.0, *) {
            scheduleTableView.topAnchor.constraint(equalTo: headerToolbar.bottomAnchor, constant: 0).isActive = true
            scheduleTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        } else {
            scheduleTableView.topAnchor.constraint(equalTo: headerToolbar.bottomAnchor, constant: 0).isActive = true
            scheduleTableView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.bottomAnchor, constant: 0).isActive = true
        }
    }

    func preparePerformersTableView() {
        performersTableView = ModularTableView()
        performersTableView.backgroundColor = .clear
        performersTableView.separatorStyle = .none
        
        view.addSubview(performersTableView)
        
        performersTableView.anchorToTop(nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor)
        if #available(iOS 11.0, *) {
            performersTableView.topAnchor.constraint(equalTo: headerToolbar.bottomAnchor, constant: 0).isActive = true
            performersTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        } else {
            performersTableView.topAnchor.constraint(equalTo: headerToolbar.bottomAnchor, constant: 0).isActive = true
            performersTableView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.bottomAnchor, constant: 0).isActive = true
        }
        
        HomeItemTypes.instance.registerCells(for: performersTableView)
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
        performersTableView.model = model
        performersTableView.reloadData()
    }
}
