//
//  PollsViewController.swift
//  PennMobile
//
//  Created by Karthik Padmanabhan on 3/20/22.
//  Copyright © 2022 PennLabs. All rights reserved.
//

import Foundation

import UIKit

class PollsViewController: UIViewController {
    override func viewDidLoad() {
        view.backgroundColor = .red
        PollsNetworkManager.instance.getArchivedPolls { polls in
            print(polls)
            if let polls = polls, polls.count > 0 {
                ([HomePollsCellItem(pollQuestion: polls[0])])
            }
        }
    }
}
