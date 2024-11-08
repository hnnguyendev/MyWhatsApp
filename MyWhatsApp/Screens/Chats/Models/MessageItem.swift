//
//  MessageItem.swift
//  MyWhatsApp
//
//  Created by Nguyen Huu Nghia on 27/10/24.
//

import Foundation
import SwiftUI

struct MessageItem: Identifiable {
    let id = UUID().uuidString
    let text: String
    let type: MessageType
    let direction: MessageDirection
    
    static let sentPlaceholder = MessageItem(text: "Wow beautiful Motki Bubu hotty hotty", type: .text, direction: .sent)
    static let recievedPlaceholder = MessageItem(text: "Motaa Dudu", type: .text, direction: .received)
    
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
        MessageItem(text: "Hi There", type: .text, direction: .sent),
        MessageItem(text: "Check out this Photo", type: .photo, direction: .received),
        MessageItem(text: "Play out this Video", type: .video, direction: .sent),
        MessageItem(text: "", type: .audio, direction: .received)
    ]
}

extension String {
    static let text = "text"
    static let `type` = "type"
    static let timestamp = "timestamp"
    static let ownerUid = "ownerUid"
}
