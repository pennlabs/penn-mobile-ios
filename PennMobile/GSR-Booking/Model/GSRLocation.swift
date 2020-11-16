//
//  StudySpace.swift
//  PennMobile
//
//  Created by Josh Doman on 2/3/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

struct GSRLocation {
    let lid: Int
    var gid: Int?
    let name: String
    let service: String
}

extension GSRLocation: Equatable {}
