//
//  MenuDisclosureGroup.swift
//  PennMobile
//
//  Created by CHOI Jongmin on 18/1/2021.
//  Copyright © 2021 PennLabs. All rights reserved.
//

import SwiftUI

struct DiningMenuRow: View {
    var diningMenu: DiningMenu

    var body: some View {
        VStack(spacing: 0) {
            ForEach(diningMenu.stations, id: \.self) { diningStation in
                DiningStationRow(for: diningStation)
            }
        }
        .background(Color.grey7.cornerRadius(8))
    }
}

struct DiningStationRow: View {
    @State var isExpanded = false
    let diningStation: DiningStation
    init (for diningStation: DiningStation) {
        self.diningStation = diningStation
    }

    var body: some View {
        VStack(spacing: 0) {
            DiningMenuSectionRow(isExpanded: $isExpanded, title: diningStation.name)
                .font(Font.system(size: 17))
                .padding()
                .background(Color.uiCardBackground.cornerRadius(8))
                .shadow(color: Color.black.opacity(0.2), radius: 4, x: 2, y: 2)
            if isExpanded {
                VStack {
                    ForEach(diningStation.items, id: \.self) { diningStationItem in
                        DiningStationItemRow(isExpanded: false, for: diningStationItem)
                            .padding([.leading, .trailing])
                        if diningStationItem != diningStation.items.last {
                            Line()
                                .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                                .frame(height: 1)
                                .foregroundColor(Color.grey5)
                        }
                    }
                    .transition(.moveAndFade)
                }
                .padding([.top, .bottom])
            }
        }
        .background(Color.grey7.cornerRadius(8))
    }
}

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
            Image(systemName: "chevron.right")
                .rotationEffect(.degrees(isExpanded ? -90 : 90))
                .frame(width: 28, alignment: .center)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            FirebaseAnalyticsManager.shared.trackEvent(action: "Open Menu", result: title, content: "")
            withAnimation {
                isExpanded.toggle()
            }
        }
    }
}

struct DiningStationItemRow: View {

    let diningStationItem: DiningStationItem
    @State var isExpanded: Bool
    let ingredients: [String]

    init (isExpanded: Bool, for diningStationItem: DiningStationItem) {
        self._isExpanded = State(initialValue: isExpanded)
        self.diningStationItem = diningStationItem
        // This is only necessary because backend has duplicate ingredients, and some ingredients match item name exactly
        // Also should take into account parenthesis, but not implemented yet
        self.ingredients = Array(Set(diningStationItem.ingredients.components(separatedBy: ", ")))
            .filter {
                $0 != "" &&
                $0 != diningStationItem.name &&
                $0 != diningStationItem.name + "s" &&
                $0 != diningStationItem.name + "es" &&
                $0 != diningStationItem.name.dropLast() + "ies" &&
                !diningStationItem.name.lowercased().contains($0.lowercased())
            }
    }

    var body: some View {
        let name = diningStationItem.name.capitalizeMainWords()
        if diningStationItem.desc != "" || ingredients.count > 0 {
            HStack {
                Text(name)
                Spacer()
                Image(systemName: "chevron.right")
                    .rotationEffect(.degrees(isExpanded ? -90 : 90))
                    .frame(width: 28, alignment: .center)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation {
                    isExpanded.toggle()
                }
            }
            if isExpanded {
                ItemView(name: name, description: diningStationItem.desc, ingredients: ingredients)
            }
        } else {
            HStack {
                Text(name)
                Spacer()
            }
        }
    }
}

struct ItemView: View {
    let name: String
    let description: String
    let ingredients: [String]
    var body: some View {
        VStack(alignment: .center) {
            VStack(spacing: 0) {
                if description != "" {
                    Text(description.capitalizeFirstLetter())
                        .font(.system(size: 17))
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding([.leading])
                }
                if ingredients.count != 0 {
                    VStack {
                        ForEach(ingredients, id: \.self) { attribute in
                            Text("• " + attribute.capitalizeFirstLetter())
                                .font(.system(size: 17))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding([.leading])
                        }
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

        return self.split(separator: " ").map({nonCaptializingSet.contains(String($0)) ? $0.lowercased() : $0.capitalized}).joined(separator: " ").capitalizeFirstLetter()
    }
    func capitalizeFirstLetter() -> String {
        return self.prefix(1).capitalized + self.dropFirst()
    }
}

struct Line: Shape {
    func path(in rect: CGRect) -> Path {
       var path = Path()
       path.move(to: CGPoint(x: 0, y: 0))
       path.addLine(to: CGPoint(x: rect.width, y: 0))
       return path
    }
}
