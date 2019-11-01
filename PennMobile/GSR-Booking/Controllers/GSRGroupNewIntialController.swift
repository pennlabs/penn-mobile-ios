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
    fileprivate var colorCollectionView: UICollectionView!
    fileprivate var colors: [UIColor] = [UIColor(red: 32, green: 156, blue: 238),
                                         UIColor(red: 63, green: 170, blue: 109),
                                         UIColor(red: 255, green: 207, blue: 89),
                                         UIColor(red: 250, green: 164, blue: 50),
                                         UIColor(red: 226, green: 81, blue: 82),
                                         UIColor(red: 51, green: 101, blue: 143),
                                         UIColor(red: 131, green: 79, blue: 160)
                                         ]

    weak var delegate: GSRGroupController!


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        // Do any additional setup after loading the view.
        prepareUI()
    }
    override func viewDidAppear(_ animated: Bool) {
        colorCollectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: UICollectionView.ScrollPosition.centeredHorizontally)
        collectionView(colorCollectionView, didSelectItemAt: IndexPath(item: 0, section:0))

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


    func prepareNameField() {
        nameField = UITextField()
        nameField.placeholder = "New Group Name"
        nameField.textColor = UIColor.init(red: 216, green: 216, blue: 216)
        nameField.font = UIFont.boldSystemFont(ofSize: 24)
        //rgb 18 39 75
        nameField.textColor = UIColor(r: 18/255, g: 39/255, b: 75/255)
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
        createButton.layer.cornerRadius = 8
        createButton.layer.masksToBounds = true
        createButton.isEnabled = false
        createButton.addTarget(self, action: #selector(createGroupBtnAction), for: .touchUpInside)

        view.addSubview(createButton)
        createButton.topAnchor.constraint(equalTo: colorCollectionView.bottomAnchor, constant: 45).isActive = true
        createButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        createButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        createButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        createButton.translatesAutoresizingMaskIntoConstraints = false
    }

    func prepareColorLabel() {
        colorLabel = UILabel()
        colorLabel.text = "Pick a color:"
        colorLabel.font = UIFont.systemFont(ofSize: 17)
        colorLabel.textColor = UIColor.init(red: 153, green: 153, blue: 153)
        colorLabel.textAlignment = .center

        view.addSubview(colorLabel)
        colorLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        colorLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        colorLabel.topAnchor.constraint(equalTo: barView.bottomAnchor, constant: 35).isActive = true
        colorLabel.translatesAutoresizingMaskIntoConstraints = false
    }

    func prepareColorCollection() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        colorCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        colorCollectionView.register(GSRColorCell.self, forCellWithReuseIdentifier: GSRColorCell.identifier)
        colorCollectionView.backgroundColor = .clear
        colorCollectionView.showsHorizontalScrollIndicator = false
        colorCollectionView.delegate = self
        colorCollectionView.dataSource = self
        colorCollectionView.allowsSelection = true;
        colorCollectionView.allowsMultipleSelection = false
        colorCollectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: UICollectionView.ScrollPosition.centeredHorizontally)
        //collectionView(colorCollectionView, didSelectItemAt: IndexPath(item: 0, section:0))
        view.addSubview(colorCollectionView)

        colorCollectionView.topAnchor.constraint(equalTo: colorLabel.bottomAnchor, constant: 20).isActive = true
        colorCollectionView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        colorCollectionView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        colorCollectionView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        colorCollectionView.translatesAutoresizingMaskIntoConstraints = false
    }


    @objc func createGroupBtnAction(sender:UIButton!) {
        GSRGroupNetworkManager.instance.createGroup(name: nameField.text!, color: "color") { (success, errorMsg) in
            if success {
                delegate.fetchGroups()
                dismiss(animated: true, completion: nil)
            }
        }
        
//        delegate.addNewGroup(group: group)
        dismiss(animated: true, completion:nil)
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


protocol NewGroupInitialDelegate: GSRGroupController {
    func fetchGroups()
}

//Mark: Setup UI
extension GSRGroupNewIntialController {
    fileprivate func prepareUI() {
        prepareCloseButton()
        prepareNameField()
        prepareGroupForLabel()
        prepareSegmentedControl()
        prepareColorLabel()
        prepareColorCollection()
        prepareCreateButton()
    }
}

extension GSRGroupNewIntialController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GSRColorCell.identifier, for: indexPath) as! GSRColorCell
        cell.color = colors[indexPath.item % colors.count]
        return cell
    }

//    func collectionView(_ collectionView: UICollectionView,
//               layout collectionViewLayout: UICollectionViewLayout,
//               insetForSectionAt section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets(top: 0, left: 100, bottom: 0, right: 0)
//    }

//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let size = RoomCell.cellHeight - 12
//        return CGSize(width: size, height: size)
//    }
//
    // MARK: - Collection View Delegate Methods
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? GSRColorCell
        cell?.toggleBorder()
        createButton.isEnabled = true
        createButton.backgroundColor = cell?.colorView.backgroundColor
        colorLabel.textColor = cell?.colorView.backgroundColor
    }
//
//    //only enable selection for available rooms
//    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
//        let timeSlot = room.timeSlots[indexPath.row]
//        return timeSlot.isAvailable
//    }
//
    // Deselect this time slot and all select ones that follow it
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? GSRColorCell
        cell?.toggleBorder()
    }
}
