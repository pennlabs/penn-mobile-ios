//
//  GSRTabPicker.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 2/19/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI

struct GSRTabPicker: View {
    @Binding var selection: GSRTab
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                ForEach(GSRTab.allCases, id: \.self) { tab in
                    Text(tab.titleText)
                        .foregroundStyle(selection == tab ? Color("baseLabsBlue") : Color.primary)
                        .font(.title3)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .onTapGesture {
                            withAnimation(.snappy(duration: 0.3)) {
                                selection = tab
                            }
                        }
                    Spacer()
                }
            }
            Rectangle()
                .frame(maxHeight: 1)
                .foregroundStyle(Color(UIColor.systemGray))
        }
    }
}
