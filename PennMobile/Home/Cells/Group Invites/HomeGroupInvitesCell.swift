//
//  HomeGroupInvitesCell.swift
//  PennMobile
//
//  Created by Daniel Salib on 2/7/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import Foundation

protocol GSRInviteSelectable {
    func handleInviteSelected(_ invite: GSRGroupInvite, _ accept: Bool)
}

final class HomeGroupInvitesCell: UITableViewCell, HomeCellConformable {
    
    static var identifier: String {
        return "invitesCell"
    }
    
    static func getCellHeight(for item: ModularTableViewItem) -> CGFloat {
        guard let item = item as? HomeGroupInvitesCellItem else { return 0.0 }
        return (CGFloat(item.invites.count) * GSRGroupInviteCell.cellHeight) + HomeCellHeader.height + (Padding.pad * 3)
    }
    
    var item: ModularTableViewItem! {
        didSet {
            guard let item = item as? HomeGroupInvitesCellItem else { return }
            setupCell(with: item)
        }
    }
    
    var invites: GSRGroupInvites!
    var delegate: ModularTableViewCellDelegate!
    
    // MARK: - UI Elements
    var cardView: UIView! = UIView()
    fileprivate var safeArea: HomeCellSafeArea = HomeCellSafeArea()
    fileprivate var header: HomeCellHeader = HomeCellHeader()
    fileprivate var groupInvitesTableView: UITableView!
    
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
extension HomeGroupInvitesCell {
    fileprivate func setupCell(with item: HomeGroupInvitesCellItem) {
        invites = item.invites
        groupInvitesTableView.reloadData()
        header.secondaryTitleLabel.text = "GSR GROUPS"
        header.primaryTitleLabel.text = "Pending Invites"
    }
}

// MARK: - UITableViewDataSource
extension HomeGroupInvitesCell: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return invites?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GSRGroupInviteCell.identifier, for: indexPath) as! GSRGroupInviteCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        let invite = invites[indexPath.row]
        cell.invite = invite
        cell.delegate = self
        return cell
    }
}

extension HomeGroupInvitesCell: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return GSRGroupInviteCell.cellHeight
    }
}

extension HomeGroupInvitesCell: GSRGroupInviteCellDelegate {
    func acceptInvite(invite: GSRGroupInvite) {
        guard let delegate = delegate as? GSRInviteSelectable else { return }
        delegate.handleInviteSelected(invite, true)
    }
    
    func declineInvite(invite: GSRGroupInvite) {
        guard let delegate = delegate as? GSRInviteSelectable else { return }
        delegate.handleInviteSelected(invite, false)
    }
}

// MARK: - Initialize & Layout UI Elements
extension HomeGroupInvitesCell {
    fileprivate func prepareUI() {
        prepareSafeArea()
        prepareHeader()
        prepareTableView()
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
        
        groupInvitesTableView = getInvitesTableView()
        cardView.addSubview(groupInvitesTableView)
        
        groupInvitesTableView.snp.makeConstraints { (make) in
            make.leading.equalTo(cardView)
            make.top.equalTo(header.snp.bottom).offset(pad)
            make.trailing.equalTo(cardView)
            make.bottom.equalTo(cardView).offset(-pad)
        }
    }
}

// MARK: - Define UI Elements
extension HomeGroupInvitesCell {
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
