//
//  EventsTableViewCell.swift
//  PennMobile
//
//  Created by Samantha Su on 10/1/21.
//  Copyright © 2021 PennLabs. All rights reserved.
//

import UIKit
import Kingfisher
import SwiftSoup

class PennEventsTableViewCell: UITableViewCell {

    lazy var imageExistsConstraint = eventImageView.widthAnchor.constraint(equalToConstant: 120)
    lazy var imageMissingConstraint = eventImageView.widthAnchor.constraint(equalToConstant: 0)
    var isExpanded = false

    var pennEvent: PennEvents? {
        didSet {
            guard let event = pennEvent else {return}
            if event.media_image == "" {
                imageExistsConstraint.isActive = false
                imageMissingConstraint.isActive = true
            } else {
                let imageString = "https://penntoday.upenn.edu" + (event.media_image.slice(from: "<img src=\"", to: "\n") ?? "").trimmingCharacters(in: .whitespaces)
                eventImageView.kf.setImage(with: URL(string: imageString))
                imageExistsConstraint.isActive = true
                imageMissingConstraint.isActive = false
            }
            titleLabel.text = event.shortdate + ": " + event.title
            if let doc: Document = try? SwiftSoup.parse(event.body), let text = try? doc.text() {
                bodyLabel.text = text
            }
        }
    }

    // MARK: - Views

    let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true // this will make sure its children do not go out of the boundary
        return view
    }()

    let eventImageView: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFill // image will never be strecthed vertially or horizontally
        img.translatesAutoresizingMaskIntoConstraints = false // enable autolayout
        img.layer.cornerRadius = 7
        img.clipsToBounds = true
        return img
    }()

    let titleLabel: UILabel = {
        var view = UILabel()
        view.backgroundColor = .clear
        view.numberOfLines = 0

        view.textColor = UIColor.label
        view.font = UIFont(name: "SFProText-Regular", size: 30)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let bodyLabel: UILabel = {
        var view = UILabel()
        view.backgroundColor = .clear
        view.font = UIFont(name: "Helvetica", size: 12)
        view.textColor = UIColor.secondaryLabel
        view.numberOfLines = 3
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        containerView.addSubview(titleLabel)
        containerView.addSubview(bodyLabel)
        self.contentView.addSubview(containerView)
        self.contentView.addSubview(eventImageView)

        containerView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 10).isActive = true
        containerView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -10).isActive = true

        eventImageView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
        eventImageView.leadingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 10).isActive = true
        eventImageView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -10).isActive = true
        eventImageView.heightAnchor.constraint(equalToConstant: 80).isActive = true

        titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 5).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10).isActive = true

        bodyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 0).isActive = true
        bodyLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -5).isActive = true
        bodyLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10).isActive = true
        bodyLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
