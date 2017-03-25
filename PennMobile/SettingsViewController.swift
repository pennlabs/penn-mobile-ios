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

class SettingsViewController: GenericTableViewController, SaveDelegate, SettingsCellDelegate {
    
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

private protocol SaveDelegate {
    func handleSave()
}

private class SaveCell: UITableViewCell {
    
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
        
        selectionStyle = .none
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
    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        subviews.forEach { (view) in
//            if type(of: view).description() == "_UITableViewCellSeparatorView" {
//                view.isHidden = true
//            }
//        }
//    }
}

private protocol SettingsCellDelegate {
    func getSelectedDiningHalls() -> [String]
}

private class SettingsCell: UITableViewCell, CheckBoxDelegate {
    
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
