//
//  PrivacyPermissionView.swift
//  PennMobile
//
//  Created by Dominic Holmes on 12/31/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import SwiftUI

@available(iOS 13, *)
struct PrivacyPermissionView: View {
    
    let privacyString =
    """
    Help us improve our course recommendation algorithms by sharing  anonymized course enrollments with Penn Labs. You can change your decision later.

    No course enrollments are ever associated with your name, PennKey, or email.

    This allows Penn Labs to recommend courses to other students based on what you’ve taken, improving student life for everyone at Penn. That’s what we do 💖
    """
    
    var body: some View {
        VStack(alignment: .center, spacing: 17) {
            
            Image("pennmobile")
                .resizable()
                .frame(minWidth: 45, maxWidth: 70, minHeight: 45, maxHeight: 70)
                .scaledToFit()
                .padding(.vertical, 17)
            
            Text("Share Courses")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text(privacyString)
                .padding()
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.8)
                .layoutPriority(1)
            
            Button(action: moreAboutLabs) {
                HStack {
                    Text("More about Penn Labs")
                    Image(systemName: "arrow.right.circle")
                }
                .font(.system(size: 17, weight: .semibold))
            }
            
            Spacer()

            FullButton(action: shareCourses, content: Text("Share Courses with Penn Labs"), foreground: .white, background: .blue)
            FullButton(action: doNotShareCourses, content: Text("Don't Share"), foreground: .primary, background: .clear)
        }
    }
    
    func moreAboutLabs() {
        print("More about labs button")
    }
    
    func shareCourses() {
        print("Share Courses chosen")
    }
    
    func doNotShareCourses() {
        print("Don't Share Courses chosen")
    }
}

@available(iOS 13, *)
struct FullButton: View {
    var action: () -> Void
    var content: Text
    var foreground: Color? = .white
    var background: Color? = .blue
    
    var body: some View {
        Button(action: action) {
            content
                .frame(minWidth: 0, maxWidth: .infinity)
                .padding(.vertical, 20)
            .foregroundColor(foreground)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
            .padding(.horizontal)
        }
    }
}

@available(iOS 13, *)
struct PrivacyPermissionView_Previews: PreviewProvider {
    static var previews: some View {
        PrivacyPermissionView()
    }
}
