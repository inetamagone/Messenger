//
//  ConversationModels.swift
//  Messenger
//
//  Created by ineta.magone on 21/06/2022.
//

import Foundation

struct Conversation {
    let id: String
    let name: String
    let otherUserEmail: String
    let latestMessage: LatestMessage
}

struct LatestMessage {
    let date: String
    let text: String
    let isRead: Bool
}

struct SearchResult {
    let name: String
    let email: String
}
