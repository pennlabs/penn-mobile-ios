//
//  BannerViewModel.swift
//  PennMobile
//
//  Created by Anthony Li on 3/24/23.
//  Copyright © 2023 PennLabs. All rights reserved.
//

import SwiftUI
import Foundation

private func getDefaultBannerURL() -> URL {
    let data = Data(base64Encoded: "aHR0cHM6Ly9wZW5ubGFicy5naXRodWIuaW8vcGxhdGZvcm0tc2FtcGxlLWFzc2V0cy9hc3NldHMuanNvbg==")!
    return URL(string: String(data: data, encoding: .ascii)!)!
}

class BannerViewModel: ObservableObject {
    static let shared = BannerViewModel(
        url: getDefaultBannerURL(),
        cacheMaxAge: 60 * 60
    )
    
    @Published var banners: [BannerDescription] = []
    private var isFetching = false
    private var lastSuccessfulFetch: Date?
    
    let url: URL
    let cacheMaxAge: TimeInterval
    
    init(url: URL, cacheMaxAge: TimeInterval) {
        self.url = url
        self.cacheMaxAge = cacheMaxAge
    }
    
    let decoder = {
        let decoder = JSONDecoder()
        decoder.allowsJSON5 = true
        return decoder
    }()
    
    func shouldDisplayBanners(on date: Date = Date()) -> Bool {
        #if DEBUG
        if ProcessInfo.processInfo.environment["FORCE_BANNERS"] != nil {
            return true
        }
        #endif
        
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents(in: TimeZone.current, from: date)
        
        return components.year == 2023 && components.month == 4 && components.day == 1
    }
    
    func fetchBannersIfNeeded() {
        if isFetching {
            return
        }
        
        if let lastSuccessfulFetch, -lastSuccessfulFetch.timeIntervalSinceNow < cacheMaxAge {
            return
        }
        
        struct BannerResponse: Decodable {
            let assets: [BannerDescription]
        }
        
        print("Fetching banners!")
        isFetching = true
        Task {
            do {
                let (data, _) = try await URLSession(configuration: .ephemeral).data(from: url)
                banners = try decoder.decode(BannerResponse.self, from: data).assets
                lastSuccessfulFetch = Date()
            } catch let error {
                lastSuccessfulFetch = nil
                print("Failed to load banners: \(error)")
            }
            
            isFetching = false
        }
    }
}
