//
//  AIChatView.swift
//  PennMobile
//
//  Created by Jon Melitski on 3/22/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import SwiftUI

struct AIChatView: View {
    @ObservedObject var vm = AIChatViewModel()
    
    @State var text = ""
    @FocusState var keyboardFocus
    
    let name: String?
    
    init() {
        
        if Account.getAccount()?.firstName != nil && Account.getAccount()?.lastName != nil {
            name = Account.getAccount()!.firstName! + " " + Account.getAccount()!.lastName!
        } else {
            name = nil
        }
        
    }
    var body: some View {
        VStack {
            VStack {
                VStack(alignment: .center) {
                    Image("logotype")
                    Text("Penn Mobile AI")
                        .font(.largeTitle)
                        .bold()
                    Text("(satire)")
                        .italic()
                }
                .padding()
                Spacer()
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 8) {
                            ForEach(vm.thread) { msg in
                                HStack {
                                    ChatMessageView(message: msg, username: name)
                                    Spacer()
                                }.id(msg.id)
                            }
                        }.onChange(of: vm.thread) {
                            withAnimation {
                                proxy.scrollTo(vm.thread.last?.id ?? nil, anchor: .top)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }.onTapGesture {
                keyboardFocus = false
            }
                
            TextField("Enter Message", text: $text)
            .onSubmit {
                vm.processUserMessage(msg: text)
                text = ""
            }
            .focused($keyboardFocus)
            .padding()
            .background(Color(UIColor.systemGray4))
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .padding()
        }
    }
}

#Preview {
    AIChatView()
}
