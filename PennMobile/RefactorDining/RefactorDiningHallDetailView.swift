//
//  RefactorDiningHallDetailView.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 1/14/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI
import Kingfisher
import PennMobileShared

struct RefactorDiningHallDetailView: View {
    let hall: RefactorDiningHall
    
    @Environment(\.colorScheme) var colorScheme
    @State var pickerIndex: Int = 0
    @State var showMenu: Bool = false
    private let sectionTitle: [String]
    private let hasMenu: Bool
    
    init(_ hall: RefactorDiningHall) {
        self.hall = hall
        
        hasMenu = !hall.meals.filter({ el in
            return el.stations.count > 0
        }).isEmpty
        
        var sections = hasMenu ? ["Menu"] : []
        sections.append(contentsOf: ["Hours", "Location"])
        sectionTitle = sections
        
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack {
                GeometryReader { geometry in
                    let minY = geometry.frame(in: .global).minY
                    ZStack(alignment: .bottomLeading) {
                        KFImage(URL(string: hall.imageUrl))
                            .resizable()
                            .scaledToFill()
                            .frame(width: geometry.size.width, height: UIScreen.main.bounds.height * 4/9 + max(0, minY))
                            .offset(y: min(0, minY) * -2/3)
                            .allowsHitTesting(false)
                            .clipped()
                        
                        LinearGradient(gradient: Gradient(colors: [.black.opacity(0.6), .black.opacity(0.2), .clear, .black.opacity(0.3), .black]), startPoint: .init(x: 0.5, y: 0.2), endPoint: .init(x: 0.5, y: 1))
                        
                        Text(hall.name)
                            .padding()
                            .foregroundColor(.white)
                            .font(.system(size: 40, weight: .bold))
                            .minimumScaleFactor(0.2)
                            .lineLimit(1)
                    }
                    .offset(y: -max(0, minY))
                }
                .edgesIgnoringSafeArea(.all)
                .frame(height: UIScreen.main.bounds.height * 4/9)
                
                HStack (alignment: .center, spacing: 10) {
                    CustomPicker(options: sectionTitle, selected: $pickerIndex) { item in
                        Text(item)
                    }
                    
                    Button {
                        showMenu.toggle()
                    } label: {
                        Image(systemName:"safari")
                            .font(.title2)
                    }
                    .sheet(isPresented: $showMenu) {
                        VStack {
                            HStack {
                                Spacer()
                                Image(systemName: "xmark")
                                    .font(.largeTitle)
                                    .padding(8)
                                    .onTapGesture {
                                        showMenu = false
                                    }
                            }
                            WebView(url: URL(string: RefactorDiningHall.menuUrlDict[hall.id] ?? "https://university-of-pennsylvania.cafebonappetit.com/")!)
                        }
                    }
                }
                .padding()
                
                // Don't show an empty view if there are no menu items. Instead, just show the hours screen
                // The subtracted index is to adjust for whether the "Menu" section in the picker exists
                if pickerIndex == 0 && hasMenu {
                    RefactorDiningHallMenuSubview(hall: hall)
                } else if pickerIndex == 1 - (hasMenu ? 0 : 1) {
                    RefactorDiningHallHoursView(hall: hall)
                        .padding()
                } else if pickerIndex == 2 - (hasMenu ? 0 : 1) {
                    //RefactorDiningHallLocationView()
                    Text("Location")
                }
            }
            //        ScrollView(showsIndicators: false) {
            //
            //            LazyVStack(alignment: .leading, spacing: 0, pinnedViews: [.sectionHeaders]) {
            //
            //
            //
            ////                .background {
            ////                    let image = Image("DiningAnalyticsBackground")
            ////                        .resizable()
            ////                        .scaledToFit()
            ////                        .opacity(0.3)
            ////                    switch colorScheme {
            ////                    case .dark:
            ////                        image
            ////                            .colorInvert()
            ////                            .hueRotation(.degrees(180))
            ////                            .saturation(0.8)
            ////                            .contrast(0.8)
            ////                    default:
            ////                        image
            ////                    }
            ////                }
            //
            //            }
            //        }
            .navigationBarTitleDisplayMode(.inline)
            .edgesIgnoringSafeArea(.horizontal)
        }
    }
}
