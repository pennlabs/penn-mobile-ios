//
//  TwoFactorCell.swift
//  PennMobile
//
//  Created by Henrique Lorente on 11/24/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//
import Foundation

protocol TwoFactorCellDelegate {
    func handleRefresh()
    func handleEnableSwitch(enabled: Bool)
    
}

class TwoFactorCell: UITableViewCell {
    
    static let cellHeight: CGFloat = 100
    static let identifier = "TwoFactorCell"
    
    fileprivate var enabled: Bool {
        return code != nil || UserDefaults.standard.bool(forKey: "TOTPEnabled")
    }
    
    var code: String? = nil {
        didSet {
            codeLabel.text = code
            enabledLabel.text = enabled ? "Enabled" : "Disabled"
            enabledLabel.textColor = enabled ? UIColor.baseGreen : UIColor.grey1
            
            refreshButton.tintColor = enabled ? .navigation : .grey1
            refreshButton.isEnabled = enabled
            
            if code == nil {
                codeLabel.text = "––––––"
            }
            
            enabledSwitch.isOn = enabled
        }
    }

    var delegate: TwoFactorCellDelegate!
    
    fileprivate var nameLabel: UILabel!
    fileprivate var titleLabel: UILabel!
    fileprivate var codeLabel: UILabel!
    fileprivate var enabledLabel: UILabel!
    fileprivate var refreshButton: UIButton!
    fileprivate var enabledSwitch: UISwitch!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        prepareUI()
        selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Prepare UI
extension TwoFactorCell {
    fileprivate func prepareUI() {
        prepareTitle()
        prepareCodeLabel()
        prepareEnabledSwitch()
        prepareEnabledLabel()
        prepareRefreshButton()
    }
    
    private func prepareTitle() {
        titleLabel = UILabel()
        titleLabel.textColor = UIColor.labelPrimary
        titleLabel.font = UIFont(name: "HelveticaNeue-Light", size: 19)
        titleLabel.textAlignment = .left
        titleLabel.text = "Two-Factor Automation"
        
        self.addSubview(titleLabel)
        _ = titleLabel.anchor(self.topAnchor, left: self.leftAnchor, bottom: nil, right: nil, topConstant: 12, leftConstant: 15, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    
    private func prepareCodeLabel() {
        codeLabel = UILabel()
        codeLabel.textColor = UIColor.labelPrimary
        codeLabel.font = UIFont.systemFont(ofSize: 32)
        codeLabel.textAlignment = .left
        if let code = code {
            codeLabel.text = code
        }
        else {
            codeLabel.text = "––––––"
        }
        
        self.addSubview(codeLabel)
        _ = codeLabel.anchor(nil, left: self.leftAnchor, bottom: self.bottomAnchor, right: nil, topConstant: 0, leftConstant: 15, bottomConstant: 12, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    
    private func prepareEnabledSwitch() {
        enabledSwitch = UISwitch()
        enabledSwitch.addTarget(self, action:  #selector(enableSwitchToggled(_:)), for: .valueChanged)
        self.addSubview(enabledSwitch)
        _ = enabledSwitch.anchor(self.topAnchor, left: nil, bottom: nil, right: self.rightAnchor, topConstant: 10, leftConstant: 0, bottomConstant: 0, rightConstant: 15, widthConstant: 0, heightConstant: 0)
    }
    
    private func prepareEnabledLabel() {
        enabledLabel = UILabel()
        enabledLabel.textColor = UIColor.labelSecondary
        enabledLabel.font = UIFont.systemFont(ofSize: 16)
        enabledLabel.textAlignment = .left
        enabledLabel.text = enabled ? "Enabled" : "Disabled"
        
        self.addSubview(enabledLabel)
        _ = enabledLabel.anchor(self.topAnchor, left: nil, bottom: nil, right: enabledSwitch.leftAnchor, topConstant: 15, leftConstant: 0, bottomConstant: 0, rightConstant: 15, widthConstant: 0, heightConstant: 0)
    }
        
    private func prepareRefreshButton() {
        refreshButton = UIButton()
        refreshButton.tintColor = UIColor.navigation
        refreshButton.setImage(UIImage(named: "refresh")?.withRenderingMode(.alwaysTemplate), for: .normal)
        refreshButton.addTarget(self, action: #selector(refreshButtonTapped(_:)), for: .touchUpInside)
        refreshButton.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(refreshButton)
        
        _ = refreshButton.anchor(nil, left: nil, bottom: nil, right: self.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 15, rightConstant: 15, widthConstant: 28, heightConstant: 28)
        refreshButton.centerYAnchor.constraint(equalTo: codeLabel.centerYAnchor).isActive = true
    }
}

// MARK: - Handle Refresh
extension TwoFactorCell {
    @objc fileprivate func refreshButtonTapped(_ sender: Any) {
        delegate.handleRefresh()
    }
}

// MARK: - Handle Enable Switch
extension TwoFactorCell {
    @objc fileprivate func enableSwitchToggled(_ sender: Any) {
//        enabledLabel.text = enabledSwitch.isOn ? "Enabled" : "Disabled"
        delegate.handleEnableSwitch(enabled: enabledSwitch.isOn)
    }
}
