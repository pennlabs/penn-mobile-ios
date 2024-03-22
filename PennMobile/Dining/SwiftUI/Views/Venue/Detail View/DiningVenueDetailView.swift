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
import PennMobileShared
import WebKit

struct DiningVenueDetailView: View {

    init(for venue: DiningVenue) {
        self.venue = venue
    }

    private let venue: DiningVenue
    private let sectionTitle = ["Menu", "Hours", "Location"]

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var diningVM: DiningViewModelSwiftUI
    @State private var pickerIndex = 0
    @State private var contentOffset: CGPoint = .zero
    @State private var showMenu = false
    @State var showTitle = false

    var body: some View {
        GeometryReader { fullGeo in
            let imageHeight = fullGeo.size.height * 4/9
            let isFavorite = diningVM.favoriteVenues.contains { $0.id == venue.id }
            ScrollViewReader { fullReader in
                ScrollView {
                    // Image and Name
                    GeometryReader { geometry in
                        let minY = geometry.frame(in: .global).minY
                        
                        ZStack(alignment: .bottomLeading) {
                            KFImage(self.venue.image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: geometry.size.width, height: imageHeight + max(0, minY))
                                .offset(y: min(0, minY) * -2/3)
                                .allowsHitTesting(false)
                                .clipped()
                            
                            LinearGradient(gradient: Gradient(colors: [.black.opacity(0.6), .black.opacity(0.2), .clear, .black.opacity(0.3), .black]), startPoint: .init(x: 0.5, y: 0.2), endPoint: .init(x: 0.5, y: 1))
                            
                            Text(venue.name)
                                .padding()
                                .foregroundColor(.white)
                                .font(.system(size: 40, weight: .bold))
                                .minimumScaleFactor(0.2)
                                .lineLimit(1)
                                .background(GeometryReader { geometry in
                                    let minY = geometry.frame(in: .global).minY
                                    Color.clear.onChange(of: minY) { minY in
                                        showTitle = minY <= 64
                                    }
                                })
                        }
                        .offset(y: -max(0, minY))
                    }
                    .edgesIgnoringSafeArea(.all)
                    .frame(height: imageHeight)
                    .zIndex(2)
                    
                    VStack(spacing: 10) {
                        HStack (spacing: 10) {
                            Picker("Section", selection: self.$pickerIndex) {
                                ForEach(0 ..< self.sectionTitle.count, id: \.self) {
                                    Text(self.sectionTitle[$0])
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            
                            Button {
                                showMenu.toggle()
                            } label: {
                                Image(systemName:"safari")
                                    .font(.largeTitle)
                            }
                            .sheet(isPresented: $showMenu) {
                                WebView(url: URL(string: DiningVenue.menuUrlDict[venue.id] ?? "https://university-of-pennsylvania.cafebonappetit.com/")!)
                            }
                        }
                        
                        Divider()
                        
                        VStack {
                            if self.pickerIndex == 0 {
                                DiningVenueDetailMenuView(menus: diningVM.diningMenus[venue.id]?.menus ?? [], id: venue.id, venue: venue, parentScrollProxy: fullReader,
                                                          parentScrollOffset: $contentOffset)
                            } else if self.pickerIndex == 1 {
                                DiningVenueDetailHoursView(for: venue)
                            } else {
                                DiningVenueDetailLocationView(for: venue, screenHeight: fullGeo.size.width)
                            }
                            Spacer()
                        }.frame(minHeight: fullGeo.size.height - 80)
                    }.padding(.horizontal)
                    .background(GeometryReader { geometry in
                        Color.clear
                            .preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .named("scroll")).origin)
                    })
                    .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                        self.contentOffset = value
                }
                
                }
                .coordinateSpace(name: "scroll")
                .navigationTitle(Text(showTitle ? venue.name : ""))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem {
                        Button(action: isFavorite ? { diningVM.removeVenueFromFavorites(venue: venue) } : { diningVM.addVenueToFavorites(venue: venue) }) {
                            Image(systemName: isFavorite ? "star.fill" : "star")
                                .font(.system(size: 20, weight: .light))
                        }
                        .tint(.yellow)
                    }
                }
                .onAppear {
                    FirebaseAnalyticsManager.shared.trackScreen("Venue Detail View")
                }
            }
        }
    }
    
    struct ScrollOffsetPreferenceKey: PreferenceKey {
        static var defaultValue: CGPoint = .zero

        static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
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

struct WebView: UIViewRepresentable {
    let url: URL
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.load(URLRequest(url: url))
    }
}
