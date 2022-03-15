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
                        KFImage(self.venue.imageURL)
                            .resizable()
                            .scaledToFill()
                            .frame(width: geometry.size.width, height: imageHeight + max(0, minY))
                            .offset(y: min(0, minY) * -2/3)
                            .allowsHitTesting(false)
                            .clipped()

                        LinearGradient(gradient: Gradient(colors: [.clear, .black]), startPoint: .center, endPoint: .bottom)

                        VStack(alignment: .leading) {
                            Button(action: {
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 20, weight: .light))
                            }
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Circle().opacity(0.8).foregroundColor(.black))
                            .position(x: 40, y: statusBarHeight + 22)
                            .offset(y: -min(0, minY))

                            Spacer()

                            Text(venue.name)
                                .padding()
                                .foregroundColor(.white)
                                .font(.system(size: 40, weight: .bold))
                                .minimumScaleFactor(0.2)
                                .lineLimit(1)
                        }.opacity(1 - Double(minY)/60)

                        VStack {
                            DefaultNavigationBar(title: venue.name)
                                .frame(height: 44 + statusBarHeight)
                                .opacity(Double(-1/20 * (remain - (64 + statusBarHeight))))

                            Spacer()
                        }.offset(y: -min(0, minY))
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
                            DiningVenueDetailMenuView(menus: diningVM.diningMenus[venue.id]?.document.menuDocument.menus ?? [], id: venue.id)
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
            .navigationBarHidden(true)
            .onAppear {
                FirebaseAnalyticsManager.shared.trackScreen("Venue Detail View")
                diningVM.refreshMenu(for: venue.id)
            }
        }
    }
}

struct DefaultNavigationBar: View {

    @Environment(\.presentationMode) var presentationMode

    var title: String

    var body: some View {
        ZStack(alignment: .bottom) {
            VisualEffectView(effect: UIBlurEffect(style: .systemMaterial))

            VStack {
                Spacer()

                HStack {
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Back")
                            .frame(width: 75, height: 44, alignment: .center)
                            .contentShape(Rectangle())
                    }

                    Spacer()
                }
            }

            VStack {
                Spacer()
                Text(title)
                    .frame(height: 44)
            }
        }
    }
}

struct DiningVenueDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let path = Bundle.main.path(forResource: "sample-dining-venue", ofType: "json")
        let data = try! Data(contentsOf: URL(fileURLWithPath: path!), options: .mappedIfSafe)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let diningVenues = try! decoder.decode(DiningAPIResponse.self, from: data)

        return
            NavigationView {
                DiningVenueDetailView(for: diningVenues.document.venues[0])
            .preferredColorScheme(.dark)
            .environmentObject(DiningViewModelSwiftUI())
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
