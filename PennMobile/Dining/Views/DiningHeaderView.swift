//
//  DiningHeaderView.swift
//  PennMobile
//
//  Created by Josh Doman on 1/19/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation
import UIKit

protocol DiningBalanceRefreshable {
    func refreshBalance()
}

class DiningHeaderView: UITableViewHeaderFooterView {
    
    enum DiningHeaderViewState {
        case normal
        case loading
        case refresh
    }
    
    var state: DiningHeaderViewState = .normal {
        didSet {
            switch state {
            case .normal:
                refreshButton.isHidden = true
                loadingView.isHidden = true
                loadingView.stopAnimating()
            case .loading:
                refreshButton.isHidden = false
                loadingView.isHidden = false
                loadingView.startAnimating()
            case .refresh:
                refreshButton.isHidden = false
                loadingView.isHidden = true
                loadingView.stopAnimating()
            }
        }
    }
    
    var delegate: DiningBalanceRefreshable?
    
    static let headerHeight: CGFloat = 60
    static let identifier = "diningHeaderView"
    
    fileprivate var loadingView: UIActivityIndicatorView!
    fileprivate var refreshButton: UIButton!
    
    var label: UILabel = {
        let label = UILabel()
        label.font = .primaryTitleFont
        label.textColor = .labelPrimary
        label.textAlignment = .left
        return label
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = .uiBackground
        
        addSubview(label)
        label.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(pad)
            make.bottom.equalTo(self).offset(-10)
        }

        prepareRefreshButton()
        prepareLoadingView()
        
        loadingView.isHidden = true
        refreshButton.isHidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DiningHeaderView {
    // MARK: Refresh Button
    fileprivate func prepareRefreshButton() {
        refreshButton = UIButton()
        refreshButton.tintColor = UIColor.navigation
        refreshButton.setImage(UIImage(named: "refresh")?.withRenderingMode(.alwaysTemplate), for: .normal)
        refreshButton.addTarget(self, action: #selector(refreshButtonTapped(_:)), for: .touchUpInside)
        refreshButton.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(refreshButton)
        
        refreshButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -18).isActive = true
        refreshButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        refreshButton.widthAnchor.constraint(equalToConstant: 24).isActive = true
        refreshButton.heightAnchor.constraint(equalToConstant: 24).isActive = true
    }
    
    func prepareLoadingView() {
        loadingView = UIActivityIndicatorView(style: .white)
        loadingView.color = .black
        loadingView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(loadingView)
        loadingView.rightAnchor.constraint(equalTo: refreshButton.leftAnchor, constant: -10).isActive = true
        loadingView.centerYAnchor.constraint(equalTo: refreshButton.centerYAnchor).isActive = true
    }
    
    @objc fileprivate func refreshButtonTapped(_ sender: Any) {
        if let delegate = delegate {
            delegate.refreshBalance()
        }
    }
}

