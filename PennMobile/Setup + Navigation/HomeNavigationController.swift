//
//  HomeNavigationController.swift
//  PennMobile
//
//  Created by Daniel Salib on 10/28/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import UIKit

class HomeNavigationController: UINavigationController {
    
    fileprivate var bar: StatusBar?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //adds a status bar and animates it down
    func addStatusBar(text: StatusBar.statusBarText) {
        bar?.removeFromSuperview()
        bar = StatusBar(text: text)
        setupBar(text: text)
        animateBarDown()
    }
    
    fileprivate func animateBarDown() {
        guard bar != nil else { return }
        bar!.notClear()
        UIView.animate(withDuration: 0.5) {
            self.bar!.transform = CGAffineTransform(translationX: 0, y: CGFloat(self.bar!.height))
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.hideBar(animated: true)
        }
    }
    
    func hideBar(animated: Bool) {
        guard bar != nil else { return }
        if (animated) {
//            UIView.animate(withDuration: 0.5) {
//
//                self.bar!.makeClear()
//            }
            UIView.animate(withDuration: 0.5, animations: {
                    self.bar!.transform = CGAffineTransform(translationX: 0, y: CGFloat(-1 * self.bar!.height))
            }) { (success) in
                self.bar!.makeClear() //dom check out this func in StatusBar.swift
            }
        } else {
            self.bar!.transform = CGAffineTransform(translationX: 0, y: CGFloat(-1 * self.bar!.height))
        }
//        bar!.makeClear()
    }
    
    func setupBar(text: StatusBar.statusBarText) {
        self.view.insertSubview(bar!, belowSubview: self.navigationBar)
        bar!.translatesAutoresizingMaskIntoConstraints = false
        bar!.topAnchor.constraint(equalTo: self.navigationBar.bottomAnchor, constant: text == .noInternet ? -50 : -70 ).isActive = true
        bar!.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        bar!.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
    }
}
