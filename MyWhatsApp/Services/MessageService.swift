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
        let timestamp = Date().timeIntervalSince1970
        guard let messageId = FirebaseConstants.ChannelMessagesRef.childByAutoId().key else { return }
        
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
    
    static func getMessages(for channel: ChannelItem, completion: @escaping([MessageItem]) -> Void) {
        FirebaseConstants.ChannelMessagesRef.child(channel.id).observe(.value) { snapshot in
            guard let channelMessageDict = snapshot.value as? [String: Any] else { return }
            var messages: [MessageItem] = []
            /// In Firebase Database key is channel.id, value are messageId key pairs of the messages
            channelMessageDict.forEach { key, value in
                let messageDict = value as? [String: Any] ?? [:]
                let message = MessageItem(id: key, dict: messageDict)
                messages.append(message)
                completion(messages)
            }
        } withCancel: { error in
            print("Failed to get messages for \(channel.title)")
        }
    }
    
}
