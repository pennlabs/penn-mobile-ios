//
//  UpdateVersionCell.swift
//  PennMobile
//
//  Created by Josh Doman on 12/30/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation


import Foundation

final class UpdateVersionCell: UITableViewCell, HomeCellConformable {
    var cardView: UIView! = UIView()
    
    var delegate: ModularTableViewCellDelegate!
    
    static var identifier: String = "updateVersionCell"
    
    var item: ModularTableViewItem! {
        didSet {
            guard let item = item as? UpdateVersionCellItem else { return }
            setupCell(with: item)
        }
    }
    
    static func getCellHeight(for item: ModularTableViewItem) -> CGFloat {
        return 210
    }
    
    // Custom UI elements (some should be abstracted)
    fileprivate let safeInsetValue: CGFloat = 14
    fileprivate var safeArea: UIView!
    
    fileprivate var secondaryTitleLabel: UILabel!
    fileprivate var primaryTitleLabel: UILabel!
    
    fileprivate var dividerLine: UIView!
    fileprivate var updateVersionLabel: UILabel!
    
    // Mark: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        prepareHomeCell()
        prepareUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup UI Elements
extension UpdateVersionCell {
    fileprivate func setupCell(with item: UpdateVersionCellItem) {
        secondaryTitleLabel.text = "UPDATE APP"
        primaryTitleLabel.text = "Update Available"
    }
}

// MARK: - Initialize & Layout UI Elements
extension UpdateVersionCell {
    fileprivate func prepareUI() {
        prepareSafeArea()
        prepareTitleLabels()
        prepareDividerLine()
        prepareUpdateTextLabel()
        prepareGestures()
    }
    
    private func prepareSafeArea() {
        safeArea = getSafeAreaView()
        
        cardView.addSubview(safeArea)
        
        safeArea.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: safeInsetValue).isActive = true
        safeArea.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -safeInsetValue).isActive = true
        safeArea.topAnchor.constraint(equalTo: cardView.topAnchor, constant: safeInsetValue).isActive = true
        safeArea.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -safeInsetValue).isActive = true
    }
    
    // MARK: Labels
    fileprivate func prepareTitleLabels() {
        secondaryTitleLabel = getSecondaryLabel()
        primaryTitleLabel = getPrimaryLabel()
        
        cardView.addSubview(secondaryTitleLabel)
        cardView.addSubview(primaryTitleLabel)
        
        secondaryTitleLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor).isActive = true
        secondaryTitleLabel.topAnchor.constraint(equalTo: safeArea.topAnchor).isActive = true
        
        primaryTitleLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor).isActive = true
        primaryTitleLabel.topAnchor.constraint(equalTo: secondaryTitleLabel.bottomAnchor, constant: 10).isActive = true
    }
    
    // MARK: Divider Line
    fileprivate func prepareDividerLine() {
        dividerLine = getDividerLine()
        
        cardView.addSubview(dividerLine)
        
        dividerLine.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor).isActive = true
        dividerLine.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor).isActive = true
        dividerLine.topAnchor.constraint(equalTo: primaryTitleLabel.bottomAnchor, constant: 14).isActive = true
        dividerLine.heightAnchor.constraint(equalToConstant: 2).isActive = true
    }
    
    fileprivate func prepareUpdateTextLabel() {
        updateVersionLabel = UILabel()
        updateVersionLabel.textAlignment = .center
        updateVersionLabel.numberOfLines = 0
        updateVersionLabel.font = UIFont(name: "HelveticaNeue", size: 19)
        updateVersionLabel.textColor = .labelSecondary
        updateVersionLabel.attributedText = getUpdateVersionText()
        
        updateVersionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        cardView!.addSubview(updateVersionLabel)
        updateVersionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        updateVersionLabel.topAnchor.constraint(equalTo: dividerLine.bottomAnchor, constant: 20).isActive = true
        updateVersionLabel.widthAnchor.constraint(equalTo: cardView.widthAnchor, constant: -40).isActive = true
        updateVersionLabel.centerXAnchor.constraint(equalTo: cardView.centerXAnchor).isActive = true
    }
    
    func prepareGestures() {
        let tapGestureRecognizer = getTapGestureRecognizer()
        cardView.addGestureRecognizer(tapGestureRecognizer)
        cardView.isUserInteractionEnabled = true
    }
}

// MARK: - Define UI Elements
extension UpdateVersionCell {
    
    fileprivate func getSafeAreaView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    fileprivate func getSecondaryLabel() -> UILabel {
        let label = UILabel()
        label.font = .secondaryTitleFont
        label.textColor = .labelSecondary
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    fileprivate func getPrimaryLabel() -> UILabel {
        let label = UILabel()
        label.font = .primaryTitleFont
        label.textColor = .labelPrimary
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    fileprivate func getDividerLine() -> UIView {
        let view = UIView()
        view.backgroundColor = .grey5
        view.layer.cornerRadius = 2.0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    func getUpdateVersionText() -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        paragraphStyle.alignment = .center
        
        let attrString = NSMutableAttributedString(string: "Update the app to take full advantage of the latest features 🎉")
        attrString.addAttribute(.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
        return attrString
    }
}

// MARK: - Gesture Recognizer
extension UpdateVersionCell {
    fileprivate func getTapGestureRecognizer() -> UITapGestureRecognizer {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapped(_:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        return tapGestureRecognizer
    }
    
    @objc fileprivate func handleTapped(_ sender: Any) {
        UIApplication.shared.open(URL(string: "itms-apps://apps.apple.com/in/app/penn-mobile/id944829399?mt=8")!, options: [:], completionHandler: nil)
    }
}
