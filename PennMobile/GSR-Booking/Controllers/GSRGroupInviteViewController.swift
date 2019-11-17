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
    
    @objc func cancelBtnAction(sender:UIButton!) {
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

//Mark: Setup UI
extension GSRGroupInviteViewController {
    fileprivate func prepareUI() {
        prepareCloseButton()
    }
}
