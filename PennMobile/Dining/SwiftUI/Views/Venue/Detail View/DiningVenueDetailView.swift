//
//  DiningVenueDetailView.swift
//  PennMobile
//
//  Created by CHOI Jongmin on 6/6/2020.
//  Copyright © 2020 PennLabs. All rights reserved.
//

#if canImport(SwiftUI)
import SwiftUI
import KingfisherSwiftUI
#endif

@available(iOS 14, *)
struct DiningVenueDetailView: View {
    
    var venue: DiningVenue
    var sectionTitle = ["Menu", "Hours", "Location"]
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var pickerIndex = 0
    
    init(for venue: DiningVenue) {
        self.venue = venue
    }
    
    private let headerImageHeight: CGFloat = 300
    private let collapsedHeaderImageHeight: CGFloat = 88
    
    private func getScrollOffset(_ geometry: GeometryProxy) -> CGFloat {
        geometry.frame(in: .global).minY
    }
    
    private func getOffsetForHeaderImage(_ geometry: GeometryProxy) -> CGFloat {
        let offset = getScrollOffset(geometry)
        
        let sizeOffScreen = headerImageHeight - collapsedHeaderImageHeight
        
        // if our offset is roughly less than -225 (the amount scrolled / amount off screen)
        if offset < -sizeOffScreen {
            return abs(offset) - sizeOffScreen
        }
        
        // Image was pulled down
        if offset > 0 {
            print("down")
            return -offset
        }
        
        return 0
    }
    
    private func getHeightForHeaderImage(_ geometry: GeometryProxy) -> CGFloat {
        let offset = getScrollOffset(geometry)
        // 44?
        let imageHeight = geometry.size.height

        if offset > 0 {
            return imageHeight + offset
        }

        return imageHeight
    }
    
    private func mapOffsetWithinZeroAndOne(_ geometry: GeometryProxy) -> CGFloat {
        let offset = geometry.frame(in: .global).maxY

        return min((max(300 - offset,0) / 260), 1)
    }
    
    private func getOpacityForNavigationBar(_ geometry: GeometryProxy) -> Double {
        let offset = geometry.frame(in: .global).maxY
        
        return Double(min((max(74 - offset,0) / 34), 1))
    }
    
    var body: some View {
        GeometryReader { screenGeoProxy in
            ScrollView {
                GeometryReader { geometry in
                    KFImage(self.venue.imageURL)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: self.getHeightForHeaderImage(geometry))
                        .blur(radius: self.mapOffsetWithinZeroAndOne(geometry)*6)
                        .opacity(1 - Double(self.mapOffsetWithinZeroAndOne(geometry)))
                        .clipped()
                        //screenGeoProxy.safeAreaInsets.top
                        .overlay(
                            DefaultNavigationBar(height: self.collapsedHeaderImageHeight, width: geometry.size.width, title: self.venue.name)
                                .opacity(self.getOpacityForNavigationBar(geometry))
                        )
                        .offset(x: 0, y: self.getOffsetForHeaderImage(geometry))
                }
                .frame(height: headerImageHeight)
                .zIndex(1)
                
                
                HStack {
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 28, weight: .bold))
                        Text(venue.name)
                            .font(.system(size: 28, weight: .bold))
                            .minimumScaleFactor(0.2)
                            .lineLimit(1)
                    }
                    .foregroundColor(Color.primary)
                    
                    Spacer()
                    
    //                    Image(systemName: "heart")
    //                        .font(.system(size: 28, weight: .medium))
                    
                }.padding(.horizontal)
                
                Picker("Section", selection: self.$pickerIndex) {
                    ForEach(0 ..< self.sectionTitle.count) {
                        Text(self.sectionTitle[$0])
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding([.leading, .trailing])
                
                Divider()
                    .padding()
                
                if self.pickerIndex == 0 {
                    DiningVenueDetailMenuView()
                        .padding(.horizontal)
                        
                } else if self.pickerIndex == 1 {
                    DiningVenueDetailHoursView(for: venue)
                        .padding(.horizontal)
                } else {
                    DiningVenueDetailLocationView(for: venue)
                        .padding(.horizontal)
                }
            }
            .navigationBarHidden(true)
        }
            
    }
}

@available(iOS 14.0, *)
struct DefaultNavigationBar: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var height: CGFloat
    var width: CGFloat
    var title: String
   
    var body: some View {
        VStack {
            Spacer()
            
            ZStack(alignment: .bottom) {
                VisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
                
                HStack {
                    Button("Back") {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                    Spacer()
                }.padding([.leading, .bottom])
                
                HStack {
                    Spacer()
                    Text(title)
                    Spacer()
                }.padding(.bottom)
                
                
            }.frame(width: width, height: height)
                
        }

    }
}

@available(iOS 14, *)
struct DiningVenueDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let path = Bundle.main.path(forResource: "sample-dining-venue", ofType: "json")
        let data = try! Data(contentsOf: URL(fileURLWithPath: path!), options: .mappedIfSafe)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let diningVenues = try! decoder.decode(DiningAPIResponse.self, from: data)

        return DiningVenueDetailView(for: diningVenues.document.venues[0])
    }
}

let loremIpsum = """
Lorem ipsum dolor sit amet consectetur adipiscing elit donec, gravida commodo hac non mattis augue duis vitae inceptos, laoreet taciti at vehicula cum arcu dictum. Cras netus vivamus sociis pulvinar est erat, quisque imperdiet velit a justo maecenas, pretium gravida ut himenaeos nam. Tellus quis libero sociis class nec hendrerit, id proin facilisis praesent bibendum vehicula tristique, fringilla augue vitae primis turpis.
Sagittis vivamus sem morbi nam mattis phasellus vehicula facilisis suscipit posuere metus, iaculis vestibulum viverra nisl ullamcorper lectus curabitur himenaeos dictumst malesuada tempor, cras maecenas enim est eu turpis hac sociosqu tellus magnis. Sociosqu varius feugiat volutpat justo fames magna malesuada, viverra neque nibh parturient eu nascetur, cursus sollicitudin placerat lobortis nunc imperdiet. Leo lectus euismod morbi placerat pretium aliquet ultricies metus, augue turpis vulputa
te dictumst mattis egestas laoreet, cubilia habitant magnis lacinia vivamus etiam aenean.
Sagittis vivamus sem morbi nam mattis phasellus vehicula facilisis suscipit posuere metus, iaculis vestibulum viverra nisl ullamcorper lectus curabitur himenaeos dictumst malesuada tempor, cras maecenas enim est eu turpis hac sociosqu tellus magnis. Sociosqu varius feugiat volutpat justo fames magna malesuada, viverra neque nibh parturient eu nascetur, cursus sollicitudin placerat lobortis nunc imperdiet. Leo lectus euismod morbi placerat pretium aliquet ultricies metus, augue turpis vulputa
te dictumst mattis egestas laoreet, cubilia habitant magnis lacinia vivamus etiam aenean.
Sagittis vivamus sem morbi nam mattis phasellus vehicula facilisis suscipit posuere metus, iaculis vestibulum viverra nisl ullamcorper lectus curabitur himenaeos dictumst malesuada tempor, cras maecenas enim est eu turpis hac sociosqu tellus magnis. Sociosqu varius feugiat volutpat justo fames magna malesuada, viverra neque nibh parturient eu nascetur, cursus sollicitudin placerat lobortis nunc imperdiet. Leo lectus euismod morbi placerat pretium aliquet ultricies metus, augue turpis vulputa
te dictumst mattis egestas laoreet, cubilia habitant magnis lacinia vivamus etiam aenean.
"""
