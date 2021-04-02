//
//  DiningVenueRow.swift
//  PennMobile
//
//  Created by CHOI Jongmin on 5/6/2020.
//  Copyright © 2020 PennLabs. All rights reserved.
//

#if canImport(SwiftUI)
import SwiftUI
import KingfisherSwiftUI
#endif

@available(iOS 14, *)
struct DiningVenueRow: View {
    
    init(for venue: DiningVenue) {
        self.venue = venue
    }
    
    let venue: DiningVenue
    
    let scrollViewCoordName = "scrollViewCoordinateSpaceName"
    let fadeDistance: CGFloat = 10
    
    var body: some View {
        HStack(spacing: 13) {
            
            KFImage(venue.imageURL)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 100, height: 63.98)
                .background(Color.grey1)
                .clipShape(RoundedRectangle(cornerRadius: 7))
                
            VStack(alignment: .leading) {
                
                Label(venue.statusString, systemImage: circleImageString)
                    .labelStyle(VenueStatusLabelStyle())
                    .modifier(StatusColorModifier(for: venue))
                
                Text(venue.name)
                    .font(.system(size: 17, weight: .medium))
                    .minimumScaleFactor(0.2)
                    .lineLimit(1)
                
                Spacer()
            
                GeometryReader { scrollViewGeoProxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        ScrollViewReader { value in
                            HStack(spacing: 8) {
                                // Enumerating to use indices as ids for ScrollViewReader
//                                ForEach(0..<10) { index in
                                ForEach(0..<venue.humanFormattedHoursArrayForToday.count) { index in
                                    
                                    let humanFormattedHours = venue.humanFormattedHoursArrayForToday[index]
//                                    let humanFormattedHours = "Text \(index)"
                                    let diningTimeWidth = CGFloat(Double(humanFormattedHours.count) * 7.5)
                                    
                                    GeometryReader { diningTimeGeoProxy in
                                        let minX = diningTimeGeoProxy.frame(in: .named(scrollViewCoordName)).minX
                                        
                                        Text(humanFormattedHours)
                                            .font(.system(size: 14, weight: .light))
                                            .frame(width: diningTimeWidth, height: scrollViewGeoProxy.size.height, alignment: .center)
//                                            .background(Color.grey6)
                                            .modifier(DiningTimeModifier(minX: minX, cellWidth: diningTimeWidth, scrollViewWidth: scrollViewGeoProxy.size.width, fadeDistance: fadeDistance))

                                    }
                                    .id(index)
                                    .frame(width: diningTimeWidth, height: scrollViewGeoProxy.size.height)
                                    .offset(x: fadeDistance)
                                }
                                
                                // TODO: decide on how to proceed
                                // Spacing to prevent ScrollView Reader from jumping
                                 Spacer(minLength: scrollViewGeoProxy.size.width/2)
                            }.onAppear(perform: {
                                // TODO: Scroll to nearest time id index
                                value.scrollTo(9, anchor: .center)
                            })
                        }
                    }
                    .offset(x: -fadeDistance)
                    .coordinateSpace(name: scrollViewCoordName)
                }
            }
        }
    }
    
    // TODO maybe move to DiningVenue+Extensions
    var circleImageString: String {
        if venue.hasMealsToday {
            if venue.isOpen {
                return "circle.fill"
            } else if venue.nextMeal != nil {
                return "pause.circle.fill"
            } else {
                return "xmark.circle.fill"
            }
        } else {
            return "xmark.circle.fill"
        }
    }
}

// MARK: - ViewModifiers
@available(iOS 14, *)
struct StatusColorModifier: ViewModifier {
    
    init(for venue: DiningVenue) {
        self.venue = venue
    }
    
    let venue: DiningVenue
    
    func body(content: Content) -> some View {
        if venue.hasMealsToday && venue.isOpen {
            if venue.isClosingSoon {
                return content.foregroundColor(Color.red)
            } else {
                switch venue.venueType {
                case .dining:
                    if venue.isMainDiningTimes {
                        return content.foregroundColor(Color.green)
                    } else {
                        return content.foregroundColor(Color.yellow)
                    }
                default:
                    return content.foregroundColor(Color.green)
                }
            }
        } else {
            return content.foregroundColor(Color.gray)
        }
    }
}

// TODO: Add Text Color and BackgroundColor Variable
@available(iOS 14, *)
struct DiningTimeModifier: ViewModifier {
    
    let minX: CGFloat
    let cellWidth: CGFloat
    let scrollViewWidth: CGFloat
    let fadeDistance: CGFloat

    func body(content: Content) -> some View {
        let rightOverflowAmount = minX + cellWidth + 2 * fadeDistance - scrollViewWidth
        let textColor = [Color(.systemBackground).opacity(0), .grey1]
        let cellColor = [Color(.systemBackground).opacity(0), .grey6]
        
        let textLeftGradient = LinearGradient(gradient: .init(colors: textColor), startPoint: .init(x: -(fadeDistance/2 + minX)/cellWidth, y: 0.5), endPoint: .init(x: -minX/cellWidth, y: 0.5))
        let textRightGradient = LinearGradient(gradient: .init(colors: textColor.reversed()), startPoint: .init(x: 1 - rightOverflowAmount/cellWidth, y: 0.5), endPoint: .init(x: 1 - (rightOverflowAmount - fadeDistance/2)/cellWidth, y: 0.5))
        let cellLeftGradient = LinearGradient(gradient: .init(colors: cellColor), startPoint: .init(x: -(fadeDistance + minX)/cellWidth, y: 0.5), endPoint: .init(x: -minX/cellWidth, y: 0.5))
        let cellRightGradient = LinearGradient(gradient: .init(colors: cellColor.reversed()), startPoint: .init(x: 1 - rightOverflowAmount/cellWidth, y: 0.5), endPoint: .init(x: 1 - (rightOverflowAmount - fadeDistance)/cellWidth, y: 0.5))
        
        return
            content
            .foregroundColor(.clear)
            .background(rightOverflowAmount > 0 ? textRightGradient : textLeftGradient)
            .mask(content)
            .background(rightOverflowAmount > 0 ? cellRightGradient : cellLeftGradient)
            .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

struct VenueStatusLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 4) {
            configuration.icon.font(.system(size: 9, weight: .semibold))
            configuration.title.font(.system(size: 11, weight: .semibold))
            Spacer()
        }
    }
}

@available(iOS 14, *)
struct DiningVenueRow_Previews: PreviewProvider {
    static var previews: some View {
        let diningVenues: DiningAPIResponse = Bundle.main.decode("sample-dining-venue.json")
        
        return NavigationView {
            List {
                NavigationLink(destination: Text("dfs")) {
                    DiningVenueRow(for: diningVenues.document.venues[0])
                }
            }
        }
    }
}


