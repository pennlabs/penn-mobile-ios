//
//  AgendaCell.swift
//  PennMobile
//
//  Created by Victor Chien on 2/4/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import UIKit

protocol AgendaDelegate {
    func getAnnouncement() -> String?
    func getEvents() -> [Event]
    func showAnnouncement() -> Bool
}

class AgendaCell: GenericHomeCell, ScheduleTableDelegate {
    
    private var mainAnnouncement = UILabel()
    
    private var events: [Event] {
        get {
            //return sortEvents(for: delegate.getEvents())
            return Event.approvableEvents(for: delegate.getEvents())
        }
    }
    
    private static let HeaderHeight: CGFloat = 50
    private static let AnnouncementHeight: CGFloat = 35
//    private lazy var AnnouncementHeight: CGFloat = {
//        return AgendaCell.calculateAnnouncementHeight(announcement: self.announcement)
//    }()

    private let emptyMessage = "Sorry! No events scheduled today."
    private static let HeaderFont = UIFont(name: "HelveticaNeue-Light", size: 20)
    
    var announcement: String? {
        get {
            return delegate.getAnnouncement()
        }
    }
    
    private var showAnnouncement: Bool {
        get {
            return delegate.showAnnouncement()
        }
    }
    
    public var delegate: AgendaDelegate! {
        didSet {
            announcementLabel.text = announcement
            setupCell()
        }
    }
    
    private let header: UILabel = {
        let label = UILabel()
        label.font = AgendaCell.HeaderFont
        label.text = "Your Monday schedule looks like"
        label.textColor = UIColor(r: 115, g: 115, b: 115)
        label.backgroundColor = .white
        return label
    }()
    
    private lazy var body: ScheduleTable = {
        let st = ScheduleTable()
        st.delegate = self
        return st
    }()
    
    private lazy var announcementLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor(r: 63, g: 81, b: 181)
        label.textColor = .white
        label.font = UIFont(name: "HelveticaNeue", size: 15)
        label.text = self.announcement
        label.textAlignment = .center
        return label
    }()
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)        
    }
    
    private func setupCell() {
        //remove all subviews
        let views = subviews
        
        for view in views {
            view.removeFromSuperview()
        }
        
        addSubview(header)
        addSubview(body)
        
        _ = header.anchor(topAnchor, left: leftAnchor, bottom: topAnchor, right: rightAnchor, topConstant: 0, leftConstant: 16, bottomConstant: -AgendaCell.HeaderHeight, rightConstant: 0, widthConstant: 0, heightConstant: AgendaCell.HeaderHeight)
        
        var tempTopAnchor = header.bottomAnchor
        
        if showAnnouncement {
            addSubview(announcementLabel)
            
            _ = announcementLabel.anchor(tempTopAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: AgendaCell.AnnouncementHeight)
            
            tempTopAnchor = announcementLabel.bottomAnchor
        }
        
        _ = body.anchorToTop(tempTopAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor)
        
    }
    
    internal func getEvents() -> [Event] {
        return events
    }
    
    internal func getEmptyMessage() -> String {
        return emptyMessage
    }
    
    public static func calculateHeightForEvents(for events: [Event], announcement: String?) -> CGFloat {
        var cellHeight = ScheduleTable.calculateHeightForEvents(for: events) + HeaderHeight + AnnouncementHeight
        
        //cellHeight += calculateAnnouncementHeight(for: announcement)
        
        return cellHeight
    }
    
    public override func reloadData() {
        body.reloadData()
    }
    
    public static func calculateAnnouncementHeight(for announcement: String?) -> CGFloat {
        if let announcement = announcement {
            let maxWidth: CGFloat = UIScreen.main.bounds.width
            
            let rect: CGRect = announcement.boundingRect(with: CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude), options: ([.usesLineFragmentOrigin, .usesFontLeading]), attributes: [NSFontAttributeName: AgendaCell.HeaderFont!], context: nil)
            let textHeight: CGFloat = rect.size.height
            return textHeight
        }
        return 0
    }
}
