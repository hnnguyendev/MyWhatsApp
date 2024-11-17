//
//  MessageService.swift
//  MyWhatsApp
//
//  Created by Nguyen Huu Nghia on 8/11/24.
//

import Foundation
import Firebase

// MARK: Handles sending and fetching messages and setting reactions
struct MessageService {
    static func sendTextMessage(to channel: ChannelItem, from currentUser: UserItem, _ textMessage: String, onComplete: () -> Void) {
        guard let messageId = FirebaseConstants.ChannelMessagesRef.childByAutoId().key else { return }
        let timestamp = Date().timeIntervalSince1970
        
        let channelDict: [String: Any] = [
            .lastMessage: textMessage,
            .lastMessageTimestamp: timestamp
        ]
        
        let messageDict: [String: Any] = [
            .text: textMessage,
            .type: MessageType.text.title,
            .timestamp: timestamp,
            .ownerUid: currentUser.uid
        ]
        
        FirebaseConstants.ChannelsRef.child(channel.id).updateChildValues(channelDict)
        FirebaseConstants.ChannelMessagesRef.child(channel.id).child(messageId).setValue(messageDict)
        
        onComplete()
    }
    
    static func sendMediaMessage(to channel: ChannelItem, params: MessageUploadParams, completion: @escaping () -> Void) {
        guard let messageId = FirebaseConstants.ChannelMessagesRef.childByAutoId().key else { return }
        let timestamp = Date().timeIntervalSince1970
        
        let channelDict: [String: Any] = [
            .lastMessage: params.text,
            .lastMessageTimestamp: timestamp,
            .lastMessageType: params.type.title
        ]

        var messageDict: [String: Any] = [
            .text: params.text,
            .type: params.type.title,
            .timestamp: timestamp,
            .ownerUid: params.ownerUid
        ]
        
        /// Photo Messages
        messageDict[.thumbnailUrl] = params.thumbnailUrl ?? nil
        messageDict[.thumbnailWidth] = params.thumbnailWidth ?? nil
        messageDict[.thumbnailHeight] = params.thumbnailHeight ?? nil
        
        FirebaseConstants.ChannelsRef.child(channel.id).updateChildValues(channelDict)
        FirebaseConstants.ChannelMessagesRef.child(channel.id).child(messageId).setValue(messageDict)
        completion()
    }
    
    /// This method is very inefficient right now because we're just fetching all the messages on the backend
    /// Need paginate the messages
    static func getMessages(for channel: ChannelItem, completion: @escaping([MessageItem]) -> Void) {
        FirebaseConstants.ChannelMessagesRef.child(channel.id).observe(.value) { snapshot in
            guard let channelMessageDict = snapshot.value as? [String: Any] else { return }
            var messages: [MessageItem] = []
            /// In Firebase Database key is channel.id, value are messageId key pairs of the messages
            channelMessageDict.forEach { key, value in
                let messageDict = value as? [String: Any] ?? [:]
                let message = MessageItem(id: key, isGroupChat: channel.isGroupChat, dict: messageDict)
                messages.append(message)
                if messages.count == snapshot.childrenCount {
                    messages.sort { $0.timestamp < $1.timestamp }
                    completion(messages)
                }
            }
        } withCancel: { error in
            print("Failed to get messages for \(channel.title)")
        }
    }
    
}

struct MessageUploadParams {
    let channel: ChannelItem
    let text: String
    let type: MessageType
    let attachment: MediaAttachment
    var thumbnailUrl: String?
    var videoURL: String?
    var audioURL: String?
    var audioDuration: TimeInterval?
    var sender: UserItem
    
    var ownerUid: String {
        return sender.uid
    }
    
    var thumbnailWidth: CGFloat? {
        guard type == .photo || type == .video else { return nil }
        return attachment.thumbnail.size.width
    }
    
    var thumbnailHeight: CGFloat? {
        guard type == .photo || type == .video else { return nil }
        return attachment.thumbnail.size.height
    }

}
