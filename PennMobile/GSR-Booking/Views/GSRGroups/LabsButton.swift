//
//  LabsButton.swift
//  PennMobile
//
//  Created by Daniel Salib on 11/22/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import UIKit

class LabsButton: UIButton {

    required init(text: String) {
        super.init(frame: .zero)
        self.backgroundColor = UIColor(red: 216, green: 216, blue: 216)
        self.setTitle("Create Group", for: .normal)
        self.setTitleColor(UIColor.white, for: .normal)
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
