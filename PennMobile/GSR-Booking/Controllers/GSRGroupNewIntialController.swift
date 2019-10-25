//
//  GSRGroupNewIntialController.swift
//  PennMobile
//
//  Created by Lucy Yuewei Yuan on 10/18/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import UIKit

class GSRGroupNewIntialController: UIViewController {

    fileprivate var closeButton: UIButton!
    fileprivate var nameField: UITextField!
    fileprivate var groupForLabel: UILabel!
    fileprivate var barView: UISegmentedControl!
    fileprivate var colorLabel: UILabel!
    fileprivate var colorPanel: UIView!
    fileprivate var createButton: UIButton!
    
    weak var delegate: GSRGroupController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        // Do any additional setup after loading the view.
        prepareUI()
    }
    
    func prepareCloseButton() {
        closeButton = UIButton()
        //closeButton.setImage(image: , for: UIControl.State.normal)
    }
    
    
    func prepareNameField() {
        nameField = UITextField()
        nameField.placeholder = "New Group Name"
        nameField.textColor = UIColor.init(red: 216, green: 216, blue: 216)
        nameField.font = UIFont.boldSystemFont(ofSize: 24)
        nameField.keyboardType = .alphabet
        nameField.textAlignment = .natural
        nameField.autocorrectionType = .no
        nameField.spellCheckingType = .no
        nameField.autocapitalizationType = .none
        view.addSubview(nameField)
        nameField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 14).isActive = true
        nameField.topAnchor.constraint(equalTo: view.topAnchor, constant: 79.5).isActive = true
        nameField.translatesAutoresizingMaskIntoConstraints = false
        
    }
    
    func prepareGroupForLabel() {
        groupForLabel = UILabel()
        groupForLabel.text = "Who is this group for?"
        groupForLabel.font = UIFont.systemFont(ofSize: 17)
        groupForLabel.textColor = UIColor.init(red: 153, green: 153, blue: 153)
        groupForLabel.textAlignment = .center
        view.addSubview(groupForLabel)
        groupForLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        groupForLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        groupForLabel.topAnchor.constraint(equalTo:nameField.bottomAnchor, constant: 35).isActive = true
        groupForLabel.translatesAutoresizingMaskIntoConstraints = false
        
    }
    
    func prepareSegmentedControl() {
        let items = ["Friends","Classmates","Club"]
        barView = UISegmentedControl(items: items)
        let font = UIFont.systemFont(ofSize: 14,weight: .semibold)
        barView.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: font] ,for: .normal)
        barView.backgroundColor = UIColor.init(red: 216, green: 216, blue: 216)
        barView.layer.borderWidth = 1
        barView.layer.borderColor = UIColor.init(red: 216, green: 216, blue: 216).cgColor
        barView.layer.cornerRadius = 6.9
        barView.layer.masksToBounds = true
        
        barView.tintColor = UIColor.init(red: 153, green: 153, blue: 153)
        
        barView.selectedSegmentIndex = 0
        
        view.addSubview(barView)
        barView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true
        barView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
        barView.topAnchor.constraint(equalTo: groupForLabel.bottomAnchor, constant: 14).isActive = true
        barView.translatesAutoresizingMaskIntoConstraints = false
        
    }
    
    func prepareCreateButton() {
        createButton = UIButton()
        createButton.backgroundColor = UIColor.init(red: 216, green: 216, blue: 216)
        createButton.setTitle("Create Group", for: .normal)
        createButton.setTitleColor(UIColor.white, for: .normal)
        createButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        
        view.addSubview(createButton)
        createButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 345.5).isActive = true
        createButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        createButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        createButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        createButton.translatesAutoresizingMaskIntoConstraints = false
        
    }
    
    @objc func buttonAction(sender:UIButton!) {
        let group = GSRGroup(id: "some id", name: nameField.text!, imgURL: nil, color: "yello", owners: [], members: [], createdAt: Date(), isActive: false, reservations: [])
        delegate.addNewGroup(group: group)
        dismiss(animated: true, completion:nil)
    }
    
    
    
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


protocol NewGroupInitialDelegate: GSRGroupController {
    func addNewGroup(group:GSRGroup)
}

//Mark: Setup UI
extension GSRGroupNewIntialController {
    fileprivate func prepareUI() {
        prepareCloseButton()
        prepareNameField()
        prepareGroupForLabel()
        prepareSegmentedControl()
        prepareCreateButton()
    }
}
