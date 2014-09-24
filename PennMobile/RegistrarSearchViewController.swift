//
//  RegistrarSearchViewController.swift
//  PennMobile
//
//  Created by Clara Wu on 7/13/14.
//  Copyright (c) 2014 PennLabs. All rights reserved.
//

import UIKit

class RegistrarSearchViewController: UITableViewController, UISearchBarDelegate, UISearchDisplayDelegate {
   
    var courses = [Course]()
    @IBOutlet weak var searchBar: UISearchBar!

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.showsScopeBar = true
        searchBar.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return self.courses.count
    }
    
    func cellForRowAtIndexPath(indexPath: NSIndexPath) -> UITableViewCell? {
        //ask for a reusable cell from the tableview, the tableview will create a new one if it doesn't have any
        let cell = self.tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        
        var course : Course
        // Check to see whether the normal table or search results table is being displayed and set the Candy object from the appropriate array
        if tableView == self.searchDisplayController?.searchResultsTableView {
            course = self.courses[indexPath.row]
        } else {
            course = self.courses[indexPath.row]
        }
        
        // Configure the cell
        cell.textLabel?.text = course.title
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        return cell
    }
    
    
    func searchBarSearchButtonClicked( searchBar: UISearchBar!)
    {
        var urlString = "http://127.0.0.1:5000/v1/search/" + searchBar.text // Your Normal URL String
        Agent.get(urlString).end {
            response, data, error in
            let json = data! as Dictionary<String, Array<Dictionary<String, AnyObject>>>
            let courses_array = json["courses"]!
            for course in courses_array {
                let id: String = course["_id"]! as String
                let dept: String = course["dept"]! as String
                let title: String = course["title"]! as String
                let courseNumber: String = course["courseNumber"]! as String
                let credits: String = course["credits"]! as String
                let sectioNumber: String = course["sectionNumber"]! as String
                let type: String = course["type"]! as String
                let times: String = course["times"]! as String
                let building: String = course["building"]! as String
                let roomNumber: String = course["roomNumber"]! as String
                let prof: String = course["prof"]! as String
                let c = Course(id: id, dept: dept, title: title, courseNumber: courseNumber, credits: credits, sectionNumber: sectioNumber, type: type, times: times, building: building, roomNumber: roomNumber, prof: prof)
                self.courses.append(c)
                self.tableView.reloadData()
            }
        }

    }

    
   

}

