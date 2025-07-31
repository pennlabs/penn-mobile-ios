//
//  SublettingPage.swift
//  PennMobile
//
//  Created by Jordan Hochman on 4/6/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import Foundation

// Codable since used in NavigationPath() with random index hack
enum SublettingPage: Hashable, Identifiable, Equatable, Codable {
    case myListings(SublettingViewModel.ListingsTabs? = .posted)
    case myActivity(SublettingViewModel.ListingsTabs? = .saved)
    case subletDetailView(Int)
    case subletInterestForm(Sublet)
    case subletMapView(Sublet)
    case newListingForm
    case editSubletDraftForm(SubletDraft)
    case editSubletForm(Sublet)
    
    var id: SublettingPage { self }
    
    enum CodingKeys: CodingKey {
        case myListings, myActivity, subletDetailView, subletInterestForm, subletMapView, newListingForm, editSubletDraftForm, editSubletForm
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let tab = try? container.decode(SublettingViewModel.ListingsTabs.self, forKey: .myListings) {
            self = .myListings(tab)
        } else if let tab = try? container.decode(SublettingViewModel.ListingsTabs.self, forKey: .myActivity) {
            self = .myActivity(tab)
        } else if let id = try? container.decode(Int.self, forKey: .subletDetailView) {
            self = .subletDetailView(id)
        } else if let sublet = try? container.decode(Sublet.self, forKey: .subletInterestForm) {
            self = .subletInterestForm(sublet)
        } else if let sublet = try? container.decode(Sublet.self, forKey: .subletMapView) {
            self = .subletMapView(sublet)
        } else if let _ = try? container.decodeNil(forKey: .newListingForm) {
            self = .newListingForm
        } else if let subletDraft = try? container.decode(SubletDraft.self, forKey: .editSubletDraftForm) {
            self = .editSubletDraftForm(subletDraft)
        } else if let sublet = try? container.decode(Sublet.self, forKey: .editSubletForm) {
            self = .editSubletForm(sublet)
        } else {
            throw DecodingError.dataCorruptedError(forKey: .myListings, in: container, debugDescription: "Unable to decode SublettingPage")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .myListings(let tab):
            try container.encode(tab, forKey: .myListings)
        case .myActivity(let tab):
            try container.encode(tab, forKey: .myActivity)
        case .subletDetailView(let id):
            try container.encode(id, forKey: .subletDetailView)
        case .subletInterestForm(let sublet):
            try container.encode(sublet, forKey: .subletInterestForm)
        case .subletMapView(let sublet):
            try container.encode(sublet, forKey: .subletMapView)
        case .newListingForm:
            try container.encodeNil(forKey: .newListingForm)
        case .editSubletDraftForm(let subletDraft):
            try container.encode(subletDraft, forKey: .editSubletDraftForm)
        case .editSubletForm(let sublet):
            try container.encode(sublet, forKey: .editSubletForm)
        }
    }
}
