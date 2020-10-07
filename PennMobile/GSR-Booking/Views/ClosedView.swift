//
//  ClosedView.swift
//  PennMobile
//
//  Created by Raunaq Singh on 10/6/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import UIKit

class ClosedView: UIView {
    
    private let label: UILabel = {
        let l = UILabel()
        l.font = UIFont(name: "HelveticaNeue", size: 22)
        l.text = "This GSR is closed until further notice."
        l.textColor = UIColor.labelSecondary
        l.textAlignment = .center
        l.numberOfLines = 0
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let closedImage: UIImageView = {
        let imgView = UIImageView(image: UIImage(named: "EmptyStateGSR")!)
        imgView.contentMode = .scaleAspectFit
        imgView.translatesAutoresizingMaskIntoConstraints = false
        return imgView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        
        addSubview(closedImage)
        closedImage.widthAnchor.constraint(equalToConstant: 200).isActive = true
        closedImage.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -100).isActive = true
        closedImage.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        addSubview(label)
        
        label.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 75).isActive = true
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        label.widthAnchor.constraint(equalTo: widthAnchor, constant: -10).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
