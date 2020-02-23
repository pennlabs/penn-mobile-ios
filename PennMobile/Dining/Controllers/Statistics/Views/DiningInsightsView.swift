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
typealias DiningInsightCard = AnyView

@available(iOS 13, *)
struct DiningInsightsView: View {
    
    @State var cards: [DiningInsightCard]
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(0..<cards.count) { index in
                    self.cards[index].padding([.leading, .trailing, .top])
                }
                Spacer().frame(height: 300) // Not sure why we need this extra space, but we do
            }
        }
    }
}

@available(iOS 13, *)
struct DiningInsightsView_Previews: PreviewProvider {
    static var previews: some View {
        DiningInsightsView(cards: [DiningInsightCard(Text("This is")), DiningInsightCard(Text("an array")), DiningInsightCard(Image(systemName: "gamecontroller"))])
    }
}
