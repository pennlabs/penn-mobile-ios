//
//  WeatherCell.swift
//  PennMobile
//
//  Created by Victor Chien on 2/4/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import UIKit

class WeatherCell: UITableViewCell {
    
    var condition = UILabel()
    var temperature = UILabel()
    var comment = UILabel()
    var starter = UILabel()
    var weatherImage = UIImageView()
    var constraint: PercentageContrain!
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        starter.text = "Today is"
        let screenSize: CGRect = UIScreen.main.bounds
        constraint = PercentageContrain(w: screenSize.width, h: 350)
        
        
        //comment
        comment.textAlignment = NSTextAlignment.center
        comment.font = UIFont(name: comment.font.fontName, size: 15)
        comment.frame = CGRect(x: 30, y: 20, width: self.frame.width, height: 20);
        self.addSubview(comment)
        
        //temperature
        temperature.font = UIFont(name: "Avenir-Book", size: 60)
        temperature.frame = CGRect(x: constraint.getConstraintX(percent: 52.1), y: constraint.getConstraintY(percent: 60), width: 80, height: 80);
        self.addSubview(temperature)
        
        //starter
        starter.font = UIFont(name: "Avenir-Book", size: 20)
        starter.frame = CGRect(x: constraint.getConstraintX(percent: 31.3), y: constraint.getConstraintY(percent: 56), width: 80, height: 80);
        self.addSubview(starter)
        
        //condition
        condition.font = UIFont(name: "Avenir-Book", size: 20)
        condition.frame = CGRect(x: constraint.getConstraintX(percent: 31.3), y: constraint.getConstraintY(percent: 62), width: 80, height: 80);
        self.addSubview(condition)
        
        //weatherImage
        weatherImage.frame = CGRect(x: constraint.getConstraintX(percent: 31.7), y: constraint.getConstraintY(percent: 20), width: constraint.getConstraintX(percent: 38.4), height: constraint.getConstraintX(percent: 38.4))
        self.addSubview(weatherImage)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}


