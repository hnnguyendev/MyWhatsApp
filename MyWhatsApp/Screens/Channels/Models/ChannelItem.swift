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
    var creationDate: Date
    var lastMessage: String
    var lastMessageTimestamp: Date
    var adminUids: [String]
    var memberUids: [String]
    var membersCount: UInt /// Unassign Int because it can't really be less than 0
    var thumbnailUrl: String?
    var members: [UserItem] /// Don't store in Firabase DB
    
    var isGroupChat: Bool {
        return membersCount > 2
    }
    
    static let placeholder = ChannelItem.init(id: "1", creationDate: Date(), lastMessage: "Hello World!", lastMessageTimestamp: Date(), adminUids: [], memberUids: [], membersCount: 2, members: [])
}

extension ChannelItem {
    init(_ dict: [String: Any]) {
        self.id = dict[.id] as? String ?? ""
        self.name = dict[.name] as? String ?? ""
        let creationInterval = dict[.creationDate] as? Double ?? 0
        self.creationDate = Date(timeIntervalSince1970: creationInterval)
        self.lastMessage = dict[.lastMessage] as? String ?? ""
        let lastMsgTimestampInterval = dict[.lastMessageTimestamp] as? Double ?? 0
        self.lastMessageTimestamp = Date(timeIntervalSince1970: lastMsgTimestampInterval)
        self.adminUids = dict[.adminUids] as? [String] ?? []
        self.memberUids = dict[.memberUids] as? [String] ?? []
        self.membersCount = dict[.membersCount] as? UInt ?? 0
        self.thumbnailUrl = dict[.thumbnailUrl] as? String ?? nil
        self.members = dict[.members] as? [UserItem] ?? []
    }
}

extension String {
    static let id = "id"
    static let name = "name"
    static let creationDate = "creationDate"
    static let lastMessage = "lastMessage"
    static let lastMessageTimestamp = "lastMessageTimestamp"
    static let adminUids = "adminUids"
    static let memberUids = "memberUids"
    static let membersCount = "membersCount"
    static let thumbnailUrl = "thumbnailUrl"
    static let members = "members"
}
