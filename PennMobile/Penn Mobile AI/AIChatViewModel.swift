//
//  AIChatViewModel.swift
//  PennMobile
//
//  Created by Jon Melitski on 3/22/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import Foundation

@MainActor
public class AIChatViewModel: ObservableObject {
    private let model: AIChatModel = AIChatModel()
    
    @Published var thread: [ChatMessage] = []
    
    func processUserMessage(msg: String) {

            model.addMessage(message: ChatMessage(messageText: msg, sender: .user, timeDelay: 0))
            thread = model.messages
        
        Task {
            let newMessage = await model.generateResponse(base: ChatMessage(messageText: msg, sender: .user, timeDelay: 0))
            
            model.addMessage(message: newMessage)
            
            thread = model.messages
        }
    }  
}
