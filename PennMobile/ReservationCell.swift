//
//  ReservationCell.swift
//  PennMobile
//
//  Created by Victor Chien on 2/4/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import UIKit

struct GSR {
    let number: Int //GSR number
    let availableIn: Int //minutes
    var location: StudyLocation //No GSR can exist independently of a location
    
    var description: String {
        get {
            return location.name + " " + String(self.number)
        }
    }
}

struct StudyLocation {
    let name: String
    var GSRs: [GSR]!
    
    public mutating func loadGSRs(for numbers: [Int]) {
        var arr = [GSR]()
        var availableIn = 30
        for number in numbers {
            arr.append(GSR(number: number, availableIn: availableIn, location: self))
            availableIn += 30
        }
        self.GSRs = arr
    }
    
    init(name: String) {
        self.name = name
    }
}

struct Announcement {
    let title: String
    let start: Date
    let end: Date
}

protocol ReservationCellDelegate {
    func handleReserve(for gsr: GSR)
    func handleMore()
    func getStudyLocations() -> [StudyLocation]
}

class ReservationCell: GenericHomeCell {
    
    internal static let StudyCellHeight: CGFloat = LocationCell.calculateCellHeight()
    private static let HeaderHeight: CGFloat = 50
    private static let BottomPadding: CGFloat = 20
    private static let FooterHeight: CGFloat = 30
    private static let SidePadding: CGFloat = 50
    
    private let header: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue-Light", size: 20)
        label.text = "Study at one of these locations"
        label.textColor = UIColor(r: 115, g: 115, b: 115)
        label.backgroundColor = .white
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: self.frame.width, height: ReservationCell.StudyCellHeight)
        layout.minimumLineSpacing = 0 //zero spacing between cells
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor(r: 248, g: 248, b: 248)
        cv.dataSource = self
        cv.allowsSelection = false
        cv.isScrollEnabled = false
        cv.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: ReservationCell.BottomPadding, right: 0)
        cv.register(LocationCell.self, forCellWithReuseIdentifier: self.locationCell)
        return cv
    }()
    
    private lazy var moreButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("More study spaces >", for: .normal)
        button.titleLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 15)
        button.tintColor = UIColor.warmGrey
        button.backgroundColor = .white
        
        button.addTarget(self, action: #selector(handleMore), for: .touchUpInside)
        return button
    }()
    
    internal var locations: [StudyLocation] {
        get {
            if let delegate = delegate {
                return delegate.getStudyLocations()
            } else {
                return [StudyLocation]()
            }
        }
    }
    
    internal let locationCell = "locationCell"
    
    var delegate: ReservationCellDelegate!
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
                
        setupViews()
    }
    
    private func setupViews() {
        addSubview(header)
        addSubview(collectionView)
        addSubview(moreButton)
        
        _ = header.anchor(topAnchor, left: leftAnchor, bottom: topAnchor, right: rightAnchor, topConstant: 0, leftConstant: 16, bottomConstant: -ReservationCell.HeaderHeight, rightConstant: 0, widthConstant: 0, heightConstant: ReservationCell.HeaderHeight)
        
        _ = moreButton.anchor(nil, left: nil, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 24, widthConstant: 0, heightConstant: ReservationCell.FooterHeight)
        
        _ = collectionView.anchorToTop(header.bottomAnchor, left: leftAnchor, bottom: moreButton.topAnchor, right: rightAnchor)
    }
    
    public static func calculateCellHeight(numberOfLocations: Int) -> CGFloat {
        if numberOfLocations <= 0 { return 0 }
        
        let numberOfCells = CGFloat(numberOfLocations)
        
        return BottomPadding + StudyCellHeight * numberOfCells + HeaderHeight + FooterHeight
    }
    
    public override func reloadData() {
        collectionView.reloadData()
    }
    
    internal func handleMore() {
        delegate.handleMore()
    }
}

extension ReservationCell: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return locations.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: locationCell, for: indexPath) as! LocationCell
        cell.delegate = self
        cell.location = locations[indexPath.item]
        return cell
    }
}

