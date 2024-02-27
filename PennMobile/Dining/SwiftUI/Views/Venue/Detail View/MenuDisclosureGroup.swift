//
//  MenuDisclosureGroup.swift
//  PennMobile
//
//  Created by CHOI Jongmin on 18/1/2021.
//  Copyright © 2021 PennLabs. All rights reserved.
//

import SwiftUI
import PennMobileShared

struct DiningMenuViewHeader: View {
    @Binding var diningMenu: DiningMenu?
    @Binding var selectedStation: DiningStation?
    
    @State var internalSelection: DiningStation?
    
    var body: some View {
        VStack {
            Divider()
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 30) {
                        ForEach(diningMenu?.stations ?? [], id: \.horizUID) { diningStation in
                            Text(diningStation.name.uppercased())
                                .bold(selectedStation != nil && selectedStation == diningStation)
                                .underline(selectedStation != nil && selectedStation == diningStation)
                                .font(.system(size: 16))
                                .onTapGesture {
                                    internalSelection = diningStation
                                }
                    }.onChange(of: internalSelection) { new in
                        if let newStation = new {
                            withAnimation {
                                proxy.scrollTo(newStation.horizUID, anchor: .leading)
                            }
                        }
                        selectedStation = internalSelection
                        
                        }
                    }
                }
                .padding(.vertical, 2)
            }
            Divider()
        }.background(Color(.systemBackground))
            .onAppear {
                internalSelection = selectedStation
            }
            .onChange(of: selectedStation) { _ in
                internalSelection = selectedStation
            }
    }
}

struct DiningStationRowStack: View {
    @Binding var selectedStation: DiningStation?
    @Binding var currentMenu: DiningMenu?
    
    @Binding var parentScrollOffset: CGPoint
    var parentScrollProxy: ScrollViewProxy
    @State var posDictionary: [DiningStation: CGRect] = [:]
    @State var scrollNext: DiningStation?
    @State var checkDictionary = true
    
    var body: some View {
        VStack {
            ForEach(currentMenu?.stations ?? [], id: \.vertUID) { station in
                DiningStationRow(diningStation: station)
                    .bold(selectedStation != nil && selectedStation == station)
                    .background {
                        GeometryReader { proxy in
                            Spacer()
                                .onChange(of: parentScrollOffset) { _ in
                                    let thisRect = proxy.frame(in: .global)

                                    posDictionary.updateValue(thisRect, forKey: station)
                                }
                        }
                    }
            }
            .onChange(of: parentScrollOffset) { _ in
                if (checkDictionary) {
                    if let defaultStation = selectedStation {
                        var mostVisible = (defaultStation, 0.0 as CGFloat, 0)
                        
                        posDictionary.forEach { station, rect in
                            let (_, mvMidY, mvPct) = mostVisible
                            
                            let intersection = rect.intersection(UIScreen.main.bounds)
                            let pctInFrame = Int((intersection.height * 100)/rect.height)
                            
                            if (pctInFrame > mvPct) {
                                mostVisible = (station, rect.midY, pctInFrame)
                            }
                            
                            if (pctInFrame == mvPct && abs(rect.midY - 350.0) < abs(mvMidY - 350.0)) {
                                mostVisible = (station, rect.midY, pctInFrame)
                            }
                        }
                        
                        let (st, _, _) = mostVisible
                        scrollNext = st
                        selectedStation = st
                    }
                }
            }
            
            .onChange(of: currentMenu) { _ in
                posDictionary = [:]
            }
            .onChange(of: selectedStation) { new in
                if let newStation = new {
                    if (newStation != scrollNext) {
                        checkDictionary = false
                        withAnimation(.easeInOut(duration: 0.3)) {
                            parentScrollProxy.scrollTo(newStation.vertUID, anchor: .top)
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            checkDictionary = true
                        }
                    }
                }
                scrollNext = nil
            }
        }
    }
}

struct DiningStationRow: View {
    @State var isExpanded = true
    let diningStation: DiningStation

    var body: some View {
        VStack(spacing: 0) {
            DiningMenuSectionRow(isExpanded: $isExpanded, title: diningStation.name)
                .font(Font.system(size: 17))
                .padding()
                .background(Color.uiCardBackground.cornerRadius(8))
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
        // Regex for commas (this matches all commas not inside parenthesis): ,\s*(?=[^)]*(?:\(|$))
        self.ingredients = Array(Set(diningStationItem.ingredients.split(usingRegex: ",\\s*(?=[^)]*(?:\\(|$))")))
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

//struct MenuDisclosureGroup_Previews: PreviewProvider {
//    static var previews: some View {
//        let diningVenues: MenuList = Bundle.main.decode("mock_menu.json")
//
//        return NavigationView {
//            ScrollView {
//                VStack {
//                    DiningVenueDetailMenuView(menus: diningVenues.menus, id: 1)
//                    Spacer()
//                }
//            }.navigationTitle("Dining")
//            .padding()
//        }
//    }
//}

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
    // Used for splitting string by regex expression
    func split(usingRegex pattern: String) -> [String] {
        // Crashes when you pass invalid pattern
        let regex = try! NSRegularExpression(pattern: pattern)
        let matches = regex.matches(in: self, range: NSRange(0..<utf16.count))
        let ranges = [startIndex..<startIndex] + matches.map {Range($0.range, in: self)!} + [endIndex..<endIndex]
        return (0...matches.count).map {String(self[ranges[$0].upperBound..<ranges[$0+1].lowerBound])}
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
