//
//  Toasts.swift
//  PennMobile
//
//  Created by Anthony Li on 11/17/23.
//  Copyright © 2023 PennLabs. All rights reserved.
//

import SwiftUI
import PennMobileShared

struct ToastView: View {
    let configuration: ToastConfiguration
    
    var body: some View {
        AnyView(configuration.content)
            .id(configuration.id)
            .tag(configuration.id)
            .fontWeight(.medium)
            .multilineTextAlignment(.center)
            .padding()
            .frame(maxWidth: 480)
            .background(Color.baseRed)
            .environment(\.colorScheme, .dark)
            .frame(maxWidth: .infinity)
            .background(Material.regular)
            .clipShape(.rect(cornerRadius: 14))
            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 2, y: 2)
            .padding(.horizontal)
    }
}

#Preview {
    ToastView(configuration: .init(message: "An error occurred"))
}
