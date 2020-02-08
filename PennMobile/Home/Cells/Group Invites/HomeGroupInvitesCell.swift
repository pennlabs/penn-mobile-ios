//
//  HomeGroupInvitesCell.swift
//  PennMobile
//
//  Created by Daniel Salib on 2/7/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import Foundation

final class HomeGroupInvitesCell: UITableViewCell, HomeCellConformable {
    var cardView: UIView!
    
    static var identifier: String {
        return "invitesCell"
    }
    
    static func getCellHeight(for item: ModularTableViewItem) -> CGFloat {
        guard let item = item as? HomeGroupInvitesCellItem else { return 0.0 }
        
        // cell height = (invites * inviteHeight) + header + footer + cellInset
        return (CGFloat(item.invites?.count ?? 0) * GSRGroupInviteCell.cellHeight) + (90.0 + 14.0 + 20.0)
    }
    
    var item: ModularTableViewItem! {
        didSet {
            guard let item = item as? HomeGroupInvitesCellItem else { return }
            setupCell(with: item)
        }
    }
    
    var invites: GSRGroupInvites?
    
    var delegate: ModularTableViewCellDelegate!
    
    fileprivate let safeInsetValue: CGFloat = 14
    fileprivate var safeArea: UIView!
    
    fileprivate var secondaryTitleLabel: UILabel!
    fileprivate var primaryTitleLabel: UILabel!
    
    fileprivate var dividerLine: UIView!
    fileprivate var groupInvitesTableView: UITableView!
    
    // Mark: - Init
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
extension HomeGroupInvitesCell {
    fileprivate func setupCell(with item: HomeGroupInvitesCellItem) {
        invites = item.invites
        groupInvitesTableView.reloadData()
        secondaryTitleLabel.text = "GSR GROUPS"
        primaryTitleLabel.text = "Pending Invites"
    }
}

// MARK: - UITableViewDataSource
extension HomeGroupInvitesCell: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return invites?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}

extension HomeGroupInvitesCell {
    fileprivate func prepareUI() {
    }
    
    fileprivate func prepareSafeArea() {
        
    }
    
    fileprivate func prepareTitleLabels() {
        
    }
    
    fileprivate func prepareDividerLine() {
        
    }
    
    fileprivate func prepareTableView() {
        
    }
}

extension HomeGroupInvitesCell: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return GSRGroupInviteCell.cellHeight
    }
}

extension HomeGroupInvitesCell {
    
    fileprivate func getSafeAreaView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    fileprivate func getSecondaryLabel() -> UILabel {
        let label = UILabel()
        label.font = .secondaryTitleFont
        label.textColor = .labelSecondary
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    fileprivate func getPrimaryLabel() -> UILabel {
        let label = UILabel()
        label.font = .primaryTitleFont
        label.textColor = .labelPrimary
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    fileprivate func getDividerLine() -> UIView {
        let view = UIView()
        view.backgroundColor = .grey5
        view.layer.cornerRadius = 2.0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    fileprivate func getInvitesTableView() -> UITableView {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.register(GSRGroupInviteCell.self, forCellReuseIdentifier: GSRGroupInviteCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }
}
