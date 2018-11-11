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
    fileprivate var animateBarDispatchItem: DispatchWorkItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // Adds a status bar and animates it down
    func addStatusBar(text: StatusBar.statusBarText) {
        bar?.removeFromSuperview()
        bar = StatusBar(text: text)
        setupBar(text: text)
        animateBarDown()
    }
    
    fileprivate func animateBarDown() {
        guard bar != nil else { return }
        bar!.isHidden = false

        UIView.animate(withDuration: 0.5) {
            self.bar!.transform = CGAffineTransform(translationX: 0, y: CGFloat(self.bar!.height))
        }
        
        // Make a dispatch item, and schedule it for 3 seconds in the future. The dispatch item becomes invalid if the view disappears.
        animateBarDispatchItem = DispatchWorkItem(block: {
            guard let bar = self.bar else { return }
            if !bar.isHidden {
                self.hideBar(animated: true)
            }
        })
        guard animateBarDispatchItem != nil else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: animateBarDispatchItem!)
    }
    
    func hideBar(animated: Bool) {
        // Cancel any in-flight timers that would call hideBar() a second time upon returning to the screen
        if animateBarDispatchItem != nil {
            animateBarDispatchItem!.cancel()
        }
        // Hide the bar
        guard bar != nil else { return }
        if (animated) {
            UIView.animate(withDuration: 0.5, animations: {
                self.bar!.transform = CGAffineTransform(translationX: 0, y: CGFloat(-1 * self.bar!.height))
                }, completion: { (didComplete) in
                    self.bar!.isHidden = true
                })
        } else {
            self.bar!.transform = CGAffineTransform(translationX: 0, y: CGFloat(-1 * self.bar!.height))
            self.bar!.isHidden = true
        }
    }
    
    func setupBar(text: StatusBar.statusBarText) {
        self.view.insertSubview(bar!, belowSubview: self.navigationBar)
        bar!.translatesAutoresizingMaskIntoConstraints = false
        bar!.topAnchor.constraint(equalTo: self.navigationBar.bottomAnchor, constant: text == .noInternet ? -50 : -70 ).isActive = true
        bar!.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        bar!.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
    }
}
