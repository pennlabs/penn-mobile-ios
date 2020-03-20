//
//  CourseScheduleViewController.swift
//  PennMobile
//
//  Created by CHOI Jongmin on 14/2/2020.
//  Copyright © 2020 PennLabs. All rights reserved.
//
import UIKit

protocol CourseScheduleCellDelegate: ModularTableViewCellDelegate, BuildingMapSelectable {}

class CourseScheduleViewController: GenericViewController, IndicatorEnabled, ShowsAlertForError {

    fileprivate var courseScheduleTableView: ModularTableView!
    fileprivate var model: CourseScheduleTableViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Course Schedule"

        prepareCourseScheduleTableView()
        prepareRefreshControl()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchViewModel()
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

// MARK: - Refresh Controller
extension CourseScheduleViewController {
    func prepareRefreshControl() {
        courseScheduleTableView.refreshControl = UIRefreshControl()
        courseScheduleTableView.refreshControl?.addTarget(self, action: #selector(handleCourseRefresh), for: .valueChanged)
    }

    @objc func handleCourseRefresh() {
        PennInTouchNetworkManager.instance.getCourses(currentTermOnly: true, callback: { (result) in
            DispatchQueue.main.async {
                self.handleNetworkCourseRefreshResult(result)
                self.courseScheduleTableView.refreshControl?.endRefreshing()
            }
        })
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.courseScheduleTableView.isHidden = true
        self.courseScheduleTableView.refreshControl?.endRefreshing()
        self.courseScheduleTableView.contentOffset = CGPoint.zero
    }
}

// MARK: - Fetch and assign Model + Delegate
extension CourseScheduleViewController {

    private func fetchViewModel() {
        if let courses = UserDefaults.standard.getCourses() {
            assignModelAndRefreshTable(courses: courses)
        } else {
            if (Account.isLoggedIn) {
                handleCourseRefresh()
            } else {
                self.showAlert(withMsg: "Please login to use this feature", title: "Login Error", completion: { self.navigationController?.popViewController(animated: true)} )
            }
        }
    }

    private func setCourseScheduleTableViewModel(_ model: CourseScheduleTableViewModel) {
        self.model = model
        self.model.delegate = self
        courseScheduleTableView.model = self.model
    }

    private func assignModelAndRefreshTable(courses: Set<Course>) {
        self.showActivity()
        self.courseScheduleTableView.isHidden = false
        model = try? CourseScheduleTableViewModel(courses: courses)
        DispatchQueue.main.async {
            self.setCourseScheduleTableViewModel(self.model)
            self.courseScheduleTableView.reloadData()
            self.hideActivity()
        }
    }
}

// MARK: - Networking
extension CourseScheduleViewController {

    func handleNetworkCourseRefreshResult(_ result: Result<Set<Course>, NetworkingError>) {
        
        let popVC : () -> Void = { self.navigationController?.popViewController(animated: true) }
        
        showRefreshAlertForError(result: result, title: "courses", success: self.handleNetworkCourseRefreshCompletion(_:), noInternet: popVC, parsingError: popVC, authenticationError: self.handleAuthentication)
    }

    private func handleNetworkCourseRefreshCompletion(_ courses: Set<Course>) {
        if let accountID = UserDefaults.standard.getAccountID() {
            UserDBManager.shared.saveCourses(courses, accountID: accountID, { (success) in
                self.assignModelAndRefreshTable(courses: courses)
            })
        } else {
            self.assignModelAndRefreshTable(courses: courses)
        }

        if let currentCourses = UserDefaults.standard.getCourses() {
            let term = Course.currentTerm
            let currentCoursesMinusTerm = currentCourses.filter { $0.term != term }
            let newCourses = currentCoursesMinusTerm.union(courses)
            UserDefaults.standard.saveCourses(newCourses)
        }
    }
}

// MARK: - Authentication
extension CourseScheduleViewController {
    private func handleAuthentication() {
        let llc = LabsLoginController { (success) in
            self.showActivity()
            DispatchQueue.main.async {
                self.loginCompletion(success)
            }
            self.hideActivity()
        }

        llc.handleCancel = { self.navigationController?.popViewController(animated: true) }
        let nvc = UINavigationController(rootViewController: llc)

        present(nvc, animated: true, completion: nil)
    }

    fileprivate func loginCompletion(_ successful: Bool) {
        if successful {
            handleCourseRefresh()
        } else {
            showAlert(withMsg: "Something went wrong. Please try again later.", title: "Uh oh!", completion: { self.navigationController?.popViewController(animated: true) } )
        }
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
