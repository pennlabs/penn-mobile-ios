//
//  StudySpace.swift
//  PennMobile
//
//  Created by Josh Doman on 2/3/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

enum SpaceSpaceName: String {
    case biomedical = "Biomedical Library"
    case eduCommons = "Education Commons"
    case fisher = "Fisher Fine Arts Library"
    case levin = "Levin Building Group Study Rooms"
    case museum = "Museum Library"
    case weigle = "Weigle"
    case lippincott = "Lippincott Library"
    case vpSeminar = "VP Sem. Rooms"
}

struct StudySpace: Codable {
    let id: Int
    let name: String
    let service: String
}
