//
//  HomeExampleCell.swift
//  PennMobile
//
//  Created by CHOI Jongmin on 14/2/2020.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import UIKit

final class HomeExampleCell: UITableViewCell, HomeCellConformable {

    static var identifier: String = "exampleCell"

    static func getCellHeight(for item: ModularTableViewItem) -> CGFloat {
        return 100.0
    }

    var item: ModularTableViewItem! {
        didSet {
            guard let item = item as? HomeExampleCellItem else { return }
            setupCell(with: item)
        }
    }

    var delegate: ModularTableViewCellDelegate!

    var cardView: UIView! = UIView()

    var titleLabel: UILabel!
        var myLabel: UILabel!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        prepareHomeCell()
        prepareUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension HomeExampleCell {
    fileprivate func prepareUI() {
        prepareTitleLabel()
        prepareMyLabel()
    }

    private func prepareTitleLabel() {
        titleLabel = UILabel()
        titleLabel.text = "Example Cell"

        cardView.addSubview(titleLabel)
        _ = titleLabel.anchor(cardView.topAnchor, left: cardView.leftAnchor, bottom: nil, right: nil, topConstant: 12, leftConstant: 20, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }

    private func prepareMyLabel() {
        myLabel = UILabel()

        cardView.addSubview(myLabel)
        _ = myLabel.anchor(nil, left: cardView.leftAnchor, bottom: cardView.bottomAnchor, right: nil, topConstant: 0, leftConstant: 20, bottomConstant: 10, rightConstant: 0, widthConstant: 0, heightConstant: 0)

    }

}

// MARK: - Setup Item
extension HomeExampleCell {
    func setupCell(with item: HomeExampleCellItem) {
        self.myLabel.text = item.myData
    }
}
