//
//  Checkbox.swift
//  PennMobile
//
//  Created by Josh Doman on 3/8/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import UIKit

protocol CheckBoxDelegate {
    func numberOfRows() -> Int
    func labelForRow(for indexPath: IndexPath) -> String
    func sizeForRow(for indexPath: IndexPath) -> CGSize
    func getStartingCells() -> [String]
}

class CheckBoxTable: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10 //decreases gap between cells
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.dataSource = self
        cv.delegate = self
        cv.allowsSelection = false
        cv.isScrollEnabled = false
        return cv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(collectionView)
        
        collectionView.anchorToTop(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor)
        collectionView.register(CheckBoxCell.self, forCellWithReuseIdentifier: checkBoxCell)
    }
    
    private let checkBoxCell = "checkBoxCell"
    
    public var delegate: CheckBoxDelegate? {
        didSet {
            collectionView.reloadData()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    internal func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let delegate = delegate {
            return delegate.numberOfRows()
        } else {
            return 0
        }
    }
    
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: checkBoxCell, for: indexPath) as! CheckBoxCell
        if let delegate = delegate {
            let label = delegate.labelForRow(for: indexPath)
            cell.title = delegate.labelForRow(for: indexPath)
            cell.setCheckBox(isChecked: delegate.getStartingCells().contains(label))
        }
        return cell
    }
    
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let delegate = delegate {
            return delegate.sizeForRow(for: indexPath)
        }
        return CGSize(width: 0, height: 0) //makes cell size of frame
    }
    
    static func CalculateTableHeight(for numberOfRows: Int, heightForRow: Int) -> CGFloat {
        return CGFloat(numberOfRows * (10 + heightForRow))
    }
    
    public func getSelectedCells() -> [String] {
        var selectedCells = [String]()
        
        let cells = collectionView.visibleCells
        
        for cell in cells {
            let cell = cell as! CheckBoxCell
            if cell.isChecked() {
                if let title = cell.title {
                    selectedCells.append(title)
                }
            }
        }
        
        return selectedCells
    }
    
}

fileprivate class CheckBoxCell: UICollectionViewCell {
    
    private let checkBox = CheckBox(frame: .zero)
    
    var title: String? {
        didSet {
            label.text = title
            setupCell()
        }
    }
    
    private let label: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue", size: 12)
        label.textColor = UIColor(r: 155, g: 155, b: 155)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCell() {
        addSubview(checkBox)
        addSubview(label)
        
        _ = checkBox.anchor(nil, left: leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 16, heightConstant: 16)
        checkBox.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        _ = label.anchor(nil, left: checkBox.rightAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 12, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    func setCheckBox(isChecked: Bool) {
        checkBox.isChecked = isChecked
    }
    
    func isChecked() -> Bool {
        return checkBox.isChecked
    }
}

//http://stackoverflow.com/questions/29117759/how-to-create-radio-buttons-and-checkbox-in-swift-ios
fileprivate class CheckBox: UIButton {
    // Images
    private let uncheckedImage = UIImage(named: "unchecked_checkbox")! as UIImage
    private let checkedImage = UIImage(named: "checked_checkbox")! as UIImage
    
    // Bool property
    public var isChecked: Bool = false {
        didSet {
            if isChecked == true {
                self.setImage(checkedImage, for: .normal)
            } else {
                self.setImage(uncheckedImage, for: .normal)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
        self.setImage(uncheckedImage, for: .normal)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func buttonClicked(sender: UIButton) {
        if sender == self {
            isChecked = !isChecked
        }
    }
}

