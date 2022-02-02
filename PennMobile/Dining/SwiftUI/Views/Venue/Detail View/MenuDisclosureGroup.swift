//
//  MenuDisclosureGroup.swift
//  PennMobile
//
//  Created by CHOI Jongmin on 18/1/2021.
//  Copyright © 2021 PennLabs. All rights reserved.
//

import SwiftUI

struct DiningMenuSectionRow: View {
    @Binding var isExpanded: Bool
    let title: String

    init(isExpanded: Binding<Bool>, title: String) {
        self.title = title.capitalizeMainWords()
        self._isExpanded = isExpanded
    }

    var body: some View {
        HStack {
            Text(title)

            Spacer()

            Image(systemName: "chevron.right.circle")
                .rotationEffect(.degrees(isExpanded ? -90 : 90))
                .frame(width:28, alignment: .center)
        }
        .contentShape(Rectangle())
        .padding(.bottom)
        .onTapGesture {
            FirebaseAnalyticsManager.shared.trackEvent(action: "Open Menu", result: title, content: "")
            withAnimation {
                isExpanded.toggle()
            }
        }
    }
}

struct DiningMenuRow: View {

    init (for diningMenu: DiningMenu) {
        self.diningMenu = diningMenu
    }

    @State var isExpanded = false
    let diningMenu: DiningMenu

    var body: some View {
        VStack {
            DiningMenuSectionRow(isExpanded: $isExpanded, title: diningMenu.mealType)
                .font(.system(size: 21, weight: .medium))

            if isExpanded {
                ForEach(diningMenu.diningStations, id: \.self) { diningStation in
                    DiningStationRow(for: diningStation)
                }
                .padding(.leading)
                .transition(.moveAndFade)
            }
        }.clipped()
    }
}

struct DiningStationRow: View {

    init (for diningStation: DiningStation) {
        self.diningStation = diningStation
    }

    @State var isExpanded = false
    let diningStation: DiningStation

    var body: some View {
        VStack {
            DiningMenuSectionRow(isExpanded: $isExpanded, title: diningStation.stationDescription)
                .font(Font.system(size: 17))

            if isExpanded {
                ForEach(diningStation.diningStationItems, id: \.self) { diningStationItem in
                    DiningStationItemRow(for: diningStationItem)
                        .padding(.leading)
                }
                .transition(.moveAndFade)
            }
        }.clipped()

    }
}

struct DiningStationItemRow: View {

    init (for diningStationItem: DiningStationItem) {
        self.diningStationItem = diningStationItem
    }

    let diningStationItem: DiningStationItem

    var body: some View {
        VStack(alignment: .leading){
            HStack(alignment: .center) {
                Text(diningStationItem.title.capitalizeMainWords())
                    .font(Font.system(size: 17))

                ForEach(diningStationItem.tableAttribute.attributeDescriptions, id: \.self) { attribute in
                    //Unlike UIKit, image will simply not appear if it doesn't exist in assets
                    Image(attribute.description)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20.0,height:20)

                }
                Spacer()
            }.padding(.bottom, 3)

            Text(diningStationItem.description)
                .font(.system(size: 17, weight: .thin))
                .fixedSize(horizontal: false, vertical: true)
        }.padding(.bottom)
    }
}

extension AnyTransition {
    static var moveAndFade: AnyTransition {
        let insertion = AnyTransition
                            .opacity.animation(.easeInOut(duration: 0.7))
                            .combined(with: .move(edge: .top)).animation(.easeInOut)

        let removal = AnyTransition
            .opacity.animation(.easeInOut(duration: 0.1))
            .combined(with: .move(edge: .top)).animation(.easeInOut)

        return .asymmetric(insertion: insertion, removal: removal)
    }
}

@available(iOS 14, *)
struct MenuDisclosureGroup_Previews: PreviewProvider {
    static var previews: some View {
        let diningVenues: DiningMenuAPIResponse = Bundle.main.decode("mock_menu.json")

        return NavigationView {
            ScrollView {
                VStack {
                    DiningVenueDetailMenuView(menus: diningVenues.document.menuDocument.menus)
                    Spacer()
                }
            }.navigationTitle("Dining")
            .padding()
        }
    }
}

extension String {
    func capitalizeMainWords() -> String {
        let nonCaptializingSet: Set = [
            "a", "an", "the", "for", "and", "nor", "but", "or", "yet", "so", "with", "at", "around", "by", "after", "along", "for", "from", "of", "on", "to", "with", "without"
        ]

        return self.split(separator: " ").map({nonCaptializingSet.contains(String($0)) ? $0.lowercased() : $0.capitalized}).joined(separator: " ")
    }
}
