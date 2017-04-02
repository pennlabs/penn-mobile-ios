//
//  WeatherCell.swift
//  PennMobile
//
//  Created by Victor Chien on 2/4/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import UIKit

struct Weather {
    let temperature: String
    let description: String
}

protocol WeatherDelegate {
    func getWeather() -> Weather
}

class WeatherCell: GenericHomeCell {
    
    private var weather: Weather {
        get {
            if let delegate = delegate {
                return delegate.getWeather()
            }
            else {
                return Weather(temperature: "_", description: "Sunny")
            }
        }
    }
    
    public var delegate: WeatherDelegate! {
        didSet {
            condition.text = weather.description
            temperatureLabel.text = weather.temperature
        }
    }
    
    private lazy var condition: UILabel = {
        let label = UILabel()
        label.text = self.weather.description
        label.font = UIFont(name: "HelveticaNeue-Light", size: 20)
        label.textAlignment = NSTextAlignment.right
        label.textColor = UIColor(r: 115, g: 115, b: 115)
        return label
    }()
    
    private lazy var temperatureLabel: UILabel = {
        let label = UILabel()
        label.text = self.weather.temperature
        label.font = UIFont(name: "HelveticaNeue-Light", size: 60)
        label.textColor = UIColor(r: 63, g: 81, b: 181)
        return label
    }()
    
    private let comment: UILabel = {
        let label = UILabel()
        label.text = "Bust out the shades"
        label.textAlignment = NSTextAlignment.center
        label.font = UIFont(name: "HelveticaNeue-Light", size: 20)
        label.textColor = UIColor(r: 115, g: 115, b: 115)
        return label
    }()
    
    private let starter: UILabel = {
        let label = UILabel()
        label.text = "Today is"
        label.textAlignment = NSTextAlignment.right
        label.font = UIFont(name: "HelveticaNeue-Light", size: 20)
        label.textColor = UIColor(r: 115, g: 115, b: 115)
        return label
    }()
    
    private let weatherImage: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named:"1d.png")
        return iv
    }()
    
    private let constraint: PercentageContrain = PercentageContrain(w: UIScreen.main.bounds.width, h: 350)
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        //comment
        comment.frame = CGRect(x: 30, y: 20, width: self.frame.width, height: 20);
        self.addSubview(comment)
        
        
        //weatherImage
        weatherImage.frame = CGRect(x: constraint.getConstraintX(percent: 31.7), y: constraint.getConstraintY(percent: 20), width: constraint.getConstraintX(percent: 38.4), height: constraint.getConstraintX(percent: 38.4))
        self.addSubview(weatherImage)
        
        self.addSubview(temperatureLabel)
        
        _ = temperatureLabel.anchor(weatherImage.bottomAnchor, left: centerXAnchor, bottom: nil, right: nil, topConstant: 20, leftConstant: 4, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        self.addSubview(starter)
        
        _ = starter.anchor(nil, left: nil, bottom: temperatureLabel.centerYAnchor, right: centerXAnchor, topConstant: 0, leftConstant: 0, bottomConstant: -2, rightConstant: 4, widthConstant: 0, heightConstant: 0)
        
        self.addSubview(condition)
        
        _ = condition.anchor(starter.bottomAnchor, left: nil, bottom: nil, right: starter.rightAnchor, topConstant: 2, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        self.addSubview(comment)
        
        _ = comment.anchor(topAnchor, left: nil, bottom: nil, right: nil, topConstant: 20, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        comment.centerXAnchor.constraint(equalTo: weatherImage.centerXAnchor).isActive = true        
    }
    
   
    //TODO: setup appropriate descriptions
    private func setupViewsForWeather(for description: String) {
        if description == "Sunny" {
            
        } else if description == "cloudy" {
            
        } else if description == "clear sky" {
            
        }
    }

}


