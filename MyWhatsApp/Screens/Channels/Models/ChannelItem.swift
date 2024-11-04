//
//  ChannelItem.swift
//  MyWhatsApp
//
//  Created by Nguyen Huu Nghia on 4/11/24.
//

import Foundation

struct ChannelItem: Identifiable {
    var id: String
    var name: String?
    var lastMessage: String
    var creationDate: Date
    var lastMessageTimestamp: Date
    var membersCount: UInt /// Unassign Int because it can't really be less than 0
    var adminUids: [String]
    var memberUids: [String]
    var members: [UserItem]
    var thumbnailUrl: String?
    
    var isGroupChat: Bool {
        return membersCount > 2
    }
    
    static let placeholder = ChannelItem.init(id: "1", lastMessage: "Hello World!", creationDate: Date(), lastMessageTimestamp: Date(), membersCount: 2, adminUids: [], memberUids: [], members: [])
}
