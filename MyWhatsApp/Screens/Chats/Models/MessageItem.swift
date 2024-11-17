//
//  MessageItem.swift
//  MyWhatsApp
//
//  Created by Nguyen Huu Nghia on 27/10/24.
//

import Foundation
import SwiftUI
import Firebase

struct MessageItem: Identifiable {
    let id: String
    let isGroupChat: Bool
    let text: String
    let thumbnailUrl: String?
    let type: MessageType
    let ownerUid: String
    let timestamp: Date
    var sender: UserItem?
    
    /// change direction from constant to a computed property
//    let direction: MessageDirection
    var direction: MessageDirection {
        return ownerUid == Auth.auth().currentUser?.uid ? .sent : .received
    }
    
    static let sentPlaceholder = MessageItem(id: UUID().uuidString, isGroupChat: true, text: "Wow beautiful Motki Bubu hotty hotty", thumbnailUrl: nil, type: .text, ownerUid: "1", timestamp: Date())
    static let recievedPlaceholder = MessageItem(id: UUID().uuidString, isGroupChat: false, text: "Motaa Dudu", thumbnailUrl: nil, type: .text, ownerUid: "2", timestamp: Date())
    
    var alignment: Alignment {
        return direction == .sent ? .trailing : .leading
    }
    
    var horizontalAliment: HorizontalAlignment {
        return direction == .sent ? .trailing : .leading
    }
    
    var backgroundColor: Color {
        return direction == .sent ? .bubbleGreen : .bubbleWhite
    }
    
    var showGroupPartnerInfo: Bool {
        return isGroupChat && direction == .received
    }
    
    var leadingPadding: CGFloat {
        return direction == .sent ? horizontalPadding : 0
    }
    
    var trailingPadding: CGFloat {
        return direction == .sent ? 0 : horizontalPadding
    }
    
    private let horizontalPadding: CGFloat = 25
    
    static let stubMessages: [MessageItem] = [
        MessageItem(id: UUID().uuidString, isGroupChat: false, text: "Hi There", thumbnailUrl: nil, type: .text, ownerUid: "3", timestamp: Date()),
        MessageItem(id: UUID().uuidString, isGroupChat: true, text: "Check out this Photo", thumbnailUrl: nil, type: .photo, ownerUid: "4", timestamp: Date()),
        MessageItem(id: UUID().uuidString, isGroupChat: false, text: "Play out this Video", thumbnailUrl: nil, type: .video, ownerUid: "5", timestamp: Date()),
        MessageItem(id: UUID().uuidString, isGroupChat: false, text: "", thumbnailUrl: nil, type: .audio, ownerUid: "6", timestamp: Date())
    ]
}

extension MessageItem {
    init(id: String, isGroupChat: Bool, dict: [String: Any]) {
        self.id = id
        self.isGroupChat = isGroupChat
        self.text = dict[.text] as? String ?? ""
        self.thumbnailUrl = dict[.thumbnailUrl] as? String ?? nil
        let type = dict[.type] as? String ?? "text"
        self.type = MessageType(type) ?? .text
        self.ownerUid = dict[.ownerUid] as? String ?? ""
        let timestampInterval = dict[.timestamp] as? TimeInterval ?? 0
        self.timestamp = Date(timeIntervalSince1970: timestampInterval)
    }
}

extension String {
    static let text = "text"
    static let `type` = "type"
    static let timestamp = "timestamp"
    static let ownerUid = "ownerUid"
    static let thumbnailWidth = "thumbnailWidth"
    static let thumbnailHeight = "thumbnailHeight"
}
