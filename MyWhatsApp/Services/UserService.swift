//
//  UserService.swift
//  MyWhatsApp
//
//  Created by Nguyen Huu Nghia on 3/11/24.
//

import Foundation
import Firebase
import FirebaseDatabase

struct UserService {
    static func paginateUsers(lastCusor: String?, pageSize: UInt) async throws -> UserNode {
        if lastCusor == nil {
            /// Initial data fetch
            let mainSnapshot = try await FirebaseConstants.UserRef.queryLimited(toLast: pageSize).getData()
            guard let first = mainSnapshot.children.allObjects.first as? DataSnapshot,
                  let allObjects = mainSnapshot.children.allObjects as? [DataSnapshot] else { return .emptyNode }
            
            let users: [UserItem] = allObjects.compactMap { userSnapshot in
                let userDict = userSnapshot.value as? [String: Any] ?? [:]
                return UserItem(dictionary: userDict)
            }
            
            if users.count == mainSnapshot.childrenCount {
                let userNode = UserNode(users: users, currentCursor: first.key)
                return userNode
            }
            
            return .emptyNode
        } else {
            /// Paginate for more data
            let mainSnapshot = try await FirebaseConstants.UserRef
                .queryOrderedByKey()
                .queryEnding(atValue: lastCusor)
                .queryLimited(toLast: pageSize + 1)
                .getData()
            
            guard let first = mainSnapshot.children.allObjects.first as? DataSnapshot,
                  let allObjects = mainSnapshot.children.allObjects as? [DataSnapshot] else { return .emptyNode }
            
            let users: [UserItem] = allObjects.compactMap { userSnapshot in
                let userDict = userSnapshot.value as? [String: Any] ?? [:]
                return UserItem(dictionary: userDict)
            }
            
            if users.count == mainSnapshot.childrenCount {
                let filteredUsers = users.filter { $0.uid != lastCusor }
                let userNode = UserNode(users: filteredUsers, currentCursor: first.key)
                return userNode
            }
            
            return .emptyNode
        }
    }
}

struct UserNode {
    var users: [UserItem]
    var currentCursor: String?
    static let emptyNode = UserNode(users: [], currentCursor: nil)
}
