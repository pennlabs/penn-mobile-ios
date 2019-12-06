//
//  GSRGroupInviteViewController.swift
//  PennMobile
//
//  Created by Lucy Yuewei Yuan on 11/3/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//
//Users/lucyyyw/Desktop/pennlabs/penn-mobile-ios/PennMobile/GSR-Booking/Controllers/GSRLocationsController.swift
import UIKit

class GSRGroupInviteViewController: UIViewController {
    
    fileprivate var dummyLabel: UILabel!
    fileprivate var doneBtn : UIButton!
    fileprivate var closeButton: UIButton!
    fileprivate var inViteUsersLabel: UILabel!
    fileprivate var searchBar: UISearchBar!
    fileprivate var sendInvitesButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        prepareUI()
        // Do any additional setup after loading the view.
    }
    
    func prepareCloseButton() {
        closeButton = UIButton()
        view.addSubview(closeButton)

        closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 40).isActive = true
        closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        closeButton.backgroundColor = UIColor(red: 118/255, green: 118/255, blue: 128/255, alpha: 12/100)
        closeButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        closeButton.layer.cornerRadius = 15
        closeButton.layer.masksToBounds = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setTitle("x", for: UIControl.State.normal)
        //closeButton.setImage(image: , for: UIControl.State.normal)
        closeButton.addTarget(self, action: #selector(cancelBtnAction), for: .touchUpInside)
    }
    
    func prepareInViteUsersLabel() {
        inViteUsersLabel = UILabel()
        inViteUsersLabel.text = "Invite User"
        inViteUsersLabel.font = UIFont.boldSystemFont(ofSize: 24)
        view.addSubview(inViteUsersLabel)
        inViteUsersLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 14).isActive = true
        inViteUsersLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 79.5).isActive = true
        inViteUsersLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    @objc func cancelBtnAction(sender:UIButton!) {
        dismiss(animated: true, completion:nil)
    }
    
    func prepareSearchBar() {
        searchBar = UISearchBar()
        searchBar.searchTextField.placeholder = "Search by Name or PennKey"
        searchBar.searchTextField.textColor = UIColor.init(red: 216, green: 216, blue: 216)
        view.addSubview(searchBar)
        searchBar.topAnchor.constraint(equalTo: inViteUsersLabel.bottomAnchor, constant: 30).isActive = true
        searchBar.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8).isActive = true
        searchBar.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8).isActive = true
        searchBar.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func prepareSendInvitationButton() {
        sendInvitesButton = UIButton()
        sendInvitesButton.backgroundColor = UIColor(red:32/255.0, green:156/255.0, blue:238/255.0, alpha:0.5)
        sendInvitesButton.setTitle("Send Invites", for: .normal)
        sendInvitesButton.setTitleColor(UIColor.white, for: .normal)
        sendInvitesButton.titleLabel?.font =  UIFont.boldSystemFont(ofSize: 17)
        sendInvitesButton.layer.cornerRadius = 8
        sendInvitesButton.layer.masksToBounds = true
        
        view.addSubview(sendInvitesButton)
        sendInvitesButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30).isActive = true
        sendInvitesButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 14).isActive = true
        sendInvitesButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -14).isActive = true
        sendInvitesButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        sendInvitesButton.translatesAutoresizingMaskIntoConstraints = false
        
        sendInvitesButton.isEnabled = false
        sendInvitesButton.isUserInteractionEnabled = false
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
extension GSRGroupInviteViewController {
    fileprivate func prepareUI() {
        prepareCloseButton()
        prepareInViteUsersLabel()
        prepareSearchBar()
        prepareSendInvitationButton()
    }
}
