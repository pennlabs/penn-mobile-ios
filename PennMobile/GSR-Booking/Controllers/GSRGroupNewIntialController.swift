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
    fileprivate var colors: [UIColor] = [.allbirdsGrey, .oceanBlue, .redingTerminal, .dataGreen]
    
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
        createButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        
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
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        colorCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        colorCollectionView.register(GSRColorCell.self, forCellWithReuseIdentifier: GSRColorCell.identifier)
        colorCollectionView.backgroundColor = .clear
        colorCollectionView.showsHorizontalScrollIndicator = false
        colorCollectionView.delegate = self
        colorCollectionView.dataSource = self
        colorCollectionView.allowsMultipleSelection = false
        
        view.addSubview(colorCollectionView)
        
        colorCollectionView.topAnchor.constraint(equalTo: colorLabel.bottomAnchor, constant: 20).isActive = true
        colorCollectionView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        colorCollectionView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        colorCollectionView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        colorCollectionView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    @objc func buttonAction(sender:UIButton!) {
        let group = GSRGroup(groupID: "new", groupName: nameField.text!, createdAt: Date(), isActive: true, members: [GSRGroupMember(accountID: "dummyOwner", first: "DummyF", last: "DummyL", email: "yuewei@seas.upenn.edu", enabled: true)])
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
//    // MARK: - Collection View Delegate Methods
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let timeSlot = room.timeSlots[indexPath.row]
//        delegate?.handleSelection(for: room, timeSlot: timeSlot, action: SelectionType.add)
//        let cell = collectionView.cellForItem(at: indexPath)
//        cell?.backgroundColor = .informationYellow
//    }
//
//    //only enable selection for available rooms
//    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
//        let timeSlot = room.timeSlots[indexPath.row]
//        return timeSlot.isAvailable
//    }
//
//    // Deselect this time slot and all select ones that follow it
//    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
//        var currTimeSlot = room.timeSlots[indexPath.row]
//        var currIndex = indexPath
//        while delegate.containsTimeSlot(currTimeSlot) {
//            collectionView.deselectItem(at: currIndex, animated: false)
//            delegate?.handleSelection(for: room, timeSlot: currTimeSlot, action: SelectionType.remove)
//            let cell = collectionView.cellForItem(at: currIndex)
//            cell?.backgroundColor = .interactionGreen
//
//            currIndex = IndexPath(row: currIndex.row + 1, section: currIndex.section)
//            if let nextTimeSlot = currTimeSlot.next {
//                currTimeSlot = nextTimeSlot
//            } else {
//                break
//            }
//        }
//    }
}
