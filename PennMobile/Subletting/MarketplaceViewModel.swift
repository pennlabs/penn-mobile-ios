//
//  MarketplaceViewModel.swift
//  PennMobile
//
//  Created by Jordan H on 2/9/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import Foundation
import Combine
import PennMobileShared

class MarketplaceViewModel: ObservableObject {
    @Published var sublets: [Sublet] = Sublet.mocks
    @Published var searchText = ""
    @Published var sortOption = "Select" {
        didSet {
            sortSublets()
        }
    }
    let sortOptions = ["Select", "Name", "Price", "Beds", "Baths", "Start Date", "End Date"]
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        $searchText
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.performSearch()
            }
            .store(in: &cancellables)
    }
    
    func sortSublets() {
        switch sortOption {
        case "Name":
            sublets.sort { $0.title < $1.title }
        case "Price":
            sublets.sort { $0.price < $1.price }
        case "Beds":
            sublets.sort { ($0.beds ?? 0) < ($1.beds ?? 0) }
        case "Baths":
            sublets.sort { ($0.baths ?? 0) < ($1.baths ?? 0) }
        case "Start Date":
            sublets.sort { $0.startDate < $1.startDate }
        case "End Date":
            sublets.sort { $0.endDate < $1.endDate }
        default:
            break
        }
    }
    
    private func performSearch() {
        guard !searchText.isEmpty else {
            return
        }
        
        sublets.sort { sublet1, sublet2 in
            getSimilaritySort(sublet1.title, sublet2.title, similar: searchText)
        }
    }
    
    private func jaccardSimilarity(_ str1: String, _ str2: String) -> Double {
        let set1 = Set(str1.lowercased())
        let set2 = Set(str2.lowercased())
        let intersection = set1.intersection(set2)
        let union = set1.union(set2)
        return Double(intersection.count) / Double(union.count)
    }

    private func getSimilaritySort(_ str1: String, _ str2: String, similar: String) -> Bool {
        let similarLowercased = similar.lowercased()
        
        let startsWithSimilar = [
            str1.lowercased().hasPrefix(similarLowercased),
            str2.lowercased().hasPrefix(similarLowercased)
        ]
        
        if startsWithSimilar[0] != startsWithSimilar[1] {
            return startsWithSimilar[0]
        }
        
        let containsSimilar = [
            str1.lowercased().contains(similarLowercased),
            str2.lowercased().contains(similarLowercased)
        ]
        
        if containsSimilar[0] != containsSimilar[1] {
            return containsSimilar[0]
        }
        
        let similarity1 = jaccardSimilarity(str1, similarLowercased)
        let similarity2 = jaccardSimilarity(str2, similarLowercased)
        
        return similarity1 > similarity2
    }
}
