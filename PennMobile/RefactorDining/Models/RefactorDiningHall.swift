//
//  RefactorDiningHall.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 1/13/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//
import Foundation


/*
 Ok so current thought:
 
 1. The dining hall schedule (meal schedule) is in the venues endpoint, which also contains the name, address, etc (fields in DiningHall).
 2. The actual items in each meal are in the menus endpoint. This makes it really difficult to link between the two.
    2a. So I don't think I'm going to. That is, I'm going to link the two endpoints' data together as they're initialized.
 3. On init, we will create (because CIS-1210 just ended and I want to justify a semester of pain) a heap of containing DiningHall objects (keyed by date)
    and an a heap of DiningMenu objects keyed by date.
        3a. O(n)
 4. We will then iterate through each heap, popping both minimums off the heap if they are equal (linking the two together).
    If not equal, pop the smaller of the two (indicating that we have no data for the meal we just removed) and continue.
        4a. O(nlogn)
 5. In theory, we should run out of data in both heaps at the same time.
 6. Then cache the whole data structure. (probably expensive given its like 200,000 lines)
 */

public struct RefactorDiningHall: Codable, Identifiable, Hashable {
    public let id: Int
    public let name: String
    public let address: String
    public let meals: [RefactorDiningMeal]
    public let imageUrl: String
    public var venueType: RefactorVenueType {
        switch id {
        case 593, 636, 637, 638, 1442, 747:
            return .dining
        default:
            return .retail
        }
    }
    public var diningUrl: String {
        RefactorDiningHall.menuUrlDict[id] ?? "https://university-of-pennsylvania.cafebonappetit.com"
    }
    
    public static let menuUrlDict: [Int: String] =
        [
            593: "https://university-of-pennsylvania.cafebonappetit.com/cafe/1920-commons/",
            636: "https://university-of-pennsylvania.cafebonappetit.com/cafe/hill-house/",
            637: "https://university-of-pennsylvania.cafebonappetit.com/cafe/kings-court-english-house/",
            638: "https://university-of-pennsylvania.cafebonappetit.com/cafe/falk-dining-commons/",
            747: "https://university-of-pennsylvania.cafebonappetit.com/cafe/mcclelland/",
            1442: "https://university-of-pennsylvania.cafebonappetit.com/cafe/lauder-college-house/",
            639: "https://university-of-pennsylvania.cafebonappetit.com/cafe/houston-market/",
            641: "https://university-of-pennsylvania.cafebonappetit.com/cafe/accenture-cafe/",
            642: "https://university-of-pennsylvania.cafebonappetit.com/cafe/joes-cafe/",
            1057: "https://university-of-pennsylvania.cafebonappetit.com/cafe/1920-gourmet-grocer/",
            1163: "https://university-of-pennsylvania.cafebonappetit.com/cafe/1920-starbucks/",
            1732: "https://university-of-pennsylvania.cafebonappetit.com/cafe/pret-a-manger-upper/",
            1733: "https://university-of-pennsylvania.cafebonappetit.com/cafe/pret-a-manger-lower/",
            1464004: "https://university-of-pennsylvania.cafebonappetit.com/cafe/quaker-kitchen/",
            1464009: "https://university-of-pennsylvania.cafebonappetit.com/cafe/cafe-west/"
        ]
    
}


public enum RefactorVenueType {
    case retail, dining
}




