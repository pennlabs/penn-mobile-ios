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
    
    init(_ hall: RefactorDiningHall) {
        self.hall = hall
    }
    
    @Environment(\.colorScheme) var colorScheme
    @State var pickerIndex: Int = 0
    @State var showMenu: Bool = false
    private let sectionTitle = ["Menu", "Hours", "Location"]
    
    
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, pinnedViews: [.sectionHeaders]) {
                ZStack {
                    KFImage(URL(string: hall.imageUrl))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxHeight: UIScreen.main.bounds.height * 4/9)
                    LinearGradient(colors: [Color.black.opacity(1.0), Color.black.opacity(0), Color.black.opacity(0)], startPoint: .bottom, endPoint: .top)
                    VStack {
                        Spacer()
                        Text(hall.name)
                            .multilineTextAlignment(.center)
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(.white)
                            .shadow(radius: 2)
                            .padding()
                    }
                }
                
                HStack (alignment: .center, spacing: 10) {
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
                
                Group {
                    if pickerIndex == 0 {
                        RefactorDiningHallMenuSubview(hall: hall)
                    } else if pickerIndex == 1 {
                        //RefactorDiningHallHoursView()
                        Text("Hours")
                    } else if pickerIndex == 2 {
                        //RefactorDiningHallLocationView()
                        Text("Location")
                    }
                }
                .padding(.horizontal)
//                .background {
//                    let image = Image("DiningAnalyticsBackground")
//                        .resizable()
//                        .scaledToFit()
//                        .opacity(0.3)
//                    switch colorScheme {
//                    case .dark:
//                        image
//                            .colorInvert()
//                            .hueRotation(.degrees(180))
//                            .saturation(0.8)
//                            .contrast(0.8)
//                    default:
//                        image
//                    }
//                }
                
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
