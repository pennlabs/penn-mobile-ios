//
//  SublettingViewModel.swift
//  PennMobile
//
//  Created by Jordan H on 2/9/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import Foundation
import Combine
import PennMobileShared
import OrderedCollections

struct MarketplaceFilterData: Codable {
    var minPrice: Int?
    var maxPrice: Int?
    var location: String?
    var startDate: Date?
    var endDate: Date?
    var beds: Int?
    var baths: Int?
    var selectedAmenities = OrderedSet<String>()
}

class SublettingViewModel: ObservableObject {
    @Published var sublets: [Int: Sublet] = [:]
    @Published private(set) var sortedFilteredSublets: [Sublet] = []
    @Published var searchText = ""
    @Published private(set) var debouncedText = "" {
        didSet {
            sortSublets()
        }
    }
    @Published var sortOption = "Select" {
        didSet {
            sortSublets()
        }
    }
    let sortOptions = ["Select", "Name", "Price", "Beds", "Baths", "Start Date", "End Date"]
    var amenities: OrderedSet<String> {
        didSet {
            UserDefaults.standard.setSubletAmenities(amenities)
        }
    }
    @Published var filterData: MarketplaceFilterData {
        didSet {
            UserDefaults.standard.setSubletFilterData(filterData)
            Task {
                await populateFiltered()
            }
        }
    }
    
    enum ListingsTabs: CaseIterable {
        case posted
        case drafts
        case saved
        case applied
    }
    
    private var listingsIDs: [Int]
    private var savedIDs: [Int]
    private var appliedIDs: [Int]
    private var filteredIDs: [Int] {
        didSet {
            sortSublets()
        }
    }
    var listings: [Sublet] {
        listingsIDs.compactMap { sublets[$0] }
    }
    var saved: [Sublet] {
        savedIDs.compactMap { sublets[$0] }
    }
    var applied: [Sublet] {
        appliedIDs.compactMap { sublets[$0] }
    }
    @Published var drafts: [Sublet] {
        didSet {
            UserDefaults.standard.setSubletDrafts(drafts)
        }
    }
    
    init() {
        self.amenities = UserDefaults.standard.getSubletAmenities() ?? OrderedSet<String>()
        self.filterData = UserDefaults.standard.getSubletFilterData() ?? MarketplaceFilterData()
        self.drafts = UserDefaults.standard.getSubletDrafts()
        self.listingsIDs = []
        self.savedIDs = []
        self.appliedIDs = []
        self.filteredIDs = []
        
        $searchText
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .assign(to: &$debouncedText)
        
        Task {
            await self.populateSublets()
            await withTaskGroup(of: Void.self) { group in
                group.addTask { await self.populateAmenities() }
                group.addTask { await self.populateListings() }
                group.addTask { await self.populateFavorites() }
                group.addTask { await self.populateApplied() }
                group.addTask { await self.populateFiltered() }
            }
        }
    }
    
    func populateAmenities() async {
        do {
            self.amenities.formUnion(Set(try await SublettingAPI.instance.getAmenities()))
        } catch {
            print("Error populating amenities: \(error)")
        }
    }
    
    func populateListings() async {
        do {
            let listingsArr = try await SublettingAPI.instance.getSublets(queryParameters: ["subletter": "true"])
            listingsArr.forEach { sublets[$0.id] = $0 }
            listingsIDs = listingsArr.map { $0.id }
            if let updatedListings = try? await SublettingAPI.instance.getSubletDetails(sublets: self.listings, withOffers: true) {
                updatedListings.forEach { sublets[$0.id] = $0 }
            }
        } catch {
            print("Error getting user listings: \(error)")
        }
    }
    
    func populateApplied() async {
        do {
            let appliedArr = try await SublettingAPI.instance.getAppliedSublets()
            appliedArr.forEach { sublets[$0.id] = $0 }
            appliedIDs = appliedArr.map { $0.id }
            if let updatedApplied = try? await SublettingAPI.instance.getSubletDetails(sublets: self.applied, withOffers: false) {
                updatedApplied.forEach { sublets[$0.id] = $0 }
            }
        } catch {
            print("Error getting user applied sublets: \(error)")
        }
    }
    
