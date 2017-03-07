//
//  ReservationCell.swift
//  PennMobile
//
//  Created by Victor Chien on 2/4/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import UIKit

class ReservationCell: UITableViewCell {

    lazy var reserveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Reserve", for: .normal)
        button.backgroundColor = UIColor.red
        //button.addTarget(self, action: #selector(reserve), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }()

    
    func createButtons() {
        for i in 0...6 {
            let reserveButton = self.reserveButton
            
            //must go before actual contraining of button
            self.addSubview(reserveButton)
            
            //reserveButton.widthAnchor.constraint(equalToConstant: constraint.getConstraintY(percent: 7.4)).isActive = true
            
            
//            reserveButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
//            
//            reserveButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
//            
//            reserveButton.topAnchor.constraint(equalTo: topAnchor, constant: CGFloat(14 + Double(i) * 5.6))
//            
//            reserveButton.leftAnchor.constraint(equalTo: leftAnchor, constant: constraint.getConstraintX(percent: 29.9))
        }
    }
    
    
    var constraint: PercentageContrain!
    

    
    func reserve() {
        
    }


    //use buttons to go to next set of six room selections. Don't do nested table or scroll view
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    
        
        createButtons()
        
    }
}
