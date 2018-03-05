//
//  HomeViewModel.swift
//  PennMobile
//
//  Created by Josh Doman on 1/17/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

// MARK: - HomeViewModelItem
protocol HomeViewModelItem {
    var title: String { get }
    func equals(item: HomeViewModelItem) -> Bool
    static var jsonKey: String { get }
    static func getItem(for json: JSON?) -> HomeViewModelItem?
    static var associatedCell: HomeCellConformable.Type { get }
}

extension HomeViewModelItem {
    var cellIdentifier: String {
        return Self.associatedCell.identifier
    }
    
    var cellHeight: CGFloat {
        return Self.associatedCell.getCellHeight(for: self)
    }
}
