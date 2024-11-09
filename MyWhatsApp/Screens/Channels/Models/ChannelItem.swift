//
//  ChannelItem.swift
//  MyWhatsApp
//
//  Created by Nguyen Huu Nghia on 4/11/24.
//

import Foundation
import Firebase

struct ChannelItem: Identifiable, Hashable {
    var id: String
    var name: String?
    var creationDate: Date
    var createdBy: String
    var lastMessage: String
    var lastMessageTimestamp: Date
    var adminUids: [String]
    var memberUids: [String]
//    var membersCount: UInt /// Unassign Int because it can't really be less than 0
    var membersCount: Int
    private var thumbnailUrl: String?
    var members: [UserItem] /// Don't store in Firabase DB
    
    var isGroupChat: Bool {
        return membersCount > 2
    }
    
    var membersExcludingMe: [UserItem] {
        guard let currentUid = Auth.auth().currentUser?.uid else { return [] }
        return members.filter { $0.uid != currentUid }
    }
    
    var title: String {
        if let name = name {
            return name
        }
        
        if isGroupChat {
            return groupMemberName
        } else {
            return membersExcludingMe.first?.username ?? "Unknown"
        }
    }
    
    private var groupMemberName: String {
        let membersCount = membersCount - 1 /// Minus one is we're trying to subtract the currently logged in user
        let fullNames: [String] = membersExcludingMe.map { $0.username }
        
        if membersCount == 2 {
            /// username1 and username2
            return fullNames.joined(separator: " and ")
        } else if membersCount > 2 {
            /// username1, username2 and 10 others
            let remainingCount = membersCount - 2
            return fullNames.prefix(2).joined(separator: ", ") + " and \(remainingCount) " + "others"
        }
        return "Unknown"
    }
    
    var isCreatedByMe: Bool {
        return createdBy == Auth.auth().currentUser?.uid
    }
    
    var creatorName: String {
        return members.first { $0.uid == createdBy }?.username ?? "Someone"
    }
    
    var coverImageUrl: String? {
        if let thumbnailUrl = thumbnailUrl {
            return thumbnailUrl
        }
        
        if isGroupChat == false {
            return membersExcludingMe.first?.profileImageUrl
        }
        
        return nil
    }
    
    static let placeholder = ChannelItem.init(id: "1", creationDate: Date(), createdBy: "", lastMessage: "Hello World!", lastMessageTimestamp: Date(), adminUids: [], memberUids: [], membersCount: 2, members: [])
    
}

extension ChannelItem {
    init(_ dict: [String: Any]) {
        self.id = dict[.id] as? String ?? ""
        self.name = dict[.name] as? String? ?? nil
        let creationInterval = dict[.creationDate] as? Double ?? 0
        self.creationDate = Date(timeIntervalSince1970: creationInterval)
        self.createdBy = dict[.createdBy] as? String ?? ""
        self.lastMessage = dict[.lastMessage] as? String ?? ""
        let lastMsgTimestampInterval = dict[.lastMessageTimestamp] as? Double ?? 0
        self.lastMessageTimestamp = Date(timeIntervalSince1970: lastMsgTimestampInterval)
        self.adminUids = dict[.adminUids] as? [String] ?? []
        self.memberUids = dict[.memberUids] as? [String] ?? []
        self.membersCount = dict[.membersCount] as? Int ?? 0
        self.thumbnailUrl = dict[.thumbnailUrl] as? String ?? nil
        self.members = dict[.members] as? [UserItem] ?? []
    }
}

extension String {
    static let id = "id"
    static let name = "name"
    static let creationDate = "creationDate"
    static let createdBy = "createdBy"
    static let lastMessage = "lastMessage"
    static let lastMessageTimestamp = "lastMessageTimestamp"
    static let adminUids = "adminUids"
    static let memberUids = "memberUids"
    static let membersCount = "membersCount"
    static let thumbnailUrl = "thumbnailUrl"
    static let members = "members"
}
