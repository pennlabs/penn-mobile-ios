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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        guard let bar = bar else { return }
        bar.makeHiddenTimeRange = nil
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

        UIView.animate(withDuration: 0.5, animations: {
            self.bar!.transform = CGAffineTransform(translationX: 0, y: CGFloat(self.bar!.height))
        }) { _ in
            //self.bar!.timerIsValid = true
        }
        
        bar!.barHideTime = DispatchTime.now()
        bar!.makeHiddenTimeRange = [DispatchTime.now() + 2.5, DispatchTime.now() + 3.5]
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            guard let bar = self.bar, bar.makeHiddenTimeRange != nil else { return }
            print(bar.makeHiddenTimeRange![0] < DispatchTime.now() && bar.makeHiddenTimeRange![1] > DispatchTime.now())
            print(bar.makeHiddenTimeRange![0])
            print(DispatchTime.now())
            print(bar.makeHiddenTimeRange![1])
            if !bar.isHidden && bar.makeHiddenTimeRange![0] < DispatchTime.now() && bar.makeHiddenTimeRange![1] > DispatchTime.now() {
                self.hideBar(animated: true)
            }
        }
    }
    
    func hideBar(animated: Bool) {
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
