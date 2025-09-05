//
//  SearchResultsCell.swift
//  PennMobile
//
//  Created by Raunaq Singh on 12/26/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import Foundation
import UIKit

class SearchResultsCell: UITableViewCell {

    static let cellHeight: CGFloat = 74
    static let noInstructorCellHeight: CGFloat = 60
    static let identifier = "searchResultsCell"

    fileprivate var detailLabel: UILabel!
    fileprivate var courseLabel: UILabel!
    fileprivate var instructorsLabel: UILabel!

    var section: CourseSection! {
        didSet {
            setupCell()
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup Cell
extension SearchResultsCell {
    fileprivate func setupCell() {
        if detailLabel == nil || courseLabel == nil {
            setupUI()
        } else {
            courseLabel.text = section.section
            detailLabel.text = section.courseTitle
            instructorsLabel.text = (section.instructors.map { $0.name }).joined(separator: ", ")
        }
    }
}

// MARK: - Setup UI
extension SearchResultsCell {
    fileprivate func setupUI() {
        prepareCourseLabel()
        prepareDetailLabel()
        prepareInstructorsLabel()
    }

    fileprivate func prepareCourseLabel() {
        courseLabel = UILabel()
        courseLabel.font = UIFont.interiorTitleFont
        addSubview(courseLabel)
        courseLabel.translatesAutoresizingMaskIntoConstraints = false
        courseLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15).isActive = true
        courseLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
    }

    fileprivate func prepareDetailLabel() {
        detailLabel = UILabel()
        detailLabel.font = UIFont.secondaryInformationFont
        detailLabel.textColor = UIColor.grey1
        addSubview(detailLabel)
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        detailLabel.leadingAnchor.constraint(equalTo: courseLabel.leadingAnchor).isActive = true
        detailLabel.topAnchor.constraint(equalTo: courseLabel.bottomAnchor, constant: 4).isActive = true
        detailLabel.widthAnchor.constraint(equalTo: widthAnchor, constant: -40).isActive = true
    }

    fileprivate func prepareInstructorsLabel() {
        instructorsLabel = UILabel()
        instructorsLabel.font = UIFont.footerDescriptionFont
        instructorsLabel.textColor = UIColor.grey1
        addSubview(instructorsLabel)
        instructorsLabel.translatesAutoresizingMaskIntoConstraints = false
        instructorsLabel.leadingAnchor.constraint(equalTo: detailLabel.leadingAnchor).isActive = true
        instructorsLabel.topAnchor.constraint(equalTo: detailLabel.bottomAnchor, constant: 3).isActive = true
        instructorsLabel.widthAnchor.constraint(equalTo: widthAnchor, constant: -40).isActive = true
    }

}
