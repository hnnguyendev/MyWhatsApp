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
    let text: String
    let type: MessageType
    let ownerUid: String
    /// change direction from constant to a computed property
//    let direction: MessageDirection
    var direction: MessageDirection {
        return ownerUid == Auth.auth().currentUser?.uid ? .sent : .received
    }
    
    static let sentPlaceholder = MessageItem(id: UUID().uuidString, text: "Wow beautiful Motki Bubu hotty hotty", type: .text, ownerUid: "1")
    static let recievedPlaceholder = MessageItem(id: UUID().uuidString, text: "Motaa Dudu", type: .text, ownerUid: "2")
    
    var alignment: Alignment {
        return direction == .sent ? .trailing : .leading
    }
    
    var horizontalAliment: HorizontalAlignment {
        return direction == .sent ? .trailing : .leading
    }
    
    var backgroundColor: Color {
        return direction == .sent ? .bubbleGreen : .bubbleWhite
    }
    
    static let stubMessages: [MessageItem] = [
        MessageItem(id: UUID().uuidString, text: "Hi There", type: .text, ownerUid: "3"),
        MessageItem(id: UUID().uuidString, text: "Check out this Photo", type: .photo, ownerUid: "4"),
        MessageItem(id: UUID().uuidString, text: "Play out this Video", type: .video, ownerUid: "5"),
        MessageItem(id: UUID().uuidString, text: "", type: .audio, ownerUid: "6")
    ]
}

extension MessageItem {
    init(id: String, dict: [String: Any]) {
        self.id = id
        self.text = dict[.text] as? String ?? ""
        let type = dict[.type] as? String ?? "text"
        self.type = MessageType(type)
        self.ownerUid = dict[.ownerUid] as? String ?? ""
    }
}

extension String {
    static let text = "text"
    static let `type` = "type"
    static let timestamp = "timestamp"
    static let ownerUid = "ownerUid"
}
