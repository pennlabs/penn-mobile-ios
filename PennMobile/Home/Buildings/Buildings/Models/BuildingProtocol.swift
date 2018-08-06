//
//  BuildingProtocol.swift
//  PennMobile
//
//  Created by Dominic Holmes on 8/6/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

enum BuildingCellType {
    case title
    case image
    case weekHours
    case foodMenu
    case map
}

enum BuildingType {
    case diningHall
    case diningRetail
    case fitnessCenter
    case fitnessCourt
}

protocol BuildingDetailDisplayable {
    func cellsToDisplay() -> [BuildingCellType]
    func numberOfCellsToDisplay() -> Int
    func getBuildingType() -> BuildingType
}

protocol BuildingHeaderDisplayable {
    func getTitle() -> String
    func getSubtitle() -> String
    func getStatus() -> BuildingHeaderState
}

protocol BuildingImageDisplayable {
    func getImage() -> String
}

protocol BuildingHoursDisplayable {
    func getTimeStrings() -> [String]
}
