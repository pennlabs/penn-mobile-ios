//
//  FitnessViewModel.swift
//  PennMobile
//
//  Created by raven on 7/19/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import UIKit

class FitnessViewModel: NSObject {
    
    let facilities: [FitnessFacilityName] = FitnessFacilityName.all

    internal let fitnessCell = "fitnessCell"
    
    func getFacility(for indexPath: IndexPath) -> FitnessSchedule {
        return FitnessFacilityData.shared.getSchedule(for: facilities[indexPath.row])!
    }
}

// MARK: - UITableViewDataSource
extension FitnessViewModel: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return facilities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FitnessHourCell.identifier, for: indexPath) as! FitnessHourCell
        cell.schedule = getFacility(for: indexPath)
        return cell
    }
    
    func registerHeadersAndCells(for tableView: UITableView) {
        tableView.register(FitnessHourCell.self, forCellReuseIdentifier: FitnessHourCell.identifier)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return FitnessHourCell.cellHeight
    }
}
