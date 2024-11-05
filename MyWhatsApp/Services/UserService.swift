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
    // MARK: Firebase
    /// .queryLimited(toLast: pageSize) => from BOTTOM to TOP in Database
    /// .queryEnding(atValue: lastCursor) => "less than or equal to" lastCursor => from BOTTOM to TOP in Database
    /// .queryLimited(toLast: pageSize + 1) => include lastCursor + pageSize users => from BOTTOM to TOP in Database
    /// first => get first user => from TOP to BOTTOM in Database
    /// filteredUsers => remove duplicate lastCursor user
    static func paginateUsers(lastCursor: String?, pageSize: UInt) async throws -> UserNode {
        let mainSnapshot: DataSnapshot
        if lastCursor == nil {
            /// Initial data fetch
            mainSnapshot = try await FirebaseConstants.UsersRef
                .queryLimited(toLast: pageSize).getData()
        } else {
            /// Paginate for more data
            mainSnapshot = try await FirebaseConstants.UsersRef
                .queryOrderedByKey()
                .queryEnding(atValue: lastCursor)
                .queryLimited(toLast: pageSize + 1)
                .getData()
        }
        
        guard let first = mainSnapshot.children.allObjects.first as? DataSnapshot,
              let allObjects = mainSnapshot.children.allObjects as? [DataSnapshot] else { return .emptyNode }
        
        let users: [UserItem] = allObjects.compactMap { userSnapshot in
            let userDict = userSnapshot.value as? [String: Any] ?? [:]
            return UserItem(dictionary: userDict)
        }
        
        if users.count == mainSnapshot.childrenCount {
            let filteredUsers = lastCursor == nil ? users : users.filter { $0.uid != lastCursor }
            let userNode = UserNode(users: filteredUsers, currentCursor: first.key)
            return userNode
        }
        
        return .emptyNode
    }
}

struct UserNode {
    var users: [UserItem]
    var currentCursor: String?
    static let emptyNode = UserNode(users: [], currentCursor: nil)
}
