//
//  FirebaseConstants.swift
//  MyWhatsApp
//
//  Created by Nguyen Huu Nghia on 31/10/24.
//

import Foundation
import Firebase
import FirebaseStorage

enum FirebaseConstants {
    private static let DatabaseRef = Database.database().reference()
    static let UsersRef = DatabaseRef.child("users")
    static let ChannelsRef = DatabaseRef.child("channels")
    static let ChannelMessagesRef = DatabaseRef.child("channel-messages")
    static let UserChannelsRef = DatabaseRef.child("user-channels")
    static let UserDirectChannelsRef = DatabaseRef.child("user-direct-channels")
}
