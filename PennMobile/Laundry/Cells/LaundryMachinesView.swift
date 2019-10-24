//
//  LaundryMachinesView.swift
//  PennMobile
//
//  Created by Josh Doman on 3/2/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

protocol LaundryMachinesViewDataSource {
    func getMachines(_ machinesView: LaundryMachinesView) -> [LaundryMachine]
}

protocol LaundryMachineViewDelegate: LaundryMachineCellTappable {}

final class LaundryMachinesView: UIView {
    static let height: CGFloat = 90
    
    let isWasher: Bool
    var dataSource: LaundryMachinesViewDataSource!
    var delegate: LaundryMachineViewDelegate!
    
    fileprivate var typeLabel: UILabel!
    fileprivate var numberLabel: UILabel!
    
    fileprivate var collectionView: UICollectionView!
    
    init(frame: CGRect, isWasher: Bool) {
        self.isWasher = isWasher
        super.init(frame: frame)
        prepareUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup
extension LaundryMachinesView {
    fileprivate func prepareUI() {
        prepareLabels()
        prepareCollectionView()
    }
    
    // MARK: Labels
    private func prepareLabels() {
        typeLabel = getTypeLabel()
        numberLabel = getNumMachinesLabel()
        
        addSubview(typeLabel)
        addSubview(numberLabel)
        
        typeLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14).isActive = true
        typeLabel.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        
        numberLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14).isActive = true
        numberLabel.centerYAnchor.constraint(equalTo: typeLabel.centerYAnchor, constant: 0).isActive = true
    }
    
    private func getTypeLabel() -> UILabel {
        let label = getRoomLabel()
        label.text = isWasher ? "Washers" : "Dryers"
        return label
    }
    
    private func getNumMachinesLabel() -> UILabel {
        let label = UILabel()
        label.font = .primaryInformationFont
        label.textColor = .secondaryInformationGrey
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private func getRoomLabel() -> UILabel {
        let label = UILabel()
        label.font = .secondaryInformationFont
        label.textColor = .labelPrimary
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    // MARK: Collection View
    private func prepareCollectionView() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.register(LaundryMachineCell.self, forCellWithReuseIdentifier: LaundryMachineCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.clear
        collectionView.showsHorizontalScrollIndicator = false
        
        addSubview(collectionView)
        _ = collectionView.anchor(typeLabel.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 4, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension LaundryMachinesView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let machines = dataSource.getMachines(self)
        numberLabel.text = "\(machines.numberOpenMachines()) of \(machines.count) open"
        return machines.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = LaundryMachineCell.identifier
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! LaundryMachineCell
        let machineArray = dataSource.getMachines(self)
        cell.machine = machineArray[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 50, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 20, bottom: 5, right: 5)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let machineArray = dataSource.getMachines(self)
        let machine = machineArray[indexPath.row]
        if machine.status == .running && machine.timeRemaining > 0 {
            delegate.handleMachineCellTapped(for: machine) {
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }
    }
}

// MARK: - Reload
extension LaundryMachinesView {
    func reloadData() {
        collectionView.reloadData()
    }
}