extension ReservationCell: GSRCellDelegate {
    internal func handleReserve(for gsr: GSR) {
        delegate.handleReserve(for: gsr)
    }
}

private class LocationCell: UICollectionViewCell {
    
    internal static let GSRHeight: CGFloat = 32
    private static let TitleHeight: CGFloat = 52
    private static let InnerWidth: CGFloat = 20
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue", size: 18)
        label.textColor = UIColor(r: 115, g: 115, b: 115)
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: self.frame.width, height: LocationCell.GSRHeight)
        layout.minimumLineSpacing = LocationCell.InnerWidth //sets gap between cells
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.dataSource = self
        cv.backgroundColor = UIColor(r: 248, g: 248, b: 248)
        cv.allowsSelection = false
        cv.isScrollEnabled = false
        cv.register(GSRCell.self, forCellWithReuseIdentifier: self.gsrCell)
        return cv
    }()
    
    var location: StudyLocation! {
        didSet {
            setupCell()
        }
    }
    
    internal var GSRs: [GSR] {
        return location.GSRs
    }
    
    internal let gsrCell = "gsrCell"
    
    var delegate: GSRCellDelegate!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    private func setupCell() {
        titleLabel.text = location.name
        
        titleLabel.removeFromSuperview()
        collectionView.removeFromSuperview()
        
        addSubview(titleLabel)
        addSubview(collectionView)
        
        titleLabel.anchorToTop(topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor)
        titleLabel.heightAnchor.constraint(equalToConstant: LocationCell.TitleHeight).isActive = true
        
        collectionView.anchorToTop(titleLabel.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor)
    }
    
    public static func calculateCellHeight() -> CGFloat {
        return 3*GSRHeight + TitleHeight + 2 * InnerWidth
    }
}

extension LocationCell: UICollectionViewDataSource {
    fileprivate func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    fileprivate func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return GSRs.count
    }
    
    fileprivate func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: gsrCell, for: indexPath) as! GSRCell
        cell.GSR = GSRs[indexPath.item]
        cell.delegate = self.delegate
        return cell
    }
}

private protocol GSRCellDelegate {
    func handleReserve(for gsr: GSR)
}

private class GSRCell: UICollectionViewCell {
    
    private lazy var reserveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Reserve", for: .normal)
        button.titleLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 14)
        button.tintColor = .white
        button.backgroundColor = UIColor.coral
        button.layer.cornerRadius = 4
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(handleReserve), for: .touchUpInside)
        return button
    }()
    
    private let numberLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.warmGrey
        label.font = UIFont(name: "HelveticaNeue-Light", size: 15)
        label.textAlignment = .right
        return label
    }()
    
    private let timer: UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        imageView.image = UIImage(named: "time")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        imageView.tintColor = UIColor.warmGrey
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue-Light", size: 15)
        label.text = "55'"
        label.textColor = UIColor.warmGrey
        return label
    }()
    
    var GSR: GSR! {
        didSet {
            numberLabel.text = String(GSR.number)
            timeLabel.text = String(GSR.availableIn) + "'"
        }
    }
    
    var delegate: GSRCellDelegate!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(reserveButton)
        addSubview(numberLabel)
        addSubview(timeLabel)
        addSubview(timer)
        
        _ = reserveButton.anchor(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 80, bottomConstant: 0, rightConstant: 80, widthConstant: 0, heightConstant: 0)
        
        _ = numberLabel.anchor(topAnchor, left: nil, bottom: bottomAnchor, right: reserveButton.leftAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 8, widthConstant: 0, heightConstant: 0)
        
        _ = timer.anchor(nil, left: reserveButton.rightAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 6, bottomConstant: 0, rightConstant: 0, widthConstant: 20, heightConstant: 16)
        timer.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        _ = timeLabel.anchor(topAnchor, left: timer.rightAnchor, bottom: bottomAnchor, right: nil, topConstant: 0, leftConstant: 2, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    internal func handleReserve() {
        delegate.handleReserve(for: GSR)
    }
}
