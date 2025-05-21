//
//  UserItem.swift
//  MyWhatsApp
//
//  Created by Nguyen Huu Nghia on 31/10/24.
//

import Foundation

struct UserItem: Identifiable, Hashable, Decodable {
    let uid: String
    var username: String
    let email: String
    var bio: String? = nil /// optional
    var profileImageUrl: String? = nil /// optional
    
    var id: String {
        return uid
    }
    
    var bioUnwrapped: String {
        return bio ?? "Hey there! I am using MyWhatsApp."
    }
    
    static let placeholder = UserItem(uid: "1", username: "Motki Bubu", email: "motki.bubu@gmail.com") /// Fix MainTabView preview

    static let placeholders: [UserItem] = [
        UserItem(uid: "1", username: "Motki Bubu", email: "motki.bubu@gmail.com"),
        UserItem(uid: "2", username: "Lara Sky", email: "lara.sky@gmail.com", bio: "Explorer at heart"),
        UserItem(uid: "3", username: "Zack Bolt", email: "zack.bolt@gmail.com", bio: "Coder and Gamer"),
        UserItem(uid: "4", username: "Nina Flash", email: "nina.flash@gmail.com", bio: "Photographer & Traveler"),
        UserItem(uid: "5", username: "Sam Drift", email: "sam.drift@gmail.com", bio: "Digital Nomad"),
        UserItem(uid: "6", username: "Eva Bliss", email: "eva.bliss@gmail.com", bio: "Food lover and Chef"),
        UserItem(uid: "7", username: "Kai Storm", email: "kai.storm@gmail.com", bio: "Lover of the ocean"),
        UserItem(uid: "8", username: "Toby Quill", email: "toby.quill@gmail.com", bio: "Writer and Thinker"),
        UserItem(uid: "9", username: "Rita Glow", email: "rita.glow@gmail.com", bio: "Artist and Dreamer"),
        UserItem(uid: "10", username: "Dan Ray", email: "dan.ray@gmail.com", bio: "Tech enthusiast"),
        UserItem(uid: "11", username: "Lucy Moon", email: "lucy.moon@gmail.com", bio: "Astronomy buff"),
        UserItem(uid: "12", username: "Omar Vibe", email: "omar.vibe@gmail.com", bio: "Musician & Producer")
    ]
}

extension UserItem {
    init(dictionary: [String: Any]) {
        self.uid = dictionary[.uid] as? String ?? ""
        self.username = dictionary[.username] as? String ?? ""
        self.email = dictionary[.email] as? String ?? ""
        self.bio = dictionary[.bio] as? String? ?? nil
        self.profileImageUrl = dictionary[.profileImageUrl] as? String? ?? nil
    }
}

extension String {
    static let uid = "uid"
    static let username = "username"
    static let email = "email"
    static let bio = "bio"
    static let profileImageUrl = "profileImageUrl"
}
