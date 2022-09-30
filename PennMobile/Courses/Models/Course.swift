//
//  Course.swift
//  PennMobile
//
//  Created by Anthony Li on 9/30/22.
//  Copyright © 2022 PennLabs. All rights reserved.
//

import Foundation

struct Course: Codable {
    var crn: String
    var code: String
    var title: String
}

extension Course: Identifiable {
    var id: String { crn }
}

extension Course {
    init(_ data: PathAtPennNetworkManager.CourseData) {
        crn = data.crn
        code = data.code
        title = data.title
    }
}
