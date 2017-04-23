//
//  GSRLocationsHandler.swift
//  GSR
//
//  Created by Yagil Burowski on 15/09/2016.
//  Copyright © 2016 Yagil Burowski. All rights reserved.
//

import Foundation

class LocationsHandler {
    static func getLocations() -> [GSRLocation] {
        return [GSRLocation(name: "VP GSR", code: 1799, path: "/booking/vpdlc"),
                GSRLocation(name: "Weigle", code: 1722, path: "/booking/wic"),
                GSRLocation(name: "Lippincott", code: 1768, path: "/booking/lippincott"),
                GSRLocation(name: "Edu Commons", code: 848, path: "/booking/educom"),
                GSRLocation(name: "VP Sem. Rooms", code: 4409, path: "/booking/seminar"),
                //GSRLocation(name: "Noldus Observer", code: 3621, path: "/booking/noldus"),
                GSRLocation(name: "Lippincott Sem. Rooms", code: 2587, path: "/booking/lippseminar"),
                GSRLocation(name: "Levin Building", code: 13489, path: "/booking/levin"),
                GSRLocation(name: "Glossberg Recording Room", code: 1819, path: "/booking/glossberg"),
                //GSRLocation(name: "Dental GSR", code: 13107, path: "/booking/dental"), //crashes
                GSRLocation(name: "Dental Sem", code: 13532, path: "/booking/dentalseminar"),
                GSRLocation(name: "Biomedical Lib.", code: 505, path: "/booking/biomed")
        ]
    }
}
