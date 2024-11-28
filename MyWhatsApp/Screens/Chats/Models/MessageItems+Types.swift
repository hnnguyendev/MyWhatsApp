//
//  MessageItems+Types.swift
//  MyWhatsApp
//
//  Created by Nguyen Huu Nghia on 6/11/24.
//

import Foundation

enum AdminMessageType: String {
    case channelCreation
    case memberAdded
    case memberLeft
    case channelNameChanged
}

/// Reason we're not making MessageType of type String becase this MessageType is going to also have admin messages and thoose are not actually string
enum MessageType: Hashable {
    case admin(_ type: AdminMessageType), text, photo, video, audio
    
    var title: String {
        switch self {
        case .admin:
            return "admin"
        case .text:
            return "text"
        case .photo:
            return "photo"
        case .video:
            return "video"
        case .audio:
            return "audio"
        }
    }
    
    var iconName: String {
        switch self {
        case .admin:
            return "megaphone.fill"
        case .text:
            return ""
        case .photo:
            return "photo.fill"
        case .video:
            return "video.fill"
        case .audio:
            return "mic.fill"
        }
    }
    
    init?(_ stringValue: String) {
        switch stringValue {
        case .text:
            self = .text
        case "photo":
            self = .photo
        case "video":
            self = .video
        case "audio":
            self = .audio
        default:
            if let adminMessageType = AdminMessageType(rawValue: stringValue) {
                self = .admin(adminMessageType)
            } else {
                return nil
            }
        }
    }
}

/// Fix error in BubbleImageView: Referencing operator function '==' on 'Equatable' requires that 'MessageType' conform to 'Equatable'
extension MessageType: Equatable {
    static func == (leftHandSide: MessageType, rightHandSide: MessageType) -> Bool {
        switch(leftHandSide, rightHandSide) {
        case (.admin(let leftAdmin), .admin(let rightAdmin)):
            return leftAdmin == rightAdmin
            
        case (.text, .text),
            (.photo, .photo),
            (.video, .video),
            (.audio, .audio):
            return true
            
        default:
            return false
        }
    }
}

enum MessageDirection {
    case sent, received
    
    static var random: MessageDirection {
        return [MessageDirection.sent, .received].randomElement() ?? .sent
    }
}

enum Reaction: Int {
    case like
    case heart
    case laugh
    case happy
    case shocked
    case sad
    case more
    
    var emoji: String {
        switch self {
        case .like:
            return "🫰"
        case .heart:
            return "❤️"
        case .laugh:
            return "🤣"
        case .happy:
            return "🥰"
        case .shocked:
            return "😮"
        case .sad:
            return "😥"
        case .more:
            return "+"
        }
    }
}

enum MessageMenuAction: String, CaseIterable, Identifiable {
    case reply, forward, copy, delete
    
    var id: String {
        return rawValue
    }
    
    var systemImage: String {
        switch self {
        case .reply:
            return "arrowshape.turn.up.left"
        case .forward:
            return "paperplane"
        case .copy:
            return "doc.on.doc"
        case .delete:
            return "trash"
        }
    }
}
