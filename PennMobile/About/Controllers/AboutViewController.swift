//
//  AboutViewController.swift
//  PennMobile
//
//  Created by Marta García Ferreiro on 10/26/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import UIKit

class Member {
    var name: String
    var image: UIImage?
    
    // initialize properties of the class Member
    init (name: String, image: UIImage?) {
        self.name = name
        self.image = image
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
        
        let dom = Member(name: "Dominic Holmes", image: UIImage(named: "dom"))
        let ben = Member(name: "Ben Leimberger", image: UIImage(named: "ben"))
        let carin = Member(name: "Carin Gan", image: UIImage(named: "carin"))
        let salib = Member(name: "Daniel Salib", image: UIImage(named: "salib"))
        let marta = Member(name: "Marta García", image: UIImage(named: "marta"))
        let grace = Member(name: "Grace Jiang", image: UIImage(named: "grace"))
        let josh = Member(name: "Josh Doman", image: UIImage(named: "josh"))
        let tiff = Member(name: "Tiffany Chang", image: UIImage(named: "tiff"))
        let zhilei = Member(name: "Zhilei Zheng", image: UIImage(named: "zhilei"))
        let laura = Member(name: "Laura Gao", image: UIImage(named: "laura"))
        let yagil = Member(name: "Yagil Burowski", image: UIImage(named: "yagil"))
        let adel = Member(name: "Adel Qalieh", image: UIImage(named: "adel"))
        let henrique = Member(name: "Henrique Lorente", image: UIImage(named: "henrique"))
        
        var currentMembers = [Member]()
        var pastMembers = [Member]()
        
        //fill the arrays with the members
        pastMembers += [yagil, laura, adel]
        currentMembers += [tiff, josh, carin, marta, dom, grace, ben, salib, zhilei, henrique]
        members += [currentMembers, pastMembers]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
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
        let logoImage: UIImage = UIImage(named: "logo")!
        logo = UIImageView(image: logoImage)
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
        let font = UIFont(name: "AvenirNext-Regular", size: 18)!
        let boldFont = UIFont(name: "AvenirNext-Bold", size: 18)!
        
        let attributedString = NSMutableAttributedString(string: str, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font) : font]))
        attributedString.addAttribute(NSAttributedString.Key.font, value: boldFont, range: NSMakeRange(10, 9))
        attributedString.addAttribute(NSAttributedString.Key.font, value: boldFont, range: NSMakeRange(39, 18))
        attributedString.addAttribute(NSAttributedString.Key.font, value: boldFont, range: NSMakeRange(58, 18))
        attributedString.addAttribute(NSAttributedString.Key.font, value: boldFont, range: NSMakeRange(81, 20))
        
        subtitle.attributedText = attributedString
        subtitle.textColor = UIColor.darkGray
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
        descriptionTextView.font = UIFont(name: "AvenirNext-Regular", size: 14)
        descriptionTextView.textColor = .darkGray
        descriptionTextView.textAlignment = .center
        descriptionTextView.isScrollEnabled = false
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        descriptionTextView.widthAnchor.constraint(equalToConstant: 280.0).isActive = true
    }
    
    // MARK: set up learn more button
    
    func setupButton() {
        learnMoreButton = UIButton()
        learnMoreButton.backgroundColor = .spruceHarborBlue
        learnMoreButton.titleLabel?.font =  UIFont(name: "AvenirNext-DemiBold", size: 16)
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
        madeWithLoveLabel.font = UIFont(name: "AvenirNext-Medium", size: 18)
        madeWithLoveLabel.text = "Made with \u{1F496} by Penn Labs"
        madeWithLoveLabel.textColor = .darkGray
        madeWithLoveLabel.textAlignment = .center
        madeWithLoveLabel.translatesAutoresizingMaskIntoConstraints = false
        madeWithLoveLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    func setupCopyrightLabel() {
        copyrightLabel = UILabel()
        copyrightLabel.font = UIFont(name: "AvenirNext-Regular", size: 12)
        copyrightLabel.text = "Penn Labs \u{00A9} 2019"
        copyrightLabel.textColor = .darkGray
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
        return CGSize(width: 83.0, height: 105.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //create cell that has the properties of the CollectionViewCell we defined, otherwise it gives an error
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AboutPageCell", for: indexPath) as? AboutPageCollectionViewCell else {
            fatalError("The dequeued cell is not an instance of AboutPageCollectionViewCell.")
        }
        //put the data for the people in the cell
        let member = members[indexPath.section][indexPath.row]
        cell.name.text = member.name
        cell.profileImage.image = member.image
        return cell
    }
    
    func setupCollection() {
        let frame = self.view.frame
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView?.delegate = self
        collectionView?.dataSource = self
        self.collectionView?.backgroundColor = .white
        self.collectionView?.isScrollEnabled = false
        self.collectionView?.register(AboutPageCollectionViewCell.self, forCellWithReuseIdentifier: "AboutPageCell")
        self.collectionView?.register(AboutPageCollectionViewHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "AboutPageSectionHeader")
        
        collectionView?.translatesAutoresizingMaskIntoConstraints = false
        collectionView?.widthAnchor.constraint(equalToConstant: 300).isActive = true
        collectionView?.heightAnchor.constraint(equalToConstant: 600).isActive = true
        
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
