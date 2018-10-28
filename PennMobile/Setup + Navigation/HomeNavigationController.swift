//
//  HomeNavigationController.swift
//  PennMobile
//
//  Created by Daniel Salib on 10/28/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import UIKit

class HomeNavigationController: UINavigationController {
    
    fileprivate var bar: statusBar?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    func addStatusBar(text: statusBar.statusBarText) {
        bar = statusBar(text: text)
        setupBar(text: text)
    }
    
    func animateBarDown() {
        if (bar == nil) {
            return
        }
        
        UIView.animate(withDuration: 0.5) {
            self.bar!.transform = CGAffineTransform(translationX: 0, y: CGFloat(self.bar!.height))
        }
    }
    
    @objc fileprivate func collapseBar(_ recognizer: UITapGestureRecognizer?) {
        if (bar == nil) {
            return
        }
        
        UIView.animate(withDuration: 0.2) {
            self.bar!.transform = CGAffineTransform(translationX: 0, y: CGFloat(-1 * self.bar!.height))
        }
    }
    
    func hideBar(animated: Bool) {
        if (bar == nil) {
            return
        }
        
        if (animated) {
            UIView.animate(withDuration: 0.5) {
                self.bar!.transform = CGAffineTransform(translationX: 0, y: CGFloat(-1 * self.bar!.height))
            }
        } else {
            self.bar!.transform = CGAffineTransform(translationX: 0, y: CGFloat(-1 * self.bar!.height))
        }
    }
    
    func setupBar(text: statusBar.statusBarText) {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.collapseBar(_:)))
        bar!.addGestureRecognizer(tap)
        self.view.insertSubview(bar!, belowSubview: self.navigationBar)
        bar!.translatesAutoresizingMaskIntoConstraints = false
        bar!.topAnchor.constraint(equalTo: self.navigationBar.bottomAnchor, constant: text == .noInternet ? -50 : -70 ).isActive = true
        bar!.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        bar!.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
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
