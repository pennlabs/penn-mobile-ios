//
//  BannerView.swift
//  PennMobile
//
//  Created by Anthony Li on 3/24/23.
//  Copyright © 2023 PennLabs. All rights reserved.
//

import SwiftUI
import Kingfisher

extension BannerDescription: View {
    var imageView: some View {
        KFImage(image)
            .resizable()
            .scaledToFill()
            .accessibilityLabel(Text(text))
    }

    var body: some View {
        Group {
            if let action {
                Link(destination: action) {
                    imageView
                }
            } else {
                imageView
            }
        }
        .id(image)
        .transition(.slide)
    }
}

struct BannerView: View {
    static let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    static let height: CGFloat = 96

    @EnvironmentObject var viewModel: BannerViewModel
    @State var banner: BannerDescription?

    func selectBanner() {
        banner = viewModel.banners.random
    }

    var body: some View {
        Group {
            if let banner {
                banner
            } else {
                Text("Finding personalized offers for you...")
                    .font(.custom("Arial", size: 16))
                    .foregroundColor(.uiBackground)
                    .padding()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.primary)
        .frame(height: BannerView.height)
        .clipped()
        .ignoresSafeArea()
        .onReceive(BannerView.timer) { _ in
            withAnimation {
                selectBanner()
            }
        }
        .onAppear {
            viewModel.fetchBannersIfNeeded()
            selectBanner()
        }
    }
}
