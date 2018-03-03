//
//  HomeDiningCell.swift
//  PennMobile
//
//  Created by Josh Doman on 1/17/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation
import UIKit

final class HomeDiningCell: UITableViewCell, HomeCellConformable {
    static var identifier: String = "diningCell"
    static var cellHeight: CGFloat = 3 * DiningCell.cellHeight + 40
    
    var delegate: HomeCellDelegate!
    var item: HomeViewModelItem? {
        didSet {
            guard let item = item as? HomeViewModelDiningItem else { return }
            setupCell(with: item)
        }
    }
    
    var venues: [DiningVenue]?
    
    var cardView: UIView! = UIView()
    
    fileprivate var tableView: UITableView!

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        prepareHomeCell()
        prepareUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup
extension HomeDiningCell {
    fileprivate func setupCell(with item: HomeViewModelDiningItem) {
        venues = item.venues
    }
}

// MARK: - Prepare UI
extension HomeDiningCell {
    fileprivate func prepareUI() {
        prepareTableView()
    }
    
    private func prepareTableView() {
        tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.register(DiningCell.self, forCellReuseIdentifier: DiningCell.identifier)
        
        cardView.addSubview(tableView)
        tableView.anchorToTop(cardView.topAnchor, left: cardView.leftAnchor, bottom: cardView.bottomAnchor, right: cardView.rightAnchor)
    }
}

// MARK: - UITableViewDataSource
extension HomeDiningCell: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return venues?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DiningCell.identifier, for: indexPath) as! DiningCell
        cell.venue = venues?[indexPath.row]
        return cell
    }
}

// MARK: - UITableViewDelegate
extension HomeDiningCell: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layer.cornerRadius = 8
        cell.layer.shadowOffset = .zero
        cell.layer.shadowRadius = 5
        cell.layer.shadowOpacity = 0.2
        cell.layer.shadowPath = UIBezierPath(rect: cell.bounds).cgPath
        cell.layer.shouldRasterize = true
        cell.layer.rasterizationScale = UIScreen.main.scale
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Cell selected!")
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return DiningCell.cellHeight
    }
}
