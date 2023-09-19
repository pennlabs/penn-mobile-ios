//
//  HomePollsCell.swift
//  PennMobile
//
//  Created by Lucy Yuewei Yuan on 9/19/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

final class HomePollsCell: UITableViewCell, HomeCellConformable {
    var delegate: ModularTableViewCellDelegate!
    static var identifier: String = "pollsCell"

    var item: ModularTableViewItem! {
        didSet {
            guard let item = item as? HomePollsCellItem else { return }
            self.isUserInteractionEnabled = true
            responsesTableView.isUserInteractionEnabled = true
            self.pollQuestion = item.pollQuestion
        }
    }

    static func getCellHeight(for item: ModularTableViewItem) -> CGFloat {
        guard let item = item as? HomePollsCellItem else { return 0.0 }
//        let maxWidth = CGFloat(0.6) * UIScreen.main.bounds.width
        var totalHeight: CGFloat = 63 + HomePollsCellFooter.height + 28 + 8

        for i in 0..<item.pollQuestion.options.count {
            totalHeight += height(forOption: item.pollQuestion.options[i])
        }

        return CGFloat(totalHeight)
    }
    
    static func getPollHeight(for pollQuestion: PollQuestion) -> CGFloat {
        var totalHeight: CGFloat = 63 + HomePollsCellFooter.height + 28 + 8

        for i in 0..<pollQuestion.options.count {
            totalHeight += HomePollsCell.height(forOption: pollQuestion.options[i])
        }

        return totalHeight + HomeViewController.cellSpacing
    }

    var pollQuestion: PollQuestion! {
        didSet {
            setupCell(with: pollQuestion)
            responsesTableView.reloadData()
        }
    }
    // MARK: - UI Elements
    var cardView: UIView! = UIView()
    fileprivate var safeArea: HomeCellSafeArea = HomeCellSafeArea()
    fileprivate var header: HomePollsCellHeader = HomePollsCellHeader()
    fileprivate var footer: HomePollsCellFooter = HomePollsCellFooter()
    fileprivate var responsesTableView: UITableView!
    fileprivate var ddlLabel: UILabel!

    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        prepareHomeCell()
        prepareUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup UI Elements
extension HomePollsCell {
    fileprivate func setupCell(with pollQuestion: PollQuestion) {
        header.secondaryTitleLabel.text = "Poll FROM \(pollQuestion.clubCode)"
        header.primaryTitleLabel.text = pollQuestion.question
        header.voteCountLabel.text = "\(pollQuestion.totalVoteCount) Vote\(pollQuestion.totalVoteCount != 1 ? "s" : "")"
        setupDdlLabel(with: pollQuestion.expireDate)
    }

    fileprivate func setupDdlLabel(with ddl: Date) {
        let diffComponents = Calendar.current.dateComponents([.day, .hour, .minute], from: Date(), to: ddl)
        let d = diffComponents.day
        let h = diffComponents.hour
        let mm = diffComponents.minute
        ddlLabel.text = ""
        if d! > 0 {
            ddlLabel.text = "\(d ?? 0)d"
        }
        if h! > 0 {
            ddlLabel.text = "\(ddlLabel.text ?? "") \(h ?? 0) h"
        }
        if mm! > 0 {
            ddlLabel.text = "\(ddlLabel.text ?? "") \(mm ?? 0) m"
        }

    }

}

// MARK: - Initialize & Layout UI Elements
extension HomePollsCell {
    fileprivate func prepareUI() {
        prepareSafeArea()
        prepareHeader()
        prepareFooter()
        prepareDdlLabel()
        prepareTableView()
    }

    // MARK: Safe Area and Header
    fileprivate func prepareSafeArea() {
        cardView.addSubview(safeArea)
        safeArea.prepare()
    }

    fileprivate func prepareHeader() {
        safeArea.addSubview(header)
        header.prepare()
    }

    fileprivate func prepareFooter() {
        safeArea.addSubview(footer)
        footer.prepare()
    }

