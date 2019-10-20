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
    
    
    
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

//Mark: Setup UI
extension GSRGroupNewIntialController {
    fileprivate func prepareUI() {
        prepareCloseButton()
        prepareNameField()
        prepareGroupForLabel()
    }
}
