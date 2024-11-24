//
//  MessageService.swift
//  MyWhatsApp
//
//  Created by Nguyen Huu Nghia on 8/11/24.
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseDatabaseSwift

// MARK: Handles sending and fetching messages and setting reactions
struct MessageService {
    static func sendTextMessage(to channel: ChannelItem, from currentUser: UserItem, _ textMessage: String, onComplete: () -> Void) {
        guard let messageId = FirebaseConstants.ChannelMessagesRef.childByAutoId().key else { return }
        let timestamp = Date().timeIntervalSince1970
        
        let channelDict: [String: Any] = [
            .lastMessage: textMessage,
            .lastMessageTimestamp: timestamp,
            .lastMessageType: MessageType.text.title
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
        
        /// Photo Messages & Video Messages
        messageDict[.thumbnailUrl] = params.thumbnailUrl ?? nil
        messageDict[.thumbnailWidth] = params.thumbnailWidth ?? nil
        messageDict[.thumbnailHeight] = params.thumbnailHeight ?? nil
        messageDict[.videoUrl] = params.videoUrl ?? nil
        
        /// Voice Messages
        messageDict[.audioUrl] = params.audioUrl ?? nil
        messageDict[.audioDuration] = params.audioDuration ?? nil
        
        FirebaseConstants.ChannelsRef.child(channel.id).updateChildValues(channelDict)
        FirebaseConstants.ChannelMessagesRef.child(channel.id).child(messageId).setValue(messageDict)
        completion()
    }
    
    // MARK: /* Deprecated */
    /// This method is very inefficient right now because we're just fetching all the messages on the backend
    /// Need paginate the messages
    static func getMessages(for channel: ChannelItem, completion: @escaping([MessageItem]) -> Void) {
        FirebaseConstants.ChannelMessagesRef.child(channel.id).observe(.value) { snapshot in
            guard let channelMessageDict = snapshot.value as? [String: Any] else { return }
            var messages: [MessageItem] = []
            /// In Firebase Database key is channel.id, value are messageId key pairs of the messages
            channelMessageDict.forEach { key, value in
                let messageDict = value as? [String: Any] ?? [:]
                var message = MessageItem(id: key, isGroupChat: channel.isGroupChat, dict: messageDict)
                let messageSender = channel.members.first(where: { $0.uid == message.ownerUid })
                message.sender = messageSender
                
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
    
    static func getHistoricalMessages(for channel: ChannelItem, lastCursor: String?, pageSize: UInt, completion: @escaping (MessageNode) -> Void) {
        let query: DatabaseQuery
        
        if lastCursor == nil {
            query = FirebaseConstants.ChannelMessagesRef.child(channel.id).queryLimited(toLast: pageSize)
        } else {
            query = FirebaseConstants.ChannelMessagesRef.child(channel.id)
                .queryOrderedByKey()
                .queryEnding(atValue: lastCursor)
                .queryLimited(toLast: pageSize)
        }
        
        query.observeSingleEvent(of: .value) { mainSnapshot in
            guard let first = mainSnapshot.children.allObjects.first as? DataSnapshot,
                  let allObjects = mainSnapshot.children.allObjects as? [DataSnapshot]
            else { return }
            
            var messages: [MessageItem] = allObjects.compactMap { messageSnapshot in
                let messageDict = messageSnapshot.value as? [String: Any] ?? [:]
                var message = MessageItem(id: messageSnapshot.key, isGroupChat: channel.isGroupChat, dict: messageDict)
                let messageSender = channel.members.first(where: { $0.uid == message.ownerUid })
                message.sender = messageSender
                return message
            }
            messages.sort { $0.timestamp < $1.timestamp }
            
            if messages.count == mainSnapshot.childrenCount {
                let filterMessages = lastCursor == nil ? messages : messages.filter { $0.id != lastCursor }
                let messageNode = MessageNode(messages: filterMessages, currentCursor: first.key)
                completion(messageNode)
            }
        } withCancel: { error in
            print("Failed to get messages for channel: \(channel.name ?? "")")
            completion(.emptyNode)
        }
    }
    
    static func getFirstMessage(in channel: ChannelItem, completion: @escaping(MessageItem) -> Void) {
        FirebaseConstants.ChannelMessagesRef.child(channel.id)
            .queryLimited(toFirst: 1)
            .observeSingleEvent(of: .value) { snapshot in
                guard let dictionary = snapshot.value as? [String: Any] else { return }
                dictionary.forEach { key, value in
                    guard let messageDict = snapshot.value as? [String: Any] else { return }
                    var firstMessage = MessageItem(id: key, isGroupChat: channel.isGroupChat, dict: messageDict)
                    let messageSender = channel.members.first(where: { $0.uid == firstMessage.ownerUid })
                    firstMessage.sender = messageSender
                    completion(firstMessage)
                }
            } withCancel: { error in
                print("Failed to get first message for channel: \(channel.name ?? "")")
            }

    }
    
    static func listenForNewMessages(in channel: ChannelItem, completion: @escaping(MessageItem) -> Void) {
        FirebaseConstants.ChannelMessagesRef.child(channel.id)
            .observe(.childAdded) { snapshot in
                guard let messageDict = snapshot.value as? [String: Any] else { return }
                var newMessage = MessageItem(id: snapshot.key, isGroupChat: channel.isGroupChat, dict: messageDict)
                let messageSender = channel.members.first(where: { $0.uid == newMessage.ownerUid })
                newMessage.sender = messageSender
                completion(newMessage)
            }
    }
}

struct MessageUploadParams {
    let channel: ChannelItem
    let text: String
    let type: MessageType
    let attachment: MediaAttachment
    var thumbnailUrl: String?
    var videoUrl: String?
    var audioUrl: String?
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

struct MessageNode {
    var messages: [MessageItem]
    var currentCursor: String?
    static let emptyNode = MessageNode(messages: [], currentCursor: nil)
}
