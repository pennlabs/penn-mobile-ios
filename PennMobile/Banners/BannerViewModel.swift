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

func getDefaultPopupURL() -> URL {
    let data = Data(base64Encoded: "aHR0cHM6Ly9wZW5ubGFicy5naXRodWIuaW8vcGxhdGZvcm0tc2FtcGxlLWFzc2V0cy9pbnRlcmFjdGl2ZS5odG1sCg==")!
    return URL(string: String(data: data, encoding: .ascii)!)!
}

@MainActor class BannerViewModel: ObservableObject {
    static let shared = BannerViewModel(
        url: getDefaultBannerURL(),
        cacheMaxAge: 60 * 60
    )
    
    static var isAprilFools: Bool {
        let components = Calendar.autoupdatingCurrent.dateComponents(in: .autoupdatingCurrent, from: Date())
        return components.month == 4 && components.day == 1
    }

    @Published var banners: [BannerDescription] = []
    private var isFetching = false
    private var lastSuccessfulFetch: Date?
    
    @Published var showBanners = ProcessInfo.processInfo.environment["FORCE_BANNERS"] != nil || BannerViewModel.isAprilFools
    @Published var showPopup = true

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

        isFetching = true
        Task {
            do {
                let (data, _) = try await URLSession(configuration: .ephemeral).data(from: url)
                let response = try decoder.decode(BannerResponse.self, from: data)
                banners = response.assets
                lastSuccessfulFetch = Date()
            } catch let error {
                lastSuccessfulFetch = nil
                print("Failed to load banners: \(error)")
            }

            isFetching = false
        }
    }
}
