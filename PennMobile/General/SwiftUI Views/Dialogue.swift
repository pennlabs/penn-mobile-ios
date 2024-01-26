//
//  Dialogue.swift
//  PennMobile
//
//  Created by Christina Qiu on 1/26/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

#if canImport(SwiftUI)
import SwiftUI
import PennMobileShared
#endif

struct Dialogue: View {
    var body: some View {
        GeometryReader { geo in
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                .frame(width: geo.size.width-48, height: 70, alignment: .center)
                .font(Font(UIFont.primaryInformationFont))
                    .foregroundColor(.black)
                    .background(.red)
            Button(<#PrimitiveButtonStyleConfiguration#>)
                .buttonBorderShape(.roundedRectangle)
        }.frame(alignment: .center)
            
    }
}

#Preview {
    Dialogue()
}
