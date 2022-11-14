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
                .frame(width: 28, alignment: .center)
        }
        .contentShape(Rectangle())
        .padding([.top])
        .onTapGesture {
            FirebaseAnalyticsManager.shared.trackEvent(action: "Open Menu", result: title, content: "")
            withAnimation {
                isExpanded.toggle()
            }
        }
    }
}

struct DiningMenuRow: View {
    var diningMenu: DiningMenu
    @State var isExpanded = false
    var body: some View {
        VStack(spacing: 0) {
            DiningMenuSectionRow(isExpanded: $isExpanded, title: diningMenu.service)
                .font(.system(size: 21, weight: .medium))

            if isExpanded {
                ForEach(diningMenu.stations, id: \.self) { diningStation in
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
            DiningMenuSectionRow(isExpanded: $isExpanded, title: diningStation.name)
                .font(Font.system(size: 17))
            if isExpanded {
                Spacer(minLength: 10)
                ForEach(diningStation.items, id: \.self) { diningStationItem in
                    DiningStationItemRow(for: diningStationItem)
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
    @State private var showDetails = false

    var body: some View {
        let name = diningStationItem.name.capitalizeMainWords()
        Button {
            showDetails.toggle()
        } label: {
            HStack {
                Text(name)
                    .font(.system(size: 17))
                    .lineLimit(1)
                Spacer()
                Image(systemName: "info.circle")
                    .frame(width: 28, alignment: .center)
            }
            .padding([.leading])
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showDetails) {
            ItemView(name: name, description: diningStationItem.desc, ingredients: diningStationItem.ingredients.components(separatedBy: ", "))
        }
    }
}

struct ItemView: View {
    let name: String
    let description: String
    let ingredients: [String]
    var body: some View {
        VStack(alignment: .center) {
            Text(name)
                .font(.title)
                .padding()
            Divider()
            if description == "" && ingredients.count == 0 {
                Text("No details")
                    .padding()
                Spacer()
            } else {
                VStack(spacing: 10) {
                    if description != "" {
                        VStack {
                            Text("Description")
                                .font(.system(size: 21, weight: .medium))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text(description.capitalizeFirstLetter())
                                .font(.system(size: 17))
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding([.leading])
                        }
                        .padding()
                    }
                    if ingredients.count != 0 {
                        VStack {
                            Text("Ingredients")
                                .font(.system(size: 21, weight: .medium))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            ForEach(ingredients, id: \.self) { attribute in
                                Text("• " + attribute.capitalizeFirstLetter())
                                    .font(.system(size: 17))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding([.leading])
                            }
                            Spacer()
                        }
                        .padding()
                    }
                }
            }
        }
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

struct MenuDisclosureGroup_Previews: PreviewProvider {
    static var previews: some View {
        let diningVenues: MenuList = Bundle.main.decode("mock_menu.json")

        return NavigationView {
            ScrollView {
                VStack {
                    DiningVenueDetailMenuView(menus: diningVenues.menus, id: 1)
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
    func capitalizeFirstLetter() -> String {
        return self.prefix(1).capitalized + self.dropFirst()
    }
}
