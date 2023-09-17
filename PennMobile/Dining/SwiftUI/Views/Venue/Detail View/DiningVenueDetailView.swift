//
//  DiningVenueDetailView.swift
//  PennMobile
//
//  Created by CHOI Jongmin on 6/6/2020.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import SwiftUI
import Kingfisher
import FirebaseAnalytics

struct DiningVenueDetailView: View {

    init(for venue: DiningVenue) {
        self.venue = venue
    }

    private let venue: DiningVenue
    private let sectionTitle = ["Menu", "Hours", "Location"]

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var diningVM: DiningViewModelSwiftUI
    @State private var pickerIndex = 0

    var body: some View {
        GeometryReader { fullGeo in
            let imageHeight = fullGeo.size.height * 4/9
            let statusBarHeight = fullGeo.safeAreaInsets.top

            ScrollView {
                GeometryReader { geometry in
                    let minY = geometry.frame(in: .global).minY
                    let remain = imageHeight + minY

                    ZStack(alignment: .bottomLeading) {
                        KFImage(self.venue.image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: geometry.size.width, height: imageHeight + max(0, minY))
                            .offset(y: min(0, minY) * -2/3)
                            .allowsHitTesting(false)
                            .clipped()

                        LinearGradient(gradient: Gradient(colors: [.clear, .black]), startPoint: .center, endPoint: .bottom)
                    }
                    .offset(y: -max(0, minY))
                }
                .frame(height: imageHeight)
                .zIndex(2)

                VStack(spacing: 10) {
                    Picker("Section", selection: self.$pickerIndex) {
                        ForEach(0 ..< self.sectionTitle.count) {
                            Text(self.sectionTitle[$0])
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())

                    Divider()

                    VStack {
                        if self.pickerIndex == 0 {
                            DiningVenueDetailMenuView(menus: diningVM.diningMenus[venue.id]?.menus ?? [], id: venue.id, venue: venue)
                        } else if self.pickerIndex == 1 {
                            DiningVenueDetailHoursView(for: venue)
                        } else {
                            DiningVenueDetailLocationView(for: venue, screenHeight: fullGeo.size.width)
                        }

                        Spacer()
                    }.frame(minHeight: fullGeo.size.height - 80)
                }.padding(.horizontal)
            }
            .edgesIgnoringSafeArea(.all)
            .navigationTitle(Text(venue.name))
            .onAppear {
                FirebaseAnalyticsManager.shared.trackScreen("Venue Detail View")
            }
        }
    }
}

// Hack to enable swipe from left while disabling navigation title
// TODO: find a more natural fix in future releases
extension UINavigationController {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = nil
    }
}