    func populateFavorites() async {
        do {
            let savedArr = try await SublettingAPI.instance.getFavorites()
            savedArr.forEach { sublets[$0.id] = $0 }
            savedIDs = savedArr.map { $0.id }
            if let updatedSaved = try? await SublettingAPI.instance.getSubletDetails(sublets: self.saved, withOffers: false) {
                updatedSaved.forEach { sublets[$0.id] = $0 }
            }
        } catch {
            print("Error getting user saved sublets: \(error)")
        }
    }
    
    func populateSublets() async {
        do {
            let subletsArr = try await SublettingAPI.instance.getSublets()
            subletsArr.forEach { sublets[$0.id] = $0 }
        } catch {
            print("Error populating sublets: \(error)")
        }
    }
    
    func populateFiltered() async {
        var queryParameters: [String: String] = [:]
        if let minPrice = filterData.minPrice {
            queryParameters["min_price"] = "\(minPrice)"
        }
        if let maxPrice = filterData.maxPrice {
            queryParameters["max_price"] = "\(maxPrice)"
        }
        if let location = filterData.location {
            queryParameters["address"] = location
        }
        if let startDate = filterData.startDate {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            queryParameters["starts_after"] = formatter.string(from: startDate)
        }
        if let endDate = filterData.endDate {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            queryParameters["ends_before"] = formatter.string(from: endDate)
        }
        if let beds = filterData.beds {
            queryParameters["beds"] = "\(beds)"
        }
        if let baths = filterData.baths {
            queryParameters["baths"] = "\(baths)"
        }
        if !filterData.selectedAmenities.isEmpty {
            queryParameters["amenities"] = filterData.selectedAmenities.joined(separator: ",")
        }
        
        do {
            let subletsArr = try await SublettingAPI.instance.getSublets(queryParameters: queryParameters)
            filteredIDs = subletsArr.map { $0.id }
        } catch {
            print("Error populating sublets: \(error)")
        }
    }
    
    func favoriteSublet(sublet: Sublet) async -> Bool {
        if isFavorited(sublet: sublet) {
            return false
        }
        do {
            try await SublettingAPI.instance.favoriteSublet(id: sublet.id)
            savedIDs.append(sublet.id)
            return true
        } catch {
            print("Error favoriting sublets: \(error)")
            return false
        }
    }
    
    func unfavoriteSublet(sublet: Sublet) async -> Bool {
        if !isFavorited(sublet: sublet) {
            return false
        }
        do {
            try await SublettingAPI.instance.unfavoriteSublet(id: sublet.id)
            savedIDs.removeAll { $0 == sublet.id }
            return true
        } catch {
            print("Error unfavoriting sublets: \(error)")
            return false
        }
    }
    
    func isFavorited(sublet: Sublet) -> Bool {
        return savedIDs.contains(sublet.id)
    }
    
    func updateSublet(sublet: Sublet) {
        sublets[sublet.id] = sublet
    }
    
    private func sortSublets() {
        let filtered = filteredIDs.compactMap { sublets[$0] }
        
        if debouncedText != "" {
            sortedFilteredSublets = sortSubletsBySearch(sublets: filtered, searchText: debouncedText)
        } else {
            sortedFilteredSublets = sortSubletsByField(sublets: filtered, sortOption: sortOption)
        }
    }
    
    private func sortSubletsByField(sublets: [Sublet], sortOption: String) -> [Sublet] {
        switch sortOption {
        case "Name":
            return sublets.sorted { $0.title < $1.title }
        case "Price":
            return sublets.sorted { $0.price < $1.price }
        case "Beds":
            return sublets.sorted { ($0.beds ?? 0) < ($1.beds ?? 0) }
        case "Baths":
            return sublets.sorted { ($0.baths ?? 0) < ($1.baths ?? 0) }
        case "Start Date":
            return sublets.sorted { $0.startDate < $1.startDate }
        case "End Date":
            return sublets.sorted { $0.endDate < $1.endDate }
        default:
            return sublets
        }
    }
    
    private func sortSubletsBySearch(sublets: [Sublet], searchText: String) -> [Sublet] {
        guard !searchText.isEmpty else {
            return sublets
        }
        
        return sublets.sorted { sublet1, sublet2 in
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
