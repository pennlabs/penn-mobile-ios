//
//  HomeReservationsCell.swift
//  PennMobile
//
//  Created by Marta García Ferreiro on 3/17/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import UIKit

final class HomeReservationsCell: UITableViewCell, HomeCellConformable {    
    var cardView: UIView! = UIView()
    
    var delegate: ModularTableViewCellDelegate!
    
    static var identifier: String = "reservationsCell"
    
    var item: ModularTableViewItem! {
        didSet {
            guard let item = item as? HomeReservationsCellItem else { return }
            setupCell(with: item)
        }
    }
    
    static func getCellHeight(for item: ModularTableViewItem) -> CGFloat {
        guard let item = item as? HomeReservationsCellItem else { return 0.0 }
        return (CGFloat(item.reservations.count) * ReservationCell.cellHeight) + (90.0 + 20.0)// + 20.0 + 7.0)
    }
    
    var reservations: [GSRReservation]?
    
    // Custom UI elements (some should be abstracted)
    fileprivate let safeInsetValue: CGFloat = 14
    fileprivate var safeArea: UIView!
    
    fileprivate var secondaryTitleLabel: UILabel!
    fileprivate var primaryTitleLabel: UILabel!
    
    fileprivate var dividerLine: UIView!
    fileprivate var reservationTableView: UITableView!
    
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
extension HomeReservationsCell {
    fileprivate func setupCell(with item: HomeReservationsCellItem) {
        reservations = item.reservations
        reservationTableView.reloadData()
        secondaryTitleLabel.text = "GSR RESERVATIONS"
        primaryTitleLabel.text = "Upcoming Reservations"
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension HomeReservationsCell: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reservations?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReservationCell.identifier, for: indexPath) as! ReservationCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.isHomePageCell = true
        let reservation = reservations![indexPath.row]
        cell.reservation = reservation
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ReservationCell.cellHeight
    }
}

// MARK: - Initialize & Layout UI Elements
extension HomeReservationsCell {
    fileprivate func prepareUI() {
        prepareSafeArea()
        prepareTitleLabels()
        prepareDividerLine()
        prepareTableView()
    }
    
    private func prepareSafeArea() {
        safeArea = getSafeAreaView()
        
        cardView.addSubview(safeArea)
        
        safeArea.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: safeInsetValue).isActive = true
        safeArea.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -safeInsetValue).isActive = true
        safeArea.topAnchor.constraint(equalTo: cardView.topAnchor, constant: safeInsetValue).isActive = true
        safeArea.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -safeInsetValue).isActive = true
    }
    
    // MARK: Labels
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
    
    // MARK: Divider Line
    fileprivate func prepareDividerLine() {
        dividerLine = getDividerLine()
        
        cardView.addSubview(dividerLine)
        
        dividerLine.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor).isActive = true
        dividerLine.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor).isActive = true
        dividerLine.topAnchor.constraint(equalTo: primaryTitleLabel.bottomAnchor, constant: 14).isActive = true
        dividerLine.heightAnchor.constraint(equalToConstant: 2).isActive = true
    }
    
    // MARK: TableView
    fileprivate func prepareTableView() {
        reservationTableView = getReservationTableView()
        
        cardView.addSubview(reservationTableView)
        
        reservationTableView.leftAnchor.constraint(equalTo: safeArea.leftAnchor).isActive = true
        reservationTableView.topAnchor.constraint(equalTo: dividerLine.bottomAnchor).isActive = true
        reservationTableView.rightAnchor.constraint(equalTo: cardView.rightAnchor).isActive = true
        reservationTableView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor).isActive = true
    }
}

// MARK: - UITableViewDelegate
extension HomeReservationsCell: ReservationCellDelegate {
    func deleteReservation(_ reservation: GSRReservation) {
        guard let delegate = delegate as? ReservationCellDelegate else { return }
        delegate.deleteReservation(reservation)
    }
}

// MARK: - Define UI Elements
extension HomeReservationsCell {
    
    fileprivate func getSafeAreaView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    fileprivate func getSecondaryLabel() -> UILabel {
        let label = UILabel()
        label.font = .secondaryTitleFont
        label.textColor = .secondaryTitleGrey
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    fileprivate func getPrimaryLabel() -> UILabel {
        let label = UILabel()
        label.font = .primaryTitleFont
        label.textColor = .primaryTitleGrey
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    fileprivate func getDividerLine() -> UIView {
        let view = UIView()
        view.backgroundColor = .allbirdsGrey
        view.layer.cornerRadius = 2.0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    fileprivate func getReservationTableView() -> UITableView {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.register(ReservationCell.self, forCellReuseIdentifier: ReservationCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }
}
