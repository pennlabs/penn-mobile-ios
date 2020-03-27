//
//  AboutViewController.swift
//  PennMobile
//
//  Created by Marta García Ferreiro on 10/26/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import UIKit
import Kingfisher

class Member {
    var name: String
    var imageURL: URL?
    var websiteURL: URL?
    
    // initialize properties of the class Member
    init (name: String, image: String, website: String? = nil) {
        self.name = name
        if let website = website {
            self.websiteURL = URL(string: website)
        }
        self.imageURL = URL(string: "https://s3.us-east-2.amazonaws.com/penn.mobile/about/" + image)
    }
}

class AboutViewController : UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var logo: UIImageView!
    var subtitle: UITextView!
    var descriptionTextView: UITextView!
    var learnMoreButton: UIButton!
    var madeWithLoveLabel: UILabel!
    var copyrightLabel: UILabel!
    var members = [[Member]]()
    var collectionView: UICollectionView?
    
    private func loadMembers() {
        
        let dom = Member(name: "Dominic Holmes", image: "dominic.jpeg", website: "https://dominic.land")
        let ben = Member(name: "Ben Leimberger", image: "ben.jpeg")
        let carin = Member(name: "Carin Gan", image: "carin.jpeg")
        let salib = Member(name: "Daniel Salib", image: "salib.jpeg")
        let marta = Member(name: "Marta García", image: "marta.jpg")
        let grace = Member(name: "Grace Jiang", image: "grace.jpeg")
        let josh = Member(name: "Josh Doman", image: "josh.jpeg")
        let tiff = Member(name: "Tiffany Chang", image: "tiff.jpeg")
        let zhilei = Member(name: "Zhilei Zheng", image: "zhilei.jpeg")
        let laura = Member(name: "Laura Gao", image: "laura.jpeg")
        let yagil = Member(name: "Yagil Burowski", image: "yagil.jpeg")
        let adel = Member(name: "Adel Qalieh", image: "adel.jpeg")
        let rehaan = Member(name: "Rehaan Furniturewala", image: "rehaan.jpeg")
        let liz = Member(name: "Liz Powell", image: "liz.jpeg")
        let henrique = Member(name: "Henrique Lorente", image: "henrique.jpeg")
        let lucy = Member(name: "Lucy Yuan", image: "lucy.jpeg")
        let matthew = Member(name: "Matthew Rosca-Halmagean", image: "matthew.jpeg")
        let hassan = Member(name: "Hassan Hammoud", image: "hassan.jpeg")
        let jongmin = Member(name: "Jong Min Choi", image: "jongmin.jpeg")
        var currentMembers = [Member]()
        var pastMembers = [Member]()
        
        //fill the arrays with the members
        pastMembers += [marta, grace, ben, tiff, zhilei, laura, adel, yagil]
        currentMembers += [josh, dom, carin, salib, rehaan, liz, henrique, lucy, matthew, hassan, jongmin]
        members += [currentMembers, pastMembers]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .uiBackground
        self.title = "About"
        
        loadMembers()
        setupLogo()
        setupSubtitle()
        setupDescription()
        setupButton()
        setupCollection()
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
        
        let attributedString = NSMutableAttributedString(string: str, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font) : font]))
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
    
    // MARK: set up collection view
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if (kind == UICollectionView.elementKindSectionHeader) {
            let section = indexPath.section
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "AboutPageSectionHeader", for: indexPath) as! AboutPageCollectionViewHeader
            header.label.text = (section == 0) ? "Meet the Team" : "Alumni"
            return header
        }
        return AboutPageCollectionViewHeader()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.bounds.width, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return members[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 90.0, height: 105.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //create cell that has the properties of the CollectionViewCell we defined, otherwise it gives an error
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AboutPageCell", for: indexPath) as? AboutPageCollectionViewCell else {
            fatalError("The dequeued cell is not an instance of AboutPageCollectionViewCell.")
        }
        //put the data for the people in the cell
        let member = members[indexPath.section][indexPath.row]
        cell.name.text = member.name
        if let imageURL = member.imageURL {
            cell.profileImage.kf.setImage(with: imageURL)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let member = members[indexPath.section][indexPath.row]
        if let url = member.websiteURL {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    func setupCollection() {
        let frame = self.view.frame
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView?.delegate = self
        collectionView?.dataSource = self
        self.collectionView?.backgroundColor = .clear
        self.collectionView?.isScrollEnabled = false
        self.collectionView?.register(AboutPageCollectionViewCell.self, forCellWithReuseIdentifier: "AboutPageCell")
        self.collectionView?.register(AboutPageCollectionViewHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "AboutPageSectionHeader")
        
        collectionView?.translatesAutoresizingMaskIntoConstraints = false
        collectionView?.widthAnchor.constraint(equalToConstant: 300).isActive = true
        collectionView?.heightAnchor.constraint(equalToConstant: 1000).isActive = true
        
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
        
        let stackView = UIStackView(arrangedSubviews: [space, logo, subtitle, descriptionTextView, learnMoreButton, smallSpace, collectionView!, madeWithLoveLabel, copyrightLabel])
        
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

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}
