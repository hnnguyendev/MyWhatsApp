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
    typealias userId = String
    typealias emoji = String
    typealias emojiCount = Int
    let id: String
    let isGroupChat: Bool
    let text: String
    let thumbnailUrl: String?
    var thumbnailWidth: CGFloat?
    var thumbnailHeight: CGFloat?
    let type: MessageType
    let ownerUid: String
    let timestamp: Date
    var sender: UserItem?
    var videoUrl: String?
    var audioUrl: String?
    var audioDuration: TimeInterval?
    var reactions: [emoji: emojiCount] = [:]
    var userReactions: [userId: emoji] = [:]
    
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
    
    var imageSize: CGSize {
        let photoWidth = thumbnailWidth ?? 0
        let photoHeight = thumbnailHeight ?? 0
        let imageHeight = CGFloat(photoHeight / photoWidth * imageWidth)
        return CGSize(width: imageWidth, height: imageHeight)
    }
    
    var imageWidth: CGFloat {
        /// UIScreen.width / 1.5
        let photoWidth = (UIWindowScene.current?.screenWidth ?? 0) / 1.5
        return photoWidth
    }
    
    var audioDurationInString: String {
        return audioDuration?.formatElapsedTime ?? "00:00"
    }
    
    var isSentByMe: Bool {
        return ownerUid == Auth.auth().currentUser?.uid ?? ""
    }
    
    var menuAnchor: UnitPoint {
        return direction == .received ? . leading : .trailing
    }
    
    var reactionAnchor: Alignment {
        return direction == .sent ? .bottomTrailing : .bottomLeading
    }
    
    var hasReaction: Bool {
        return !reactions.isEmpty
    }
    
    var currentUserHasReacted: Bool {
        guard let currentUid = Auth.auth().currentUser?.uid else { return false }
        return userReactions.contains { $0.key == currentUid }
    }
    
    var currentUserReaction: String? {
        guard let currentUid = Auth.auth().currentUser?.uid else { return nil }
        return userReactions[currentUid]
    }
    
    func containsSameOwner(as message: MessageItem) -> Bool {
        if let userA = message.sender, let userB = self.sender {
            return userA == userB
        } else {
            return false
        }
    }
    
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
        self.thumbnailWidth = dict[.thumbnailWidth] as? CGFloat ?? nil
        self.thumbnailHeight = dict[.thumbnailHeight] as? CGFloat ?? nil
        let type = dict[.type] as? String ?? "text"
        self.type = MessageType(type) ?? .text
        self.ownerUid = dict[.ownerUid] as? String ?? ""
        let timestampInterval = dict[.timestamp] as? TimeInterval ?? 0
        self.timestamp = Date(timeIntervalSince1970: timestampInterval)
        self.videoUrl = dict[.videoUrl] as? String ?? nil
        self.audioUrl = dict[.audioUrl] as? String ?? nil
        self.audioDuration = dict[.audioDuration] as? TimeInterval ?? nil
        self.reactions = dict[.reactions] as? [emoji: emojiCount] ?? [:]
        self.userReactions = dict[.userReactions] as? [userId: emoji] ?? [:]
    }
}

extension String {
    static let text = "text"
    static let `type` = "type"
    static let timestamp = "timestamp"
    static let ownerUid = "ownerUid"
    static let thumbnailWidth = "thumbnailWidth"
    static let thumbnailHeight = "thumbnailHeight"
    static let videoUrl = "videoUrl"
    static let audioUrl = "audioUrl"
    static let audioDuration = "audioDuration"
    static let reactions = "reactions"
    static let userReactions = "userReactions"
}
