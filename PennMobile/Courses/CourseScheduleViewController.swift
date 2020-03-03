//
//  CourseScheduleViewController.swift
//  PennMobile
//
//  Created by CHOI Jongmin on 14/2/2020.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import UIKit

protocol CourseScheduleCellDelegate: ModularTableViewCellDelegate, BuildingMapSelectable {}

class CourseScheduleViewController: GenericViewController, IndicatorEnabled, ShowsAlert {

    fileprivate var courseScheduleTableView: ModularTableView!
    fileprivate var model: CourseScheduleTableViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Course Schedule"
        
        prepareCourseScheduleTableView()

        self.fetchViewModel {
            self.hideActivity()
        }
    }
}

// MARK: - Fetch and assign Model + Delegate
extension CourseScheduleViewController {
    func fetchViewModel(_ completion: @escaping () -> Void) {
        if let courses = UserDefaults.standard.getCourses() {
//            TODO: Do something if the UserDefaults do not have any stored courses
            model = try? CourseScheduleTableViewModel(courses: courses)
            DispatchQueue.main.async {
                self.setCourseScheduleTableViewModel(self.model)
                self.courseScheduleTableView.reloadData()
                completion()
            }
        } else {
            self.showAlert(withMsg: "Please login to use this feature", title: "Login Error", completion: { self.navigationController?.popViewController(animated: true)} )
        }
    }
    
    func setCourseScheduleTableViewModel(_ model: CourseScheduleTableViewModel) {
        self.model = model
        self.model.delegate = self
        courseScheduleTableView.model = self.model
    }
}

// MARK: - Prepare TableViews
extension CourseScheduleViewController {
    func prepareCourseScheduleTableView() {
        courseScheduleTableView = ModularTableView()
        courseScheduleTableView.backgroundColor = .clear
        courseScheduleTableView.separatorStyle = .none
        
        view.addSubview(courseScheduleTableView)
        
        courseScheduleTableView.anchorToTop(nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor)
        courseScheduleTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        courseScheduleTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        courseScheduleTableView.tableFooterView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: 30.0))
        
        HomeItemTypes.instance.registerCells(for: courseScheduleTableView)
    }
}

// MARK: - ModularTableViewDelegate
extension CourseScheduleViewController: CourseScheduleCellDelegate{
    func handleBuildingSelected(searchTerm: String) {
        let mapVC = MapViewController()
        mapVC.searchTerm = searchTerm
        self.navigationController?.pushViewController(mapVC, animated: true)
    }
}




