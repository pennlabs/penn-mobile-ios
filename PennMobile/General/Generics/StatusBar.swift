//
//  statusBar.swift
//  PennMobile
//
//  Created by Daniel Salib on 10/28/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import UIKit

class StatusBar: UIView {

    fileprivate var barText = UILabel()
    var height: Int = 0

    fileprivate var status: StatusBarText

    enum StatusBarText: String {
        case noInternet = "No Internet Connection"
        case apiError = "Unable to connect to the API.\nPlease refresh and try again."
        case laundryDown = "Penn's laundry servers are currently not updating.\nWe hope this will be fixed shortly."
    }

    public required init?(coder aDecoder: NSCoder) {
        self.status = .noInternet
        super.init(coder: aDecoder)
        self.backgroundColor = .baseRed
    }

    public override init(frame: CGRect) {
        self.status = .noInternet
        super.init(frame: frame)
        self.backgroundColor = .baseRed
    }

    public convenience init(text: StatusBarText) {
        self.init(frame: .zero)
        self.status = text
        self.height = self.status == .noInternet ? 50 : 70
        self.backgroundColor = .baseRed
        if text == .noInternet {
            self.heightAnchor.constraint(equalToConstant: 50).isActive = true
        } else {
            self.heightAnchor.constraint(equalToConstant: 70).isActive = true
        }
        layoutSubviews()
    }

    override func layoutSubviews() {
        self.addSubview(barText)
        barText.text = status.rawValue
        barText.numberOfLines = self.status == .noInternet ? 1 : 2
        barText.translatesAutoresizingMaskIntoConstraints = false
        barText.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        barText.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        barText.textAlignment = .center
        barText.textColor = .white
        barText.font = .primaryInformationFont
    }
}
