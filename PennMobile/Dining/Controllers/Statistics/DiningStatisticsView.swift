//
//  DiningStatisticsView.swift
//  PennMobile
//
//  Created by Dominic Holmes on 2/21/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import Foundation
#if canImport(SwiftUI)
import SwiftUI
#endif

@available(iOS 13, *)
typealias DiningStatisticsCard = AnyView

@available(iOS 13, *)
struct DiningStatisticsView: View {
    
    @State var cards: [DiningStatisticsCard]
    
    var body: some View {
        List {
            ForEach(0..<cards.count) { index in
                self.cards[index]
            }
        }
    }
}

@available(iOS 13, *)
struct DiningStatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        DiningStatisticsView(cards: [DiningStatisticsCard(Text("This is")), DiningStatisticsCard(Text("an array")), DiningStatisticsCard(Image(systemName: "gamecontroller"))])
    }
}
