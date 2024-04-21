//
//  ChatMessage.swift
//  PennMobile
//
//  Created by Jon Melitski on 3/22/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import Foundation

struct ChatMessage: Equatable, Identifiable{
    public var messageText: String
    public let sender: MessageSender
    public let date = Date()
    public let timeDelay: Int
    public let id = UUID()
}

enum MessageSender {
    case user, server
}
