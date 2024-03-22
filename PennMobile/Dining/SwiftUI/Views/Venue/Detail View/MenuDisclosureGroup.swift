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
                                .font(.callout)
                                .padding(3)
                                .onTapGesture {
                                    withAnimation {
                                        internalSelection = diningStation
                                    }
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
    @State var posDictionary: [DiningStation: CGRect] = [:]
    @State var scrollNext: DiningStation?
    @State var checkDictionary = true
    
    var parentScrollProxy: ScrollViewProxy
    
    var body: some View {
        VStack {
            ForEach(currentMenu?.stations ?? [], id: \.vertUID) { station in
                DiningStationRow(diningStation: station)
                    .bold(selectedStation != nil && selectedStation == station)
                    .background {
                        GeometryReader { proxy in
                            Spacer()
                                .onChange(of: parentScrollOffset) { _ in
                                    posDictionary.updateValue(proxy.frame(in: .global), forKey: station)
                                }
                        }
                    }
            }
            .onChange(of: parentScrollOffset) { _ in
                if (checkDictionary) {
                    /// The most visible element is that which has the highest share of the viewport,
                    /// relative to its own height. If two elements are equally visible, the one whose
                    /// midpoint is closest to y = 350 is the one that is more visible.
                    let sortedDict = posDictionary.sorted { (el1, el2) in
                        let (_, rect1) = el1
                        let (_, rect2) = el2
                        
                        let intersection1 = rect1.intersection(UIScreen.main.bounds)
                        let intersection2 = rect2.intersection(UIScreen.main.bounds)
                        
                        let pct1 = Int((intersection1.height * 100)/rect1.height)
                        let pct2 = Int((intersection2.height * 100)/rect2.height)
                        
                        return pct1 > pct2 ||
                            (pct1 == pct2 && abs(rect1.midY-350.0) < abs(rect2.midY-350.0))
                    }
                    
                    if let (st, _) = sortedDict.first {
                        scrollNext = st
                        selectedStation = st
                    }
                }
            }
            .onChange(of: currentMenu) { _ in
                posDictionary = [:]
            }
            .onChange(of: selectedStation) { new in
                /// There's a lot of state changes going on here, becuase there's two
                /// ScrollViewReaders interacting. On a change of selection due to vertical scrolling,
                /// We don't want to reanimate the vertical scrolling window, since it wouldn't feel natural.
                ///
                /// Further, on vertical scroll changes as a result of clicking an item on the header bar,
                /// we do not wish to adjust the selected station based on scroll (since the user just
                /// selected the station)
                if let newStation = new {
                    // Don't animate if we just changed this value by vertical scrolling.
                    if (newStation != scrollNext) {
                        
                        // Don't adjust anything on scroll while we're animating
                        checkDictionary = false
                        
                        /// iOS 17 added an onCompletion method on an animation, but
                        /// PennMobile is not built for iOS 17 yet, so we are left with just
                        /// Dispatching an event to fire after the duration of the animation.
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
    var gridColumns: [GridItem] = []
    
    init(diningStation: DiningStation) {
        self.diningStation = diningStation
        
        for _ in 0..<DiningStation.getColumns(station: diningStation) {
            gridColumns.append(GridItem(alignment: .leading))
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                Text(diningStation.name.capitalizeMainWords())
                    .font(.title)
                    .bold()
                Spacer()
            }
            
            LazyVGrid(columns: gridColumns, alignment: .listRowSeparatorLeading, spacing: 10) {
                ForEach(diningStation.items.sorted(by: {$0.name.count > $1.name.count}), id: \.self) { item in
                    DiningStationItemView(item: item)
                        .padding(4)
                }
            }
        }
    }
}

struct DiningStationItemView: View {
    let item: DiningStationItem
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                Text("• ")
                Text(item.name.capitalizeMainWords())
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            Spacer()
        }
    }
}

struct DiningMenuSectionRow: View {
    let station: DiningStation

    var body: some View {
        Text("a")
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
            }.onChange(of: isExpanded) { _ in
                print(diningStationItem.desc)
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
