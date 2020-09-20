//
//  HomePollsCell.swift
//  PennMobile
//
//  Created by Lucy Yuewei Yuan on 9/19/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import Foundation
import UIKit

final class HomePollsCell: UITableViewCell, HomeCellConformable {
    var delegate: ModularTableViewCellDelegate!
    static var identifier: String = "pollsCell"
    
    var item: ModularTableViewItem! {
        didSet {
            guard let item = item as? HomePollsCellItem else { return }
            setupCell(with: item)
        }
    }
    
    static func getCellHeight(for item: ModularTableViewItem) -> CGFloat {
//        guard let item = item as? HomePollsCellItem else { return 0.0 }
        let pollHeight = CGFloat(20.0)
        return (pollHeight + HomeCellHeader.height + (Padding.pad * 3))
    }
    
    var pollQuestion: PollQuestion!
    
    // MARK: - UI Elements
    var cardView: UIView! = UIView()
    fileprivate var safeArea: HomeCellSafeArea = HomeCellSafeArea()
    fileprivate var header: HomeCellHeader = HomeCellHeader()
    fileprivate var tableView: UITableView!
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        prepareHomeCell()
        prepareUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup UI Elements
extension HomePollsCell {
    fileprivate func setupCell(with item: HomePollsCellItem) {
        pollQuestion = item.pollQuestion
        //tableView.reloadData()
        header.secondaryTitleLabel.text = "Poll from THE OFFICE OF THE VICE PROVOST"
        header.primaryTitleLabel.text = item.pollQuestion.title
    }
}



// MARK: - Initialize & Layout UI Elements
extension HomePollsCell {
    fileprivate func prepareUI() {
        prepareSafeArea()
        prepareHeader()
        //prepareTableView()
    }
    
    // MARK: Safe Area and Header
    fileprivate func prepareSafeArea() {
        cardView.addSubview(safeArea)
        safeArea.prepare()
    }
    
    fileprivate func prepareHeader() {
        safeArea.addSubview(header)
        header.prepare()
    }

    // MARK: TableView
    fileprivate func prepareTableView() {
        cardView.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.leading.equalTo(cardView)
            make.top.equalTo(header.snp.bottom).offset(pad)
            make.trailing.equalTo(cardView)
            make.bottom.equalTo(cardView).offset(-pad)
        }
    }
}


