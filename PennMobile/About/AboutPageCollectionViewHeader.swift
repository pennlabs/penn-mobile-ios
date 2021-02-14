//
//  AboutPageCollectionViewHeader.swift
//  PennMobile
//
//  Created by Marta García Ferreiro on 10/26/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import UIKit

class AboutPageCollectionViewHeader: UICollectionReusableView {
    
    let label: UILabel = {
        let label = UILabel()
        label.text = "Built By"
        label.font = UIFont.systemFont(ofSize: 26, weight: .medium)
        label.textColor = UIColor.labelPrimary
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(label)
        label.widthAnchor.constraint(equalToConstant: 200).isActive = true
        label.heightAnchor.constraint(equalToConstant: 30).isActive = true
        label.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
