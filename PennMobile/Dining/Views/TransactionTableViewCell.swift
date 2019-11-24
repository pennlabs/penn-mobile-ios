//
//  TransactionTableViewCell.swift
//  PennMobile
//
//  Created by Elizabeth Powell on 11/22/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

class TransactionTableViewCell: UITableViewCell {
    
    static let identifier = "transactionCell"
    
    var transaction: Transaction! {
        didSet {
            setupCell(with: transaction)
        }
    }
    
    // MARK: UI Elements
    
    fileprivate var amountLabel: UILabel!
    fileprivate var balanceLabel: UILabel!
    fileprivate var dateLabel: UILabel!
    fileprivate var descriptionLabel: UILabel!
    
    fileprivate let dateFormatter = DateFormatter()
    fileprivate let numberFormatter = NumberFormatter()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        prepareFormatters()
        prepareUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Setup Cell
extension TransactionTableViewCell {
    fileprivate func setupCell(with transaction: Transaction) {
        self.amountLabel.textColor = transaction.amount < 0 ? UIColor.redLight : UIColor.greenLight
        self.amountLabel.text = numberFormatter.string(from: NSNumber(value: transaction.amount)) ?? String(transaction.amount)
        self.balanceLabel.text = String(transaction.balance)
        self.dateLabel.text = dateFormatter.string(from: transaction.date)
        self.descriptionLabel.text = formatDescription(description: transaction.description)
    }
}

// MARK: - Prepare Formatting
extension TransactionTableViewCell {
    func prepareFormatters() {
        dateFormatter.timeZone = TimeZone(abbreviation: "EST")
        dateFormatter.dateFormat = "MMM d, h:mm a"
        
        numberFormatter.numberStyle = NumberFormatter.Style.currency
        numberFormatter.currencySymbol = ""
        numberFormatter.locale = Locale(identifier: "en_US")
        numberFormatter.positivePrefix = numberFormatter.plusSign
        numberFormatter.negativePrefix = numberFormatter.minusSign
    }
    
    func formatDescription(description: String) -> String {
        let s1 = description.components(separatedBy: CharacterSet.decimalDigits).joined()
        let s2 = s1.components(separatedBy: "-")[0]
        let s3 = s2.titlecased().replacingOccurrences(of: "_", with: " ")
        let s4 = s3.replacingOccurrences(of: "  ", with: " ")
        return s4
    }
}

// MARK: - Prepare UI
extension TransactionTableViewCell {
    fileprivate func prepareUI() {
        prepareAmountLabel()
        prepareBalanceLabel()
        prepareDateLabel()
        prepareDescriptionLabel()
    }
    
    fileprivate func prepareAmountLabel() {
        amountLabel = UILabel()
        amountLabel.numberOfLines = 1
        amountLabel.font = UIFont.systemFont(ofSize: 17, weight: .black)
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
            
        addSubview(amountLabel)

        amountLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -16).isActive = true
        amountLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -10).isActive = true
    }
    
    fileprivate func prepareBalanceLabel() {
        balanceLabel = UILabel()
        balanceLabel.numberOfLines = 1
        balanceLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        balanceLabel.textColor = UIColor.gray
        balanceLabel.translatesAutoresizingMaskIntoConstraints = false
            
        addSubview(balanceLabel)

        balanceLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -16).isActive = true
        balanceLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 13).isActive = true
    }
        
    fileprivate func prepareDateLabel() {
        dateLabel = UILabel()
        dateLabel.numberOfLines = 1
        dateLabel.font = UIFont.systemFont(ofSize: 13.5, weight: .medium)
        dateLabel.textColor = UIColor.lightGray
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
                   
        addSubview(dateLabel)

        dateLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 13).isActive = true
        dateLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 13).isActive = true
    }
            
    fileprivate func prepareDescriptionLabel() {
        descriptionLabel = UILabel()
        descriptionLabel.numberOfLines = 1
        descriptionLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        descriptionLabel.textColor = UIColor.black
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
                   
        addSubview(descriptionLabel)

        descriptionLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 13).isActive = true
        descriptionLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -10).isActive = true
    }
}

// MARK: - Title Cased String Extension
extension String {
    func titlecased() -> String {
        return self.replacingOccurrences(of: "([A-Z])", with: " $1",
                                         options: .regularExpression, range: self.range(of: self))
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .capitalized
    }
}
