//
//  PrivacyPermissionView.swift
//  PennMobile
//
//  Created by Dominic Holmes on 12/31/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//
import SwiftUI
import Combine

@available(iOS 13, *)
struct PermissionView: View {
    
    enum Choice {
        case affirmative, negative, close, moreInfo
    }
    
    @ObservedObject var delegate: PrivacyPermissionDelegate
    let title: String
    let privacyString: String
    let affirmativeString: String
    let negativeString: String
    let moreInfoString: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 17) {
            
            Image("pennmobile")
                .resizable()
                .frame(minWidth: 45, maxWidth: 70, minHeight: 45, maxHeight: 70)
                .scaledToFit()
                .padding(.vertical, 17)
            
            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text(privacyString)
                .padding()
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.8)
                .layoutPriority(1)
            
            Button(action: moreAboutLabs) {
                HStack {
                    Text(moreInfoString)
                    Image(systemName: "arrow.right.circle")
                }
                .font(.system(size: 17, weight: .semibold))
            }
            
            Spacer()

            FullButton(action: shareCourses, content: Text(affirmativeString), foreground: .white, background: .blue)
            FullButton(action: doNotShareCourses, content: Text(negativeString), foreground: .primary, background: .clear)
        }
    }
    
    func moreAboutLabs() {
        delegate.userDecision = .moreInfo
    }
    
    func shareCourses() {
        delegate.userDecision = .affirmative
    }
    
    func doNotShareCourses() {
        delegate.userDecision = .negative
    }
    
    func closeView() {
        delegate.userDecision = .close
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
struct PermissionView_Previews: PreviewProvider {
    static var previews: some View {
        PermissionView(delegate: PrivacyPermissionDelegate(), title: "Share Courses", privacyString: "privacy string", affirmativeString: "Share Courses with Penn Labs", negativeString: "Don't Share", moreInfoString: "More about Penn Labs")
    }
}

/*
 // Example usage
 
 // !!!! VERY IMPORTANT: "cancellable" should be an optional var of type "Any". This keeps the subsciption from being deallocated.
 
 if #available(iOS 13, *) {
     let prompt = """
     Help us improve our course recommendation algorithms by sharing  anonymized course enrollments with Penn Labs. You can change your decision later.
     No course enrollments are ever associated with your name, PennKey, or email.
     This allows Penn Labs to recommend courses to other students based on what you’ve taken, improving student life for everyone at Penn. That’s what we do 💖
     """
     
     let delegate = PrivacyPermissionDelegate()
     let vc = UIHostingController(rootView: PermissionView(delegate: delegate, title: "Share Courses", privacyString: prompt, affirmativeString: "Share Courses with Penn Labs", negativeString: "Don't Share", moreInfoString: "More about Penn Labs"))
     present(vc, animated: true)
     self.cancellable = delegate.objectDidChange.sink { (delegate) in
         if let decision = delegate.userDecision {
             switch decision {
             case .affirmative: print("CONSENT GIVEN")
             case .negative: print("NO CONSENT GIVEN")
             case .moreInfo: print("INFO REQUESTED")
             case .close: print("CLOSE VIEW")
             }
             //vc.dismiss(animated: true, completion: nil)
         }
     }
 } else {
     // Fallback on earlier versions
 }
 
 */
