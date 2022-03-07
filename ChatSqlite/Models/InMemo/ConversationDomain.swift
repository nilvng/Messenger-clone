//
//  ConversationsModel.swift
//  ChatSqlite
//
//  Created by LAP11353 on 20/12/2021.
//

import Foundation

struct ConversationDomain {
    static func fromFriend(friend: FriendDomain) -> ConversationDomain {
        return ConversationDomain(theme: .basic, thumbnail: nil,
                                  title: friend.name, id: friend.id,
                                  members: friend.id,
                                  lastMsg: "", timestamp: Date())
    }
    
    var theme: Theme?
    
    var thumbnail: String?
    
    var title: String
    
    var id: String
    
    var members: String
    
    var lastMsg: String
    
    var timestamp: Date
    
    
}

extension ConversationDomain : Equatable {
    static func == (lhs: ConversationDomain, rhs: ConversationDomain) -> Bool {
        return lhs.id == rhs.id
    }
}
