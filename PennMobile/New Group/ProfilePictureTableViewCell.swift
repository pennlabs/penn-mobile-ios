//
//  ProfilePictureTableViewCell.swift
//  
//
//  Created by Andrew Antenberg on 10/4/21.
//

import UIKit

class ProfilePictureTableViewCell: UITableViewCell {
    static let identifier = "profilePictureCell"
    
    var account: Account! {
        didSet {
            guard let firstName = account.first, let lastName = account.last else {
                return
            }
            nameLabel.text = "\(firstName) \(lastName)"
            tempLabel.text = "\(firstName.first!)\(lastName.first!)"
            guard let imageUrl = account.imageUrl else {
                return
            }
            profilePic.kf.setImage(with: URL(string: imageUrl))
        }
    }
    
    var profilePicImage: UIImage? {
        willSet {
            profilePic.image = newValue
        }
    }
    
    var profilePic = UIImageView()
    
    fileprivate var imageSize: Double = 60
    fileprivate var nameLabel = UILabel()
    fileprivate var placeholder = UIView()
    
    var tempLabel = UILabel()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.preparePlaceholder()
        self.prepareImage()
        self.prepareLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func preparePlaceholder() {
        placeholder.backgroundColor = .baseBlue
        contentView.addSubview(placeholder)
        placeholder.translatesAutoresizingMaskIntoConstraints = false
        placeholder.layer.cornerRadius = imageSize / 2
        placeholder.widthAnchor.constraint(equalToConstant: imageSize).isActive = true
        placeholder.heightAnchor.constraint(equalToConstant: imageSize).isActive = true
        placeholder.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: pad).isActive = true
        placeholder.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: pad).isActive = true
        placeholder.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -pad).isActive = true
        placeholder.addSubview(tempLabel)
        tempLabel.font = UIFont.systemFont(ofSize: 28.0)
        tempLabel.textColor = .white
        tempLabel.translatesAutoresizingMaskIntoConstraints = false
        tempLabel.centerYAnchor.constraint(equalTo: placeholder.centerYAnchor).isActive = true
        tempLabel.centerXAnchor.constraint(equalTo: placeholder.centerXAnchor).isActive = true
    }
    func prepareImage() {
        contentView.addSubview(profilePic)
        profilePic.translatesAutoresizingMaskIntoConstraints = false
        profilePic.layer.cornerRadius = imageSize / 2
        profilePic.widthAnchor.constraint(equalToConstant: imageSize).isActive = true
        profilePic.heightAnchor.constraint(equalToConstant: imageSize).isActive = true
        profilePic.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: pad).isActive = true
        profilePic.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: pad).isActive = true
        profilePic.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -pad).isActive = true
        profilePic.backgroundColor = .clear
        profilePic.contentMode = .scaleAspectFill
        profilePic.clipsToBounds = true
    }
    
    func prepareLabel() {
        nameLabel.font = UIFont.systemFont(ofSize: 20.0)
        contentView.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.leadingAnchor.constraint(equalTo: profilePic.trailingAnchor, constant: pad).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
        
    }

}
