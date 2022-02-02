//
//  GSRTimeCell.swift
//  PennMobile
//
//  Created by Josh Doman on 2/3/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation
import UIKit

class GSRTimeCell: UICollectionViewCell {

    static let identifier = "timeCell"

    var timeSlot: GSRTimeSlot! {
        didSet {
            startLabel.text = format(date: timeSlot.startTime)
            endLabel.text = format(date: timeSlot.endTime)
        }
    }

    override var isSelected: Bool {
        didSet {
            if !timeSlot.isAvailable {
                backgroundColor = UIColor.labelSecondary
            } else {
                UIView.animate(withDuration: 0.15) {
                    if self.isSelected {
                        self.backgroundColor = .baseYellow
                    } else {
                        self.backgroundColor = .baseGreen
                    }
                }
            }
        }
    }

    private let startLabel = UILabel()
    private let endLabel = UILabel()

    private let toLabel: UILabel = {
        let label = UILabel()
        label.text = "to"
        label.font = UIFont.secondaryInformationFont
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    private func setupView() {
        addSubview(startLabel)
        addSubview(endLabel)
        addSubview(toLabel)

        toLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        toLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true

        startLabel.font = UIFont.primaryInformationFont
        endLabel.font = UIFont.primaryInformationFont

        _ = startLabel.anchor(topAnchor, left: nil, bottom: nil, right: nil, topConstant: 8, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        startLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true

        _ = endLabel.anchor(nil, left: nil, bottom: bottomAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 8, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        endLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }

    private func format(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mma"
        formatter.amSymbol = "am"
        formatter.pmSymbol = "pm"
        return formatter.string(from: date)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
