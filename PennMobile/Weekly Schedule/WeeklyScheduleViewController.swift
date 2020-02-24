//
//  ScheduleViewController.swift
//  PennMobile
//
//  Created by CHOI Jongmin on 14/2/2020.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import UIKit

protocol WeeklyScheduleCellDelegate: ModularTableViewCellDelegate, BuildingMapSelectable {}

final class WeeklyScheduleTableViewModel: ModularTableViewModel {}

class WeeklyScheduleViewController: GenericViewController, IndicatorEnabled, ShowsAlert {

    fileprivate var weeklyScheduleTableView: ModularTableView!
    fileprivate var model: WeeklyScheduleTableViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Weekly Schedule"
        
        prepareWeeklyScheduleTableView()

        self.fetchViewModel {
            self.hideActivity()
        }
    }
}

// MARK: - Fetch and assign Model + Delegate
extension WeeklyScheduleViewController {
    func fetchViewModel(_ completion: @escaping () -> Void) {
        WeeklyScheduleModelManager.instance.fetchModel { (model) in
            guard let model = model else {
                self.showAlert(withMsg: "Please login to use this feature", title: "Login Error", completion: { self.navigationController?.popViewController(animated: true)} )
                return
            }
            DispatchQueue.main.async {
                self.setWeeklyScheduleTableViewModel(model)
                self.weeklyScheduleTableView.reloadData()
                completion()
            }
        }
    }
    
    func setWeeklyScheduleTableViewModel(_ model: WeeklyScheduleTableViewModel) {
        self.model = model
        self.model.delegate = self
        weeklyScheduleTableView.model = self.model
    }
}

// MARK: - Prepare TableViews
extension WeeklyScheduleViewController {
    
    func prepareWeeklyScheduleTableView() {
        weeklyScheduleTableView = ModularTableView()
        weeklyScheduleTableView.backgroundColor = .clear
        weeklyScheduleTableView.separatorStyle = .none
        
        view.addSubview(weeklyScheduleTableView)
        
        weeklyScheduleTableView.anchorToTop(nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor)
        if #available(iOS 11.0, *) {
            weeklyScheduleTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
            weeklyScheduleTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        } else {
            weeklyScheduleTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
            weeklyScheduleTableView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.bottomAnchor, constant: 0).isActive = true
        }
        
        weeklyScheduleTableView.tableFooterView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: 30.0))
        
        HomeItemTypes.instance.registerCells(for: weeklyScheduleTableView)
    }
}

// MARK: - ModularTableViewDelegate
extension WeeklyScheduleViewController : WeeklyScheduleCellDelegate{
    func handleBuildingSelected(searchTerm: String) {
        let mapVC = MapViewController()
        mapVC.searchTerm = searchTerm
        self.navigationController?.pushViewController(mapVC, animated: true)
    }
}




