//
//  CourseScheduleSharingSheet.swift
//  PennMobile
//
//  Created by Anthony Li on 12/22/23.
//  Copyright © 2023 PennLabs. All rights reserved.
//

import SwiftUI

struct CourseScheduleSharingSheet: View {
    @Environment(\.dismiss) var dismiss
    
    func save(value: Bool) {
        UserDefaults.standard.set(.courseSchedule, to: value)
        dismiss()
    }
    
    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 16) {
                Text("Sync your courses with Penn Course Plan?")
                    .font(.title)
                    .fontWeight(.bold)
                Text("We'll periodically fetch your courses from Path@Penn so you can see them right in Penn Course Plan.")
            }
            
            Spacer()
            
            Image(systemName: "clock.arrow.2.circlepath")
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 200)
                .foregroundStyle(.linearGradient(colors: [.navigation, .blueDark], startPoint: .topLeading, endPoint: .bottomTrailing))
            
            Spacer()
            
            VStack(spacing: 8) {
                Button {
                    save(value: true)
                } label: {
                    Text("Enable Course Sync")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
                
                Button("Don't Enable") {
                    save(value: false)
                }
                .fontWeight(.bold)
            }
            
            Text("You can change this at any time in Penn Mobile's Privacy settings.")
                .foregroundStyle(.secondary)
        }
        .multilineTextAlignment(.center)
        .padding(.top, 48)
        .padding(.bottom, 16)
        .padding(.horizontal)
    }
}

#Preview {
    Text("").sheet(isPresented: .constant(true)) {
        CourseScheduleSharingSheet()
            .interactiveDismissDisabled()
    }
}
