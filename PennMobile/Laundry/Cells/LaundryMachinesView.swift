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

final class LaundryMachinesView: UIView {
    static let height: CGFloat = 90
    
    let isWasher: Bool
    var dataSource: LaundryMachinesViewDataSource!
    
    fileprivate var typeLabel: UILabel!
    fileprivate var numberLabel: UILabel!
    
    fileprivate var machineCollectionView: UICollectionView!
    
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
        
        typeLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        typeLabel.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        
        numberLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
        numberLabel.centerYAnchor.constraint(equalTo: typeLabel.centerYAnchor, constant: 0).isActive = true
    }
    
    private func getTypeLabel() -> UILabel {
        let label = getRoomLabel(fontSize: 14)
        label.text = isWasher ? "Washers" : "Dryers"
        return label
    }
    
    private func getNumMachinesLabel() -> UILabel {
        let label = getRoomLabel(fontSize: 16)
        label.text = "0 of 9 open"
        label.textColor = .warmGrey
        label.textAlignment = .right
        return label
    }
    
    private func getRoomLabel(fontSize: CGFloat) -> UILabel {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue", size: fontSize)
        label.textColor = .black
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    // MARK: Collection View
    private func prepareCollectionView() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.register(LaundryMachineCell.self, forCellWithReuseIdentifier: LaundryMachineCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.clear
        collectionView.showsHorizontalScrollIndicator = false
        machineCollectionView = collectionView
        
        addSubview(machineCollectionView)
        _ = machineCollectionView.anchor(typeLabel.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 4, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
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
        return CGSize(width: 55, height: 55)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 20, bottom: 5, right: 5)
    }
}

// MARK: - Reload
extension LaundryMachinesView {
    func reloadData() {
        machineCollectionView.reloadData()
    }
}
