//
//  PollsCell.swift
//  PennMobile
//
//  Created by Lucy Yuewei Yuan on 9/27/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import UIKit
import SnapKit

class PollOptionCell: UITableViewCell {

    static let identifier = "pollOptionCell"
    var totalResponses: Int!

    var chosen: Bool = false
    var answered: Bool! {
         didSet {
            print("changed answered")
           // setupCell()
        }
    }

    var pollOption: PollOption! {
        didSet {
            print("pollOption")
            setupCell()
        }
    }

    // MARK: - UI Elements
    fileprivate var safeArea: UIView!
    fileprivate var questionLabel: UILabel!
    fileprivate var percentageShadow: UIView!

    fileprivate var percentageLabel: UILabel!
    fileprivate var voteLabel: UILabel!

    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        prepareSafeArea()
        prepareUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup Cell
extension PollOptionCell {

    fileprivate func setupCell() {
        backgroundColor = .clear
        self.questionLabel.text = self.pollOption.choice
        let maxWidth = CGFloat(0.85) * UIScreen.main.bounds.width

        if self.answered {
            let frac = CGFloat(pollOption.voteCount) / CGFloat(self.totalResponses)
            let width = frac * maxWidth

            // Create percentage label and attach them to safeAreaView
            percentageLabel.text = "\((frac * 100).rounded())%"
            safeArea.addSubview(percentageLabel)

            // Set constraints to start animation from
            percentageLabel.snp.makeConstraints { make in
                make.trailing.equalTo(safeArea.snp.trailing).offset(-100)
                make.top.equalTo(safeArea).offset(10)

            }

            // Same thing for vote label
            voteLabel.text = "\(self.pollOption.voteCount) Votes"
            safeArea.addSubview(voteLabel)

            voteLabel.snp.makeConstraints { make in
                make.leading.equalTo(percentageLabel)
                make.top.equalTo(percentageLabel.snp.bottom).offset(5)
            }

            // Update safe area quitely!
            safeArea.layoutIfNeeded()

            // Update to new constraints to animate to
            percentageLabel.snp.remakeConstraints { make in
                make.leading.equalTo(questionLabel.snp.trailing)
                make.trailing.lessThanOrEqualTo(safeArea.snp.trailing)
            }

            voteLabel.snp.updateConstraints { make in
                make.leading.equalTo(percentageLabel)
            }

            percentageShadow.snp.updateConstraints {(make) in
                make.width.equalTo(width)
            }

            // Animates new constraints and colors
            let anim = UIViewPropertyAnimator(duration: 0.5, curve: .easeOut) {
                self.percentageShadow.backgroundColor = self.chosen ? .blueLighter : .lightGray
                self.percentageShadow.superview!.layoutIfNeeded()
                self.voteLabel.alpha = 1
                self.percentageLabel.alpha = 1

            }

            anim.startAnimation()

        } else {
            print("hrere")
            percentageLabel.text = ""
            voteLabel.text = ""
            percentageShadow.backgroundColor = .greenLighter
            percentageShadow.snp.remakeConstraints {(make) in
                make.leading.equalTo(safeArea)
                make.top.equalTo(safeArea).offset(-2)
                make.width.equalTo(maxWidth)
                make.bottom.equalTo(safeArea).offset(2)
            }
        }
    }

}

// MARK: - Initialize and Layout UI Elements
extension PollOptionCell {

    fileprivate func prepareUI() {
        preparePercentageShadowView()
        prepareLabels()
        percentageLabel = getPercentageLabel()
        voteLabel = getVotesLabel()
    }

    // MARK: Safe Area
    fileprivate func prepareSafeArea() {
        safeArea = UIView()
        addSubview(safeArea)

        safeArea.snp.makeConstraints { (make) in
            make.leading.equalTo(self).offset(pad)
            make.trailing.equalTo(self).offset(-pad * 1)
            make.top.equalTo(self).offset(8)
            make.bottom.equalTo(self).offset(-8)
        }
    }

    // MARK: percentage shadow
    fileprivate func preparePercentageShadowView() {
        percentageShadow = UIView()
        percentageShadow.layer.cornerRadius = 10
        percentageShadow.layer.masksToBounds = true

        safeArea.addSubview(percentageShadow)

        let maxWidth = CGFloat(0.8) * UIScreen.main.bounds.width

        percentageShadow.backgroundColor = .greenLighter
        safeArea.addSubview(percentageShadow)
        percentageShadow.snp.makeConstraints {(make) in
            make.leading.equalTo(safeArea)
            make.top.equalTo(safeArea).offset(-8)
            make.width.equalTo(maxWidth)
            make.bottom.equalTo(safeArea).offset(8)
        }

    }

    // MARK: Labels
    fileprivate func prepareLabels() {
        questionLabel = getQuestionLabel()

        safeArea.addSubview(questionLabel)

        questionLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(safeArea).offset(15)
            make.trailing.equalTo(safeArea).offset(-50)
            make.centerY.equalToSuperview()
        }
    }
}

// MARK: - Define UI Elements
extension PollOptionCell {

    fileprivate func getQuestionLabel() -> UILabel {
        let label = UILabel()
        label.font = .primaryInformationFont
        label.textColor = .labelPrimary
        label.textAlignment = .left
        label.numberOfLines = 0
        label.sizeToFit()
        // PollOptionCell.cellHeight = label.frame.height + Padding.pad * 2
        return label
    }

    fileprivate func getPercentageLabel() -> UILabel {
        let label = UILabel()
        label.font = .primaryInformationFont
        label.textColor = chosen ? .blueDark : .darkGray
        label.textAlignment = .left
        label.numberOfLines = 1
        label.alpha = 0
        return label
    }

    fileprivate func getVotesLabel() -> UILabel {
        let label = UILabel()
        label.font = .primaryInformationFont
        label.textColor = chosen ? .blueDark : .darkGray
        label.textAlignment = .left
        label.numberOfLines = 1
        label.alpha = 0
        return label

    }
}
