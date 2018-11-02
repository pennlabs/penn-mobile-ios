//
//  statusBar.swift
//  PennMobile
//
//  Created by Daniel Salib on 10/28/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import UIKit

class StatusBar: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    fileprivate var barText = UILabel()
    var height: Int = 0
    
    fileprivate var status: statusBarText
    
    
    enum statusBarText : String {
        case noInternet = "No Internet Connection"
        case apiError = "Penn servers are temporarily down.\nPlease try again later."
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self.status = .noInternet
        super.init(coder: aDecoder)
        self.backgroundColor = .redingTerminal
    }
    
    public override init(frame: CGRect) {
        self.status = .noInternet
        super.init(frame: frame)
        self.backgroundColor = .redingTerminal
    }
    
    public convenience init(text: statusBarText) {
        self.init(frame: .zero)
        self.status = text
        self.height = self.status == .noInternet ? 50 : 70
        self.backgroundColor = .redingTerminal
        if (text == .noInternet) {
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
