//
//  DiningDetailModel.swift
//  PennMobile
//
//  Created by Josh Doman on 2/2/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

class DiningDetailModel {
    static private let server = "https://university-of-pennsylvania.cafebonappetit.com/cafe"
        
    static private let serverDictionary: [DiningVenueName: String] = {
        var dict = [DiningVenueName: String]()
        dict[.commons] = "1920-commons"
        dict[.mcclelland] = "mcclelland"
        dict[.falk] = "falk-dining-commons"
        dict[.english] = "kings-court-english-house"
        dict[.gourmetGrocer] = "1920-gourmet-grocer"
        dict[.joes] = "joes-cafe"
        dict[.marks] = "marks-cafe"
        dict[.houston] = "houston-market"
        dict[.starbucks] = "1920-starbucks"
        dict[.nch] = "new-college-house"
        dict[.hill] = "hill-house"
        dict[.mbaCafe] = "pret-a-manger-upper"
        dict[.pret] = "pret-a-manger-lower"
        return dict
    }()
    
    static func getUrl(for venue: DiningVenueName) -> String? {
        if let endPoint = serverDictionary[venue] {
            return "\(server)/\(endPoint)"
        }
        return nil
    }
}
