//
//  AboutViewController.swift
//  PennMobile
//
//  Created by Dominic Holmes on 12/30/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import Foundation

class AboutViewController: GenericViewController {
    
    private var panGesture: UIPanGestureRecognizer?
    
    private var beaker: BeakerLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "About"
        
        // Add views to the view controller, draw beaker
        layoutViews()
        
        // Initialize the pan gesture to control the water in beaker
        panGesture  = UIPanGestureRecognizer()
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.didPan(_:)))
        bgView.isUserInteractionEnabled = true
        bgView.addGestureRecognizer(panGesture!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let initialCP = CGPoint(x: -200, y: -50)
        if let _ = beaker {
            let newBeakerPath = beaker!.getBeakerPath(with: initialCP)
            beaker!.path = newBeakerPath
            beaker!.controlPoint = initialCP
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        releaseBeaker()
    }
    
    @objc func didPan(_ sender: UIPanGestureRecognizer){
        let translation = sender.translation(in: self.view)
        if sender.state == .began {
        } else if sender.state == .changed {
            adjustBeaker(with: translation)
        } else if sender.state == .ended {
            releaseBeaker()
        }
    }
    
    fileprivate func layoutViews() {
        // Background view
        self.view.addSubview(bgView)
        _ = bgView.anchor(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor,
                          topConstant: 60, leftConstant: 0, bottomConstant: 0, rightConstant: 0,
                          widthConstant: 0, heightConstant: 0)
        // Layout views
        bgView.addSubview(logoView)
        bgView.addSubview(descView)
        _ = logoView.anchor(bgView.topAnchor, left: bgView.leftAnchor,
                            bottom: nil, right: bgView.rightAnchor,
                            topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0,
                            widthConstant: 0, heightConstant: 170)
        _ = descView.anchor(logoView.bottomAnchor, left: logoView.leftAnchor,
                            bottom: bgView.bottomAnchor, right: logoView.rightAnchor,
                            topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0,
                            widthConstant: 0, heightConstant: 0)
        
        // Layout logo image view
        bgView.addSubview(labsLogoImageView)
        labsLogoImageView.translatesAutoresizingMaskIntoConstraints = false
        labsLogoImageView.centerXAnchor.constraint(
            equalTo: logoView.centerXAnchor).isActive = true
        labsLogoImageView.heightAnchor.constraint(equalToConstant: 100.0).isActive = true
        labsLogoImageView.widthAnchor.constraint(equalToConstant: 217.5).isActive = true
        labsLogoImageView.topAnchor.constraint(
            equalTo: logoView.topAnchor,
            constant: 40).isActive = true
        
        // Initialize & draw the beaker
        beaker = BeakerLayer()
        labsLogoImageView.layer.addSublayer(beaker!)
        labsLogoImageView.layer.addSublayer(beaker!.createParticles())
        labsLogoImageView.layer.addSublayer(beaker!.getGlassShapeLayer())
        
        // Labels
        bgView.addSubview(pennLabsLabel)
        pennLabsLabel.translatesAutoresizingMaskIntoConstraints = false
        pennLabsLabel.centerXAnchor.constraint(
            equalTo: descView.centerXAnchor).isActive = true
        pennLabsLabel.topAnchor.constraint(
            equalTo: descView.topAnchor).isActive = true
        
        bgView.addSubview(copyrightLabel)
        copyrightLabel.translatesAutoresizingMaskIntoConstraints = false
        copyrightLabel.centerXAnchor.constraint(
            equalTo: descView.centerXAnchor).isActive = true
        copyrightLabel.bottomAnchor.constraint(
            equalTo: descView.bottomAnchor,
            constant: -20).isActive = true
        
        bgView.addSubview(featureButton)
        bgView.addSubview(infoButton)
        featureButton.translatesAutoresizingMaskIntoConstraints = false
        infoButton.translatesAutoresizingMaskIntoConstraints = false
        featureButton.bottomAnchor.constraint(
            equalTo: copyrightLabel.topAnchor,
            constant: -10).isActive = true
        featureButton.centerXAnchor.constraint(
            equalTo: copyrightLabel.centerXAnchor,
            constant: -56).isActive = true
        infoButton.bottomAnchor.constraint(
            equalTo: copyrightLabel.topAnchor,
            constant: -10).isActive = true
        infoButton.centerXAnchor.constraint(
            equalTo: copyrightLabel.centerXAnchor,
            constant: 56).isActive = true
        
        bgView.addSubview(descriptionTextView)
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        descriptionTextView.widthAnchor.constraint(
            equalTo: descView.widthAnchor,
            constant: -20).isActive = true
        descriptionTextView.topAnchor.constraint(
            equalTo: pennLabsLabel.bottomAnchor,
            constant: 20).isActive = true
        descriptionTextView.centerXAnchor.constraint(
            equalTo: descView.centerXAnchor).isActive = true
        descriptionTextView.bottomAnchor.constraint(
            equalTo: featureButton.topAnchor,
            constant: -10).isActive = true
    }
    
    // Layout Views
    fileprivate let bgView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        return v
    }()
    
    fileprivate let logoView: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()
    
    fileprivate let descView: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()
    
    // Logo Image View
    fileprivate let labsLogoImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "LabsLogoNoBeaker"))
        iv.backgroundColor = .clear
        return iv
    }()
    
    // Labels & TextViews
    fileprivate let pennLabsLabel: UILabel = {
        let label = UILabel()
        label.text = "Built by students. For students."
        label.font = UIFont(name: "HelveticaNeue-Light", size: 18)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    fileprivate let descriptionTextView: UITextView = {
        let v = UITextView()
        v.isEditable = false
        v.isSelectable = false
        v.textContainer.maximumNumberOfLines = 0
        v.text = "Penn Labs is a non-profit, student-run organization at the University of Pennsylvania dedicated to building technology for student use and supporting an open-source development environment on-campus. Penn Labs is sponsored by the UA, the Provost’s Office and VPUL.\n\n Currently being developed by Josh Doman, Zhilei Zhang, and Dominic Holmes. Designed by Tiffany Chang, Josh Doman, Dominic Holmes, and Laura Gao. Special thanks to Yagil Burowski, Adel Qalieh, and everyone else who came before us."
        v.font = UIFont(name: "HelveticaNeue", size: 13)
        v.textColor = .darkGray
        v.textAlignment = .center
        v.backgroundColor = .clear
        v.isScrollEnabled = false
        return v
    }()
    
    fileprivate let featureButton: UIButton = {
        let b = UIButton(type: .system)
        b.contentRect(forBounds: CGRect(x: 0, y: 0, width: 150, height: 30))
        b.setTitle("Feature Request", for: .normal)
        b.setTitleColor(.buttonBlue, for: .normal)
        b.addTarget(self, action: #selector(featureRequest), for: .touchUpInside)
        return b
    }()
    
    fileprivate let infoButton: UIButton = {
        let b = UIButton(type: .system)
        b.contentRect(forBounds: CGRect(x: 0, y: 0, width: 150, height: 30))
        b.setTitle("More Info", for: .normal)
        b.setTitleColor(.buttonBlue, for: .normal)
        b.addTarget(self, action: #selector(moreInfo), for: .touchUpInside)
        return b
    }()
    
    fileprivate let copyrightLabel: UILabel = {
        let label = UILabel()
        label.text = "© 2018 Penn Labs"
        label.font = UIFont(name: "HelveticaNeue", size: 14)
        label.textColor = .darkGray
        label.textAlignment = .center
        return label
    }()
    
    // Beaker animations
    
    func adjustBeaker(with newControlPoint: CGPoint) {
        if let _ = beaker {
            let animation = CABasicAnimation(keyPath: "path")
            animation.fromValue = beaker!.path
            let newBeakerPath = beaker!.getBeakerPath(with: newControlPoint)
            animation.toValue = newBeakerPath
            animation.duration = 0.5
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            animation.isRemovedOnCompletion = false
            beaker!.add(animation, forKey: "animatePanGesture")
            beaker!.path = newBeakerPath
            beaker!.controlPoint = newControlPoint
        }
    }
    
    func releaseBeaker() {
        if let _ = beaker {
            let animation = CAKeyframeAnimation(keyPath: "path")
            let cx = beaker!.controlPoint.x
            let cy = beaker!.controlPoint.y
            let newBeakerPath = beaker!.getBeakerPath(with: CGPoint(x: 0, y: 0))
            animation.values = [
                beaker!.getBeakerPath(with: CGPoint(x:  cx / 1.0,  y:  cy / 1.0)),
                beaker!.getBeakerPath(with: CGPoint(x:  cx / 2.0,  y: -cy / 2.0)),
                beaker!.getBeakerPath(with: CGPoint(x:  cx / 4.0,  y:  cy / 4.0)),
                beaker!.getBeakerPath(with: CGPoint(x:  cx / 8.0,  y: -cy / 8.0)),
                beaker!.getBeakerPath(with: CGPoint(x:  cx / 16.0, y:  cy / 16.0)),
                beaker!.getBeakerPath(with: CGPoint(x:  0.0,       y: 0.0))
            ]
            animation.keyTimes = [0.0, 0.2, 0.4, 0.6, 0.8, 1.0]
            animation.duration = 1.1
            //animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            animation.isRemovedOnCompletion = false
            beaker!.add(animation, forKey: "animatePanGesture")
            beaker!.path = newBeakerPath
        }
    }
}

// Mark: Delete cell
extension AboutViewController: URLOpenable {
    @objc fileprivate func featureRequest() {
        open(scheme: "https://docs.google.com/forms/d/e/1FAIpQLSd1Ov_SDwjDKbPmOCNzOOjU5j1tqmvhXnMgGP2o-gcedvrYLA/viewform")
    }
    
    @objc fileprivate func moreInfo() {
        open(scheme: "http://pennlabs.org/")
    }
}
