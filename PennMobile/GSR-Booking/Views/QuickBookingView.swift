//
//  QuickBookingView.swift
//  PennMobile
//
//  Created by Kaitlyn Kwan on 11/10/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

// Views/QuickBookingView.swift
import UIKit

public class QuickBookingView: UIView {
    
    static let instance = QuickBookingView()
    
    // UI Elements
    public let bookButton = UIButton(type: .system)
    public let submitButton = UIButton(type: .system)
    public let unpreferButton = UIButton(type: .system)
    public let roomLabel = UILabel()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    func setupUI() {
        setupBookButton()
        setupSubmitButton()
        setupUnpreferButton()
        setupRoomLabel()
    }
    
    private func setupRoomLabel() {
        roomLabel.backgroundColor = UIColor.lightGray.withAlphaComponent(0.8)
        roomLabel.layer.masksToBounds = true
        roomLabel.layer.cornerRadius = 10
        roomLabel.textAlignment = .center
        roomLabel.textColor = .black
        roomLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        roomLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(roomLabel)
        
        NSLayoutConstraint.activate([
            roomLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 180),
            roomLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            roomLabel.widthAnchor.constraint(equalToConstant: 300)
        ])
    }
    
    private func setupBookButton() {
        bookButton.setTitle("Find GSR", for: .normal)
        bookButton.setTitleColor(UIColor(named: "labelPrimary"), for: .normal)
        bookButton.backgroundColor = UIColor(named: "baseLabsBlue")
        bookButton.layer.cornerRadius = 15
        bookButton.layer.shadowColor = UIColor.black.cgColor
        bookButton.layer.shadowOpacity = 0.3
        bookButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        bookButton.layer.shadowRadius = 5
        bookButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bookButton)
        
        NSLayoutConstraint.activate([
            bookButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 100),
            bookButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            bookButton.widthAnchor.constraint(equalToConstant: 200),
            bookButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupSubmitButton() {
        submitButton.setTitle("Submit", for: .normal)
        submitButton.setTitleColor(UIColor(named: "labelPrimary"), for: .normal)
        submitButton.backgroundColor = UIColor(named: "baseGreen")
        submitButton.layer.cornerRadius = 15
        submitButton.layer.shadowColor = UIColor.black.cgColor
        submitButton.layer.shadowOpacity = 0.3
        submitButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        submitButton.layer.shadowRadius = 5
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(submitButton)
        
        NSLayoutConstraint.activate([
            submitButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 600),
            submitButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            submitButton.widthAnchor.constraint(equalToConstant: 300),
            submitButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupUnpreferButton() {
        unpreferButton.setTitle("Preferred Location", for: .normal)
        unpreferButton.setTitleColor(UIColor(named: "labelPrimary"), for: .normal)
        unpreferButton.backgroundColor = UIColor(named: "baseLabsBlue")
        unpreferButton.layer.cornerRadius = 15
        unpreferButton.layer.shadowColor = UIColor.black.cgColor
        unpreferButton.layer.shadowOpacity = 0.3
        unpreferButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        unpreferButton.layer.shadowRadius = 5
        unpreferButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(unpreferButton)
        
        NSLayoutConstraint.activate([
            unpreferButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
            unpreferButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            unpreferButton.widthAnchor.constraint(equalToConstant: 300),
            unpreferButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    public func updateRoomLabel(startTime: String, endTime: String, roomName: String?, locationName: String?) {
        roomLabel.text = """
            Soonest available GSR:
            Time Slot: \(startTime) to \(endTime)
            Room: \(roomName ?? "N/A")
            Location: \(locationName ?? "N/A")
        """
    }
}
