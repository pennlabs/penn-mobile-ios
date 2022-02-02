//
//  SupportCell.swift
//  PennMobile
//
//  Created by Josh Doman on 8/12/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import UIKit

class ContactCell: UITableViewCell {
    
    var contact: SupportItem! {
        didSet {
            contactNameLabel.text = contact.name
            textLabel?.text = contact.name
            setDetailTextLabel()
        }
    }
    
    var isExpanded: Bool = false {
        didSet {
            setDetailTextLabel()
        }
    }
    
    func setDetailTextLabel() {
        if isExpanded, let phoneNumber = contact?.phone {
            if let description = self.contact?.descriptionText {
                self.detailTextLabel?.text = String(format: "%@\n%@", arguments: [phoneNumber, description])
            } else {
                self.detailTextLabel?.text = phoneNumber
            }
        } else {
            detailTextLabel?.text = nil
        }
    }
    
    private lazy var phoneButton: UIButton = {
        let phoneImage = UIImage(named: "phone.png")
        let phoneButton = UIButton(type: .custom)
        phoneButton.translatesAutoresizingMaskIntoConstraints = false
        phoneButton.setImage(phoneImage, for: .normal)
        phoneButton.addTarget(self, action: #selector(handleCall(_:)), for: .touchUpInside)
        phoneButton.isUserInteractionEnabled = true
        return phoneButton
    }()
    
    private let contactNameLabel: UILabel = {
        let contactLabel = UILabel()
        contactLabel.font = UIFont(name: "HelveticaNeue", size: 18)
        contactLabel.text = "Penn Walk"
        contactLabel.translatesAutoresizingMaskIntoConstraints = false
        return contactLabel
    }()
    
    weak var delegate: ContactCellDelegate?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.frame = CGRect(x: 64, y: textLabel!.frame.origin.y, width: textLabel!.frame.width, height: textLabel!.frame.height)
        detailTextLabel?.frame = CGRect(x: 64, y: detailTextLabel!.frame.origin.y, width: contentView.bounds.width - 64 - 20, height: detailTextLabel!.frame.height)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        self.detailTextLabel?.numberOfLines = 5
        
        let fakeButton = UIButton()
        fakeButton.isUserInteractionEnabled = true
        fakeButton.addTarget(self, action: #selector(handleCall(_:)), for: .touchUpInside)
        
        addSubview(fakeButton)
        addSubview(phoneButton)
        
        _ = fakeButton.anchor(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 64, heightConstant: 0)
        
        _ = phoneButton.anchor(nil, left: leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 16, bottomConstant: 0, rightConstant: 0, widthConstant: 30, heightConstant: 30)
        phoneButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    @objc internal func handleCall(_ sender: UIButton) {
        if let phoneNumber = contact.phoneFiltered {
            delegate?.call(number: phoneNumber)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
