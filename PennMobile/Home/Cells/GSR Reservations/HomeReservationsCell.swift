//
//  HomeReservationsCell.swift
//  PennMobile
//
//  Created by Marta García Ferreiro on 3/17/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import UIKit

final class HomeReservationsCell: UITableViewCell, HomeCellConformable {
    
    static var identifier: String = "reservationsCell"
    var delegate: ModularTableViewCellDelegate!
    
    var item: ModularTableViewItem! {
        didSet {
            guard let item = item as? HomeReservationsCellItem else { return }
            setupCell(with: item)
        }
    }
    
    var reservations: [GSRReservation]?
    
    // MARK: - UI Elements
    var cardView: UIView! = UIView()
    fileprivate var safeArea: HomeCellSafeArea = HomeCellSafeArea()
    fileprivate var header: HomeCellHeader = HomeCellHeader()
    fileprivate var reservationTableView: UITableView!
    
    static func getCellHeight(for item: ModularTableViewItem) -> CGFloat {
        guard let item = item as? HomeReservationsCellItem else { return 0.0 }
        return (CGFloat(item.reservations.count) * ReservationCell.cellHeight) + HomeCellHeader.height + (Padding.pad * 3)
    }
    
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
        header.secondaryTitleLabel.text = "GROUP STUDY ROOMS"
        header.primaryTitleLabel.text = "Reservations"
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
        reservationTableView = getReservationTableView()
        cardView.addSubview(reservationTableView)
        
        reservationTableView.snp.makeConstraints { (make) in
            make.leading.equalTo(cardView)
            make.top.equalTo(header.snp.bottom).offset(pad)
            make.trailing.equalTo(cardView)
            make.bottom.equalTo(cardView).offset(-pad/2)
        }
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
