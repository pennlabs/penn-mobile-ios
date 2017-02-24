//
//  AgendaCell.swift
//  PennMobile
//
//  Created by Victor Chien on 2/4/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import UIKit

class AgendaCell: UITableViewCell {
    
    var mainAnnouncement = UILabel()
    
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let screenSize: CGRect = UIScreen.main.bounds
        //constraint = PercentageContrain(w: screenSize.width, h: 350)
        
        
        //comment
        //comment.textAlignment = NSTextAlignment.center
//        comment.font = UIFont(name: comment.font.fontName, size: 15)
//        comment.frame = CGRect(x: 30, y: 20, width: self.frame.width, height: 20);
//        self.addSubview(comment)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
