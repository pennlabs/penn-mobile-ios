//
//  AboutViewController.swift
//  PennMobile
//
//  Created by Marta García Ferreiro on 10/26/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

class AboutViewController: UIViewController {

    var logo: UIImageView!
    var subtitle: UITextView!
    var descriptionTextView: UITextView!
    var learnMoreButton: UIButton!
    var madeWithLoveLabel: UILabel!
    var copyrightLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .uiBackground
        self.title = "About"

        setupLogo()
        setupSubtitle()
        setupDescription()
        setupButton()
        setUpMadeWithLoveLabel()
        setupCopyrightLabel()
        setupStack()
    }

    // MARK: set up logo and informational text
    func setupLogo() {
        let logoImage: UIImage = UIImage(named: "logotype") ?? UIImage()
        logo = UIImageView(image: logoImage)
        logo.contentMode = .scaleAspectFit
        logo.translatesAutoresizingMaskIntoConstraints = false
        logo.widthAnchor.constraint(equalToConstant: 230.0).isActive = true
        logo.heightAnchor.constraint(equalToConstant: 129.0).isActive = true
    }

    func setupSubtitle() {
        subtitle = UITextView()
        subtitle.isEditable = false
        subtitle.isSelectable = false
        subtitle.textContainer.maximumNumberOfLines = 0

        let str = "Hi, we’re Penn Labs: a team of student software engineers, product designers, and business developers."
        let font = UIFont.systemFont(ofSize: 18)
        let boldFont = UIFont.systemFont(ofSize: 18, weight: .semibold)

        let attributedString = NSMutableAttributedString(string: str, attributes: [.font: font])
        attributedString.addAttribute(NSAttributedString.Key.font, value: boldFont, range: NSMakeRange(10, 9))
        attributedString.addAttribute(NSAttributedString.Key.font, value: boldFont, range: NSMakeRange(39, 18))
        attributedString.addAttribute(NSAttributedString.Key.font, value: boldFont, range: NSMakeRange(58, 18))
        attributedString.addAttribute(NSAttributedString.Key.font, value: boldFont, range: NSMakeRange(81, 20))

        subtitle.attributedText = attributedString
        subtitle.textColor = UIColor.labelPrimary
        subtitle.textAlignment = .center
        subtitle.isScrollEnabled = false

        subtitle.translatesAutoresizingMaskIntoConstraints = false
        subtitle.widthAnchor.constraint(equalToConstant: 280.0).isActive = true
    }

    func setupDescription() {
        descriptionTextView = UITextView()
        descriptionTextView.isEditable = false
        descriptionTextView.isSelectable = false
        descriptionTextView.textContainer.maximumNumberOfLines = 0
        descriptionTextView.text = "Penn Labs empowers others to make connections: connections to resources, connections to people, and connections to the greater Penn community.\n\n Our ultimate goal is improving the Penn community. We aim to do so not only by creating high quality products, but also by giving back to the community with educational resources and technical support."
        descriptionTextView.font = .systemFont(ofSize: 14)
        descriptionTextView.textColor = .labelPrimary
        descriptionTextView.textAlignment = .center
        descriptionTextView.isScrollEnabled = false
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        descriptionTextView.widthAnchor.constraint(equalToConstant: 280.0).isActive = true
    }

    // MARK: set up learn more button

    func setupButton() {
        learnMoreButton = UIButton()
        learnMoreButton.backgroundColor = .baseBlue
        learnMoreButton.titleLabel?.font =  .systemFont(ofSize: 16, weight: .semibold)
        learnMoreButton.setTitle("Learn More", for: [])
        learnMoreButton.setTitleColor(UIColor.white, for: [])

        learnMoreButton.layer.cornerRadius = 36.0/2
        learnMoreButton.layer.masksToBounds = true
        learnMoreButton.translatesAutoresizingMaskIntoConstraints = false
        learnMoreButton.heightAnchor.constraint(equalToConstant: 36.0).isActive = true
        learnMoreButton.widthAnchor.constraint(equalToConstant: 132.0).isActive = true
        learnMoreButton.addTarget(self, action: #selector(didTapLearnMoreButton), for: .touchUpInside)
    }

    @objc func didTapLearnMoreButton(sender: UIButton!) {
        if let url = URL(string: "https://pennlabs.org") {
            UIApplication.shared.open(url, options: [:])
        }
    }

    func setUpMadeWithLoveLabel() {
        madeWithLoveLabel = UILabel()
        madeWithLoveLabel.font = .systemFont(ofSize: 18, weight: .medium)
        madeWithLoveLabel.text = "Made with \u{1F496} by Penn Labs"
        madeWithLoveLabel.textColor = .labelSecondary
        madeWithLoveLabel.textAlignment = .center
        madeWithLoveLabel.translatesAutoresizingMaskIntoConstraints = false
        madeWithLoveLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }

    func setupCopyrightLabel() {
        let now = Date()
        copyrightLabel = UILabel()
        copyrightLabel.font = .systemFont(ofSize: 11)
        copyrightLabel.text = "Penn Labs \u{00A9} \(now.year)"
        copyrightLabel.textColor = .labelTertiary
        copyrightLabel.textAlignment = .center
        copyrightLabel.translatesAutoresizingMaskIntoConstraints = false
        copyrightLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }

    // MARK: set up scroll view and stack view
    func setupStack() {
        let space = UIView()
        space.translatesAutoresizingMaskIntoConstraints = false
        space.widthAnchor.constraint(equalToConstant: 1.0).isActive = true
        space.heightAnchor.constraint(equalToConstant: 50.0).isActive = true

        let smallSpace = UIView()
        space.translatesAutoresizingMaskIntoConstraints = false
        space.widthAnchor.constraint(equalToConstant: 1.0).isActive = true
        space.heightAnchor.constraint(equalToConstant: 25.0).isActive = true

        let stackView = UIStackView(arrangedSubviews: [space, logo, subtitle, descriptionTextView, learnMoreButton, smallSpace, madeWithLoveLabel, copyrightLabel])

        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)

        //add constraints to scrollView
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        scrollView.addSubview(stackView)

        //add constraints to stackView
        stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
    }
}
