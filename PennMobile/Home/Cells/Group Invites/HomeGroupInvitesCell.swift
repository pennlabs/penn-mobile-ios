//
//  HomeGroupInvitesCell.swift
//  PennMobile
//
//  Created by Daniel Salib on 2/7/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import Foundation

protocol GSRInviteSelectable {
    func handleInviteSelected(_ invite: GSRGroupInvite)
}

final class HomeGroupInvitesCell: UITableViewCell, HomeCellConformable {
    var cardView: UIView! = UIView()
    
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
    
    //var invitesDelegate: HomeViewController
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: GSRGroupInviteCell.identifier, for: indexPath) as! GSRGroupInviteCell
        let invite = invites![indexPath.row]
        cell.invite = invite
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(invites![indexPath.row])
        guard let delegate = delegate as? GSRInviteSelectable else { return }
        delegate.handleInviteSelected(invites![indexPath.row])
    }
}

extension HomeGroupInvitesCell {
    fileprivate func prepareUI() {
        prepareSafeArea()
        prepareTitleLabels()
        prepareDividerLine()
        prepareTableView()
    }
    
    fileprivate func prepareSafeArea() {
        safeArea = getSafeAreaView()
        
        cardView.addSubview(safeArea)
        
        safeArea.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: safeInsetValue).isActive = true
        safeArea.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -safeInsetValue).isActive = true
        safeArea.topAnchor.constraint(equalTo: cardView.topAnchor, constant: safeInsetValue).isActive = true
        safeArea.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -safeInsetValue).isActive = true
    }
    
    fileprivate func prepareTitleLabels() {
        secondaryTitleLabel = getSecondaryLabel()
        primaryTitleLabel = getPrimaryLabel()
        
        cardView.addSubview(secondaryTitleLabel)
        cardView.addSubview(primaryTitleLabel)
        
        secondaryTitleLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor).isActive = true
        secondaryTitleLabel.topAnchor.constraint(equalTo: safeArea.topAnchor).isActive = true
        
        primaryTitleLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor).isActive = true
        primaryTitleLabel.topAnchor.constraint(equalTo: secondaryTitleLabel.bottomAnchor, constant: 10).isActive = true
    }
    
    fileprivate func prepareDividerLine() {
        dividerLine = getDividerLine()
        
        cardView.addSubview(dividerLine)
        
        dividerLine.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor).isActive = true
        dividerLine.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor).isActive = true
        dividerLine.topAnchor.constraint(equalTo: primaryTitleLabel.bottomAnchor, constant: 14).isActive = true
        dividerLine.heightAnchor.constraint(equalToConstant: 2).isActive = true
    }
    
    fileprivate func prepareTableView() {
        groupInvitesTableView = getInvitesTableView()
        
        cardView.addSubview(groupInvitesTableView)
        
        groupInvitesTableView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor).isActive = true
        groupInvitesTableView.topAnchor.constraint(equalTo: dividerLine.bottomAnchor,
                                                    constant: safeInsetValue / 2).isActive = true
        groupInvitesTableView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor).isActive = true
        groupInvitesTableView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: safeInsetValue / 2).isActive = true
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
