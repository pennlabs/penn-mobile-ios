//
//  PCRDetailController.swift
//  PennMobile
//
//  Created by Josh Doman on 3/31/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import UIKit

class PCRDetailViewController: UIViewController {
    
    var course: Course! {
        didSet {
            nameLabel.text = course.dept + " " + course.courseNum
            print(course.review)
            courseQuality.text = NSString(format: "%.01f", course.review.course) as String
            instructorQuality.text = NSString(format: "%.01f", course.review.inst) as String
            difficulty.text = NSString(format: "%.01f", course.review.diff) as String
        }
    }
    
    private let sideOffset: CGFloat = 20
    private let innerSpacing: CGFloat = 12
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.warmGrey
        label.font = UIFont(name: "HelveticaNeue", size: 24)
        return label
    }()
    
    private let courseQuality: UILabel = PCRDetailViewController.createRatingSquare(color: UIColor.paleTeal)
    private let courseQualityTitle: UILabel = PCRDetailViewController.createRatingLabel(type: "Course")
    
    private let instructorQuality: UILabel = PCRDetailViewController.createRatingSquare(color: UIColor.oceanBlue)
    private let instructorTitle: UILabel = PCRDetailViewController.createRatingLabel(type: "Instructor")
    
    private let difficulty: UILabel = PCRDetailViewController.createRatingSquare(color: UIColor.coral)
    private let difficultyTitle: UILabel = PCRDetailViewController.createRatingLabel(type: "Difficulty")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        let navBarHeight = (self.navigationController?.navigationBar.frame.size.height)!
        
        view.addSubview(nameLabel)
        view.addSubview(courseQuality)
        view.addSubview(instructorQuality)
        view.addSubview(difficulty)
        view.addSubview(courseQualityTitle)
        view.addSubview(instructorTitle)
        view.addSubview(difficultyTitle)
        
        _ = nameLabel.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, topConstant: navBarHeight + 50, leftConstant: sideOffset, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        let squareSize: CGFloat = calculateDetailSquareSize()
        
        _ = courseQuality.anchor(nameLabel.bottomAnchor, left: nameLabel.leftAnchor, bottom: nil, right: nil, topConstant: 30, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: squareSize, heightConstant: squareSize)
        
        _ = instructorQuality.anchor(courseQuality.topAnchor, left: courseQuality.rightAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: innerSpacing, bottomConstant: 0, rightConstant: 0, widthConstant: squareSize, heightConstant: squareSize)
        
        _ = difficulty.anchor(instructorQuality.topAnchor, left: instructorQuality.rightAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: innerSpacing, bottomConstant: 0, rightConstant: 0, widthConstant: squareSize, heightConstant: squareSize)
        
        _ = courseQualityTitle.centerXAnchor.constraint(equalTo: courseQuality.centerXAnchor).isActive = true
        _ = courseQualityTitle.topAnchor.constraint(equalTo: courseQuality.bottomAnchor, constant: 8).isActive = true
        
        _ = instructorTitle.centerXAnchor.constraint(equalTo: instructorQuality.centerXAnchor).isActive = true
        _ = instructorTitle.topAnchor.constraint(equalTo: courseQuality.bottomAnchor, constant: 8).isActive = true

        _ = difficultyTitle.centerXAnchor.constraint(equalTo: difficulty.centerXAnchor).isActive = true
        _ = difficultyTitle.topAnchor.constraint(equalTo: courseQuality.bottomAnchor, constant: 8).isActive = true
    }
    
    private func calculateDetailSquareSize() -> CGFloat {
        return (UIScreen.main.bounds.width - 2.0 * sideOffset - 2.0 * innerSpacing)/3.0
    }
    
    private static func createRatingSquare(color: UIColor) -> UILabel {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 40)
        label.backgroundColor = color
        label.layer.cornerRadius = 4
        label.layer.masksToBounds = true
        label.textAlignment = .center
        return label
    }
    
    private static func createRatingLabel(type: String) -> UILabel {
        let label = UILabel()
        label.textColor = UIColor.warmGrey
        label.font = UIFont(name: "HelveticaNeue", size: 20)
        label.text = type
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
}