    // MARK: DDL Label
    fileprivate func prepareDdlLabel() {
        ddlLabel = getDdlLabel()
        cardView.addSubview(ddlLabel)
        ddlLabel.snp.makeConstraints { (make) in
            make.trailing.equalTo(safeArea).offset(-3)
            make.top.equalTo(safeArea)
        }
        header.secondaryTitleLabel.snp.makeConstraints { (make) in
            make.trailing.lessThanOrEqualTo(ddlLabel.snp.leading).offset(-3)
            make.top.equalTo(safeArea)
        }
    }

    // MARK: TableView
    fileprivate func prepareTableView() {
        responsesTableView = getTableView()
        responsesTableView.backgroundColor = .uiCardBackground
        responsesTableView.rowHeight = UITableView.automaticDimension
        cardView.addSubview(responsesTableView)
        responsesTableView.snp.makeConstraints { (make) in
            make.leading.equalTo(cardView)
            make.top.equalTo(header.snp.bottom).offset(5)
            make.trailing.equalTo(cardView)
            make.bottom.equalTo(footer.snp.top).offset(-5)
        }
    }
}

extension HomePollsCell: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Deselect and prohibit user from selecting another cell
        tableView.deselectRow(at: indexPath, animated: false)
        tableView.isUserInteractionEnabled = false
        let pollOptionId = self.pollQuestion.options[indexPath.row].id
        Task {
            let success = await PollsNetworkManager.instance.answerPoll(withId: PollsNetworkManager.id, response: pollOptionId)
            if success {
                DispatchQueue.main.async {
                    self.pollQuestion.options[indexPath.row].voteCount += 1
                    // Change selected cell to chosen
                    let chosenCell = (tableView.cellForRow(at: indexPath) as! PollOptionCell)
                    chosenCell.pollOption.voteCount += 1
                    chosenCell.chosen = true
                    
                    // Update cells to reflect question answered
                    for cell in tableView.visibleCells as! [PollOptionCell] {
                        cell.totalResponses += 1
                        cell.answered = true
                    }
                    
                    // Update model
                    self.pollQuestion.optionChosenId = self.pollQuestion.options[indexPath.row].id
                }
                
                // TODO: Send Network Request to reflect changes
            } else {
                print("not changing chosen")
                // TODO: Show error
            }
        }
    }

    static func height(forOption option: PollOption) -> CGFloat {
        let maxWidth = CGFloat(0.6) * UIScreen.main.bounds.width
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: maxWidth, height: CGFloat.greatestFiniteMagnitude))

        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.text = option.choice
        label.font = .primaryInformationFont
        label.textColor = .labelPrimary
        label.textAlignment = .left
        label.numberOfLines = 0
        label.sizeToFit()
        return label.frame.height + Padding.pad * 1 + 22
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        HomePollsCell.height(forOption: pollQuestion.options[indexPath.row])
    }
}

extension HomePollsCell: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pollQuestion?.options.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PollOptionCell.identifier, for: indexPath) as! PollOptionCell
        let pollOption = pollQuestion.options[indexPath.row]

        cell.totalResponses = pollQuestion.totalVoteCount
        cell.answered = (pollQuestion.optionChosenId != nil)
        cell.chosen = pollQuestion.optionChosenId == pollOption.id

        cell.pollOption = pollOption

        return cell
    }
}

extension HomePollsCell {
    fileprivate func getTableView() -> UITableView {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.register(PollOptionCell.self, forCellReuseIdentifier: PollOptionCell.identifier)
        return tableView
    }

    private func getVoteCountLabel() -> UILabel {
        let label = UILabel()
        label.font = .secondaryTitleFont
        label.textColor = .labelSecondary
        label.textAlignment = .left
        return label
    }

    private func getDdlLabel() -> UILabel {
        let label = UILabel()
        label.font = .secondaryTitleFont
        label.textColor = .labelSecondary
        label.textAlignment = .left
        return label
    }
}
