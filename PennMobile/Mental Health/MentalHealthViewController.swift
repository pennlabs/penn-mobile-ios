//
//  MentalHealthViewController.swift
//  PennMobile
//
//  Created by dominic on 4/11/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

class MentalHealthViewController: GenericViewController {
    
    fileprivate var resources = [SupportItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.title = "Mental Health"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
}
