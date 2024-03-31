//
//  ChatMessageView.swift
//  PennMobile
//
//  Created by Jon Melitski on 3/23/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import SwiftUI

struct ChatMessageView: View, Animatable {
    @State var timeDelayBeforeShow: Int
    
    let username: String
    
    
    let message: ChatMessage
    
    init(message: ChatMessage, username: String?) {
        self.message = message
        self.username = username ?? "Me"
        _timeDelayBeforeShow = State(initialValue: message.timeDelay)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                Text(message.sender == .server ? "Penn Mobile AI" : username)
                    .font(.headline)
                Text(message.date.formatted(.dateTime))
                    .font(.caption)
            }
            if(timeDelayBeforeShow == 0) {
                Text(message.messageText)
            } else {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            }
        }
        
        .onAppear {
            Task {
                try? await Task.sleep(nanoseconds: UInt64(1000000 * timeDelayBeforeShow))
                timeDelayBeforeShow = 0
            }
        }
        
    }
}
