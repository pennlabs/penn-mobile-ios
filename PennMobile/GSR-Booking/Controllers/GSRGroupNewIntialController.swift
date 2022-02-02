//
//  GSRGroupNewIntialController.swift
//  PennMobile
//
//  Created by Lucy Yuewei Yuan on 10/18/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import UIKit

protocol NewGroupInitialDelegate: GSRGroupController {
    func fetchGroups()
}

class GSRGroupNewIntialController: UIViewController {

    fileprivate var closeButton: UIButton!
    fileprivate var nameField: UITextField!
    fileprivate var groupForLabel: UILabel!
    fileprivate var barView: UISegmentedControl!
    fileprivate var colorLabel: UILabel!
    fileprivate var colorPanel: UIView!
    fileprivate var createButton: UIButton!
    fileprivate var colorCollectionView: UICollectionView!
    fileprivate var colors: [UIColor] = [
        UIColor.baseBlue,
        UIColor.baseGreen,
        UIColor.baseYellow,
        UIColor.baseOrange,
        UIColor.baseRed,
        UIColor.blueDarker
    ]

    fileprivate var chosenColor: UIColor!
    fileprivate var nameChanged: Bool!

    fileprivate var colorNames: [String] = ["Labs Blue", "College Green", "Locust Yellow", "Cheeto Orange", "Red-ing Terminal", "Baltimore Blue", "Purple"]

    weak var delegate: NewGroupInitialDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        // Do any additional setup after loading the view.
        prepareUI()
    }
    override func viewDidAppear(_ animated: Bool) {
        colorCollectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: UICollectionView.ScrollPosition.centeredHorizontally)
        //collectionView(colorCollectionView, didSelectItemAt: IndexPath(item: 0, section:0))

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

        nameField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControl.Event.editingChanged)

    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        if (textField.text != "" && textField.text != "New Group Name") {
            createButton.isUserInteractionEnabled = true
            if (chosenColor != nil) {
                createButton.backgroundColor = chosenColor
            } else {
                createButton.backgroundColor = UIColor.init(red: 216, green: 216, blue: 216)
            }
            nameChanged = true

        } else {
            createButton.isUserInteractionEnabled = false
            createButton.backgroundColor = UIColor.init(red: 216, green: 216, blue: 216)
            nameChanged = false
        }
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
        groupForLabel.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: 35).isActive = true
        groupForLabel.translatesAutoresizingMaskIntoConstraints = false
    }

    func prepareSegmentedControl() {
        let items = ["Friends", "Classmates", "Club"]
        barView = UISegmentedControl(items: items)
        let font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        barView.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: font], for: .normal)
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

        //button unclickable until group name changed and not empty
        createButton.isUserInteractionEnabled = false
        nameChanged = false
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
        colorCollectionView.allowsSelection = true
        colorCollectionView.allowsMultipleSelection = false
        colorCollectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: UICollectionView.ScrollPosition.centeredHorizontally)
        view.addSubview(colorCollectionView)

        colorCollectionView.topAnchor.constraint(equalTo: colorLabel.bottomAnchor, constant: 20).isActive = true
        colorCollectionView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30).isActive = true
        colorCollectionView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        colorCollectionView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        colorCollectionView.translatesAutoresizingMaskIntoConstraints = false
    }

    @objc func createGroupBtnAction(sender: UIButton!) {
        //TODO: Consider adding appropriate error messages
        guard let name = nameField.text else {return}
        guard let color = colorLabel.text else {return}

        GSRGroupNetworkManager.instance.createGroup(name: name, color: color) { (success, errorMsg) in
            if success {

                // This reloads the groups on the GSRGroupController - this should be done after invites / end of the flow
                // self.delegate.fetchGroups()

                DispatchQueue.main.async {
                    let controller = GSRGroupInviteViewController()
                    self.navigationController?.pushViewController(controller, animated: true)
                }
            }
        }
    }

    @objc func cancelBtnAction(sender: UIButton!) {
        self.delegate.fetchGroups()
        dismiss(animated: true, completion: nil)
    }
}

// MARK: Setup UI
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
        return 7
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GSRColorCell.identifier, for: indexPath) as! GSRColorCell
        let color = colors[indexPath.item % colors.count]
        cell.color = color
        cell.borderColor = color.borderColor(multiplier: 1.5)
        return cell
    }

    // MARK: - Collection View Delegate Methods
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? GSRColorCell
        cell?.toggleBorder()
        createButton.isEnabled = true
        if (nameChanged) {
            createButton.backgroundColor = cell?.colorView.backgroundColor
        } else {
            createButton.backgroundColor = UIColor.init(red: 216, green: 216, blue: 216)
        }
        chosenColor = cell?.colorView.backgroundColor
        colorLabel.textColor = cell?.colorView.backgroundColor
        colorLabel.text = colorNames[indexPath.item % colorNames.count]
        colorLabel.font = UIFont.boldSystemFont(ofSize: 17)
    }

    // Deselect this time slot and all select ones that follow it
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? GSRColorCell
        cell?.toggleBorder()
    }
}

extension UIColor {

    //for getting a lighter variant (using a multiplier)
    func borderColor(multiplier: CGFloat) -> UIColor {
        let rgba = self.rgba
        return UIColor(red: rgba.red * multiplier, green: rgba.green * multiplier, blue: rgba.blue * multiplier, alpha: rgba.alpha)
    }

    //https://www.hackingwithswift.com/example-code/uicolor/how-to-read-the-red-green-blue-and-alpha-color-components-from-a-uicolor
    var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        //returns rgba colors.
        return (red, green, blue, alpha)
    }
}
