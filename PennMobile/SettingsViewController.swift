//
//  SettingsViewController.swift
//  PennMobile
//
//  Created by Josh Doman on 3/4/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import Foundation
import UIKit

protocol SettingsViewControllerDelegate {
    func getSelectedDiningHalls() -> [String]
    func getSelectedSettings() -> [String]
    func updateHomeViewController(settings: [String], diningHalls: [String])
}

class SettingsViewController: UITableViewController, SaveDelegate, SettingsCellDelegate {
    
    let settings = ["Weather", "Schedule", "Study Room Booking", "Dining"]
    let diningHalls = ["1920 Commons", "English House", "Tortas Frontera", "New College House", "Hill House", "1920 Starbucks", "Houston Market"]
    
    var diningCellSelected = false
    var checkBoxHeight = 20
    
    var delegate: SettingsViewControllerDelegate? {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var selectedSettings: [String] {
        get {
            var tempArr = [String]()
            
            let numberOfSettings = settings.count - 1
            for index in 0...numberOfSettings {
                let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as! SettingsCell
                if cell.settingIsOn() {
                    if let setting = cell.setting {
                        tempArr.append(setting)
                    }
                }
            }
            
            return tempArr
        }
    }
    
    private var selectedDiningHalls: [String] {
        get {
            let cell = tableView.cellForRow(at: IndexPath(row: settings.count-1, section: 0)) as! SettingsCell
            return cell.getSelectedDiningHalls()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Customize Home"
        self.view.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.tintColor = UIColor(r: 192, g: 57, b:  43)
        
        //slide out menu stuff
        let revealController = SWRevealViewController()
        revealController.panGestureRecognizer()
        revealController.tapGestureRecognizer()
        
        //Assigns function to the menu button
        let revealButtonItem = UIBarButtonItem(image: UIImage(named: "reveal-icon.png")!, style: .plain, target: revealController, action: #selector(SWRevealViewController.revealToggle(_:)))
        self.navigationItem.leftBarButtonItem = revealButtonItem
        
        let image = UIImage(named: "homepage-settings")
        navigationItem.rightBarButtonItem = UIBarButtonItem.itemWith(colorfulImage: image, color: UIColor(r: 100, g: 100, b:  100), target: self, action: #selector(handleDismiss))
        
        registerCells()
        
        tableView.tableFooterView = UIView() // Removes empty cell separators
        
    }
    
    let settingsCell = "settingsCell"
    let saveCell = "saveCell"
    
    func registerCells() {
        tableView.register(SettingsCell.self, forCellReuseIdentifier: settingsCell)
        tableView.register(SaveCell.self, forCellReuseIdentifier: saveCell)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == settings.count - 1 {
            return 60 + CheckBoxTable.CalculateTableHeight(for: diningHalls.count, heightForRow: checkBoxHeight)
        } else {
            return 60
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings.count + 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //adding table view cell programmatically
        if indexPath.row == settings.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: saveCell, for: indexPath) as! SaveCell
            cell.delegate = self
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: settingsCell, for: indexPath) as! SettingsCell
        let setting = settings[indexPath.row]
        cell.setting = setting
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        if indexPath.row == settings.count - 1 {
            cell.diningHalls = self.diningHalls
            cell.checkBoxHeight = CGFloat(checkBoxHeight)
            cell.delegate = self
        }
        
        if let delegate = delegate {
            cell.setSwitch(on: delegate.getSelectedSettings().contains(setting))
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
    
    func handleDismiss() {
        _ = navigationController?.popViewController(animated: false)
    }
    
    func handleSave() {
        var selectedSettings = self.selectedSettings
        if selectedDiningHalls.isEmpty, let index = selectedSettings.index(of: "Dining") {
            selectedSettings.remove(at: index) //"Dining" must be last
        }
        
        delegate?.updateHomeViewController(settings: selectedSettings, diningHalls: selectedDiningHalls)
        handleDismiss()
    }

    func getSelectedDiningHalls() -> [String] {
        if let delegate = delegate {
            return delegate.getSelectedDiningHalls()
        }
        return []
    }
}

protocol SaveDelegate {
    func handleSave()
}

class SaveCell: UITableViewCell {
    
    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save", for: .normal)
        button.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 14)
        button.tintColor = .white
        button.backgroundColor = UIColor(r: 242, g: 110, b: 103)
        button.layer.cornerRadius = 2
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
        return button
    }()
    
    var delegate: SaveDelegate?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
    }
    
    func setupViews() {
        addSubview(saveButton)
        
        _ = saveButton.anchor(topAnchor, left: nil, bottom: nil, right: rightAnchor, topConstant: 16, leftConstant: 0, bottomConstant: 0, rightConstant: 28, widthConstant: 75, heightConstant: 36)
        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    func handleSave() {
        delegate?.handleSave()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        subviews.forEach { (view) in
            if type(of: view).description() == "_UITableViewCellSeparatorView" {
                view.isHidden = true
            }
        }
    }
}

protocol SettingsCellDelegate {
    func getSelectedDiningHalls() -> [String]
}

class SettingsCell: UITableViewCell, CheckBoxDelegate {
    
    var setting: String? {
        didSet {
            label.text = setting
            setupViews()
        }
    }
    
    var diningHalls: [String]?
    var checkBoxHeight: CGFloat = 20
    var delegate: SettingsCellDelegate?
    
    private let label: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue", size: 17)
        label.textColor = UIColor(r: 155, g: 155, b: 155)
        return label
    }()
    
    private let settingsSwitch: UISwitch = {
        let switcher = UISwitch()
        switcher.onTintColor = UIColor(r: 65, g: 81, b: 181)
        switcher.translatesAutoresizingMaskIntoConstraints = false
        switcher.setOn(true, animated: false)
        switcher.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        return switcher
    }()
    
    private lazy var checkBoxTable: CheckBoxTable = {
        let check = CheckBoxTable()
        check.delegate = self
        return check
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    let leftOffset: CGFloat = 30
    
    func setupViews() {
        addSubview(label)
        addSubview(settingsSwitch)
        
        _ = label.anchor(nil, left: leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: leftOffset, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        label.centerYAnchor.constraint(equalTo: topAnchor, constant: 30).isActive = true
        
        _ = settingsSwitch.anchor(nil, left: nil, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 0)
        settingsSwitch.centerYAnchor.constraint(equalTo: topAnchor, constant: 30).isActive = true
        
        if setting == "Dining" {
            addSubview(checkBoxTable)
            
            checkBoxTable.anchorWithConstantsToTop(label.bottomAnchor, left: label.leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 16, leftConstant: 0, bottomConstant: 0, rightConstant: 0)
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    func numberOfRows() -> Int {
        if let halls = diningHalls {
            return halls.count
        }
        return 0
    }
    
    func labelForRow(for indexPath: IndexPath) -> String {
        if let halls = diningHalls {
            return halls[indexPath.row]
        }
        return ""
    }
    
    func sizeForRow(for indexPath: IndexPath) -> CGSize {
        return CGSize(width: frame.width-leftOffset, height: checkBoxHeight)
    }
    
    public func getSelectedDiningHalls() -> [String] {
        return checkBoxTable.getSelectedCells()
    }
    
    public func settingIsOn() -> Bool {
        return settingsSwitch.isOn
    }
    
    public func setSwitch(on: Bool) {
        settingsSwitch.isOn = on
    }
    
    public func getStartingCells() -> [String] {
        if let delegate = delegate {
            return delegate.getSelectedDiningHalls()
        }
        return []
    }
}

//http://stackoverflow.com/questions/29117759/how-to-create-radio-buttons-and-checkbox-in-swift-ios
class CheckBox: UIButton {
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

class CheckBoxCell: UICollectionViewCell {
    
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
