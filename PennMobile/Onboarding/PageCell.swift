//
//  PageCell.swift
//  audible
//
//  Created by Josh Doman on 11/23/16.
//  Copyright © 2016 Josh Doman. All rights reserved.
//

import UIKit

class PageCell: UICollectionViewCell {

    private lazy var confettiView: SAConfettiView = SAConfettiView(frame: self.bounds)

    var page: OnboardingPage? {
        didSet {

            guard let page = page else {
                return
            }

            imageView.image = UIImage(named: page.imageName)

            let color = UIColor(white: 0.2, alpha: 1)

            let attributedText = NSMutableAttributedString(string: page.title, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.medium), convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): color]))

            attributedText.append(NSAttributedString(string: "\n\n\(page.message)", attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): UIFont.systemFont(ofSize: 14), convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): color])))

            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center

            let length = attributedText.string.count
            attributedText.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: length))

            textView.attributedText = attributedText

            imageView.removeFromSuperview()
            addSubview(imageView)
            _ = imageView.anchor(nil, left: leftAnchor, bottom: textView.topAnchor, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)

            if page.isFullScreen {
                imageView.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true
            } else {
                #if os(visionOS)
                let height: CGFloat = 100
                #else
                let height = imageView.image!.size.height / imageView.image!.size.width * UIScreen.main.bounds.size.width
                #endif
                imageView.heightAnchor.constraint(equalToConstant: height).isActive = true
            }

            if page.showConfetti {
                addSubview(confettiView)
                confettiView.startConfetti()
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupViews()
    }

    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .white
        iv.contentMode = .scaleAspectFit
        iv.image = #imageLiteral(resourceName: "Onboard 1")
        iv.clipsToBounds = false // clips image so same size as screen
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    let textView: UITextView = {
        let tv = UITextView()
        tv.text = "SAMPLE TEXT"
        tv.isEditable = false
        tv.contentInset = UIEdgeInsets(top: 24, left: 0, bottom: 0, right: 0)
        return tv
    }()

    let lineSeperatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .grey6
        return view
    }()

    func setupViews() {
        addSubview(imageView)
        addSubview(textView)
        addSubview(lineSeperatorView)

        textView.anchorWithConstantsToTop(nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 16, bottomConstant: 0, rightConstant: 16)

        textView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.3).isActive = true

        lineSeperatorView.anchorToTop(nil, left: leftAnchor, bottom: textView.topAnchor, right: rightAnchor)

        lineSeperatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// Helper function inserted by Swift 4.2 migrator.
private func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
private func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}
