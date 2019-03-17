//
//  ScheduleTableCell.swift
//  PennMobile
//
//  Created by Josh Doman on 3/16/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

class ScheduleEventCell: UICollectionViewCell {
    
    public var event: Event! {
        didSet {
            var str = event.name
            if let location = event.location {
                str += "\n\(location)"
            }
            
            let attributedString = NSMutableAttributedString(string: str)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 2 // Whatever line spacing you want in points
            attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
            label.attributedText = attributedString
            
            imageView.isHidden = event.location == nil
        }
    }
    
    private var color: UIColor = UIColor(r: 73, g: 144, b: 226) {
        didSet {
            backgroundColor = color
        }
    }
    
    fileprivate var label: UILabel!
    fileprivate var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = color
        layer.cornerRadius = 4
        layer.masksToBounds = true
        
        prepareUI()
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        if let attributes = layoutAttributes as? ScheduleLayoutAttributes {
            color = attributes.color
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
}

// MARK: - Prepare UI
extension ScheduleEventCell {
    func prepareUI() {
        prepareLabel()
        prepareImageView()
    }
    
    private func prepareLabel() {
        label = UILabel()
        label.numberOfLines = 2
        label.font = UIFont(name: "HelveticaNeue", size: 12)
        label.textColor = UIColor(r: 248, g: 248, b: 248)
        
        addSubview(label)
        _ = label.anchor(topAnchor, left: leftAnchor, bottom: nil, right: nil, topConstant: 4, leftConstant: 8, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    
    private func prepareImageView() {
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .clear
        imageView.image = UIImage(named: "PennPin")
        
        addSubview(imageView)
        _ = imageView.anchor(label.topAnchor, left: nil, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 4, widthConstant: 0, heightConstant: 20)
    }
}
