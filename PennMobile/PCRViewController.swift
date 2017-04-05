//
//  PCRViewController.swift
//  PennMobile
//
//  Created by Josh Doman on 3/31/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import UIKit

class PCRViewController: RegistrarTableViewController {
    
    private let cell = "PCRCell"
    
    private var courses: [Course] {
        if let courses = filteredCourses as? [Course] { //THIS IS AN XCODE MISTAKE, IT DOES CAST
            return courses
        }
        return []
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.tintColor = UIColor(r: 192, g: 57, b:  43)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let PCRvc = PCRDetailViewController()
        PCRvc.course = courses[indexPath.item]
        self.navigationController?.pushViewController(PCRvc, animated: true)
    }
}
