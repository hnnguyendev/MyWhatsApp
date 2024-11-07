//
//  UserService.swift
//  MyWhatsApp
//
//  Created by Nguyen Huu Nghia on 3/11/24.
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseDatabaseSwift

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
    
    static func getUsers(with uids: [String], completion: @escaping (UserNode) -> Void) {
        var users: [UserItem] = []
        for uid in uids {
            let query = FirebaseConstants.UsersRef.child(uid)
            /// We're going to observeSingleEvent which is just going to get me the data without any form of Observe
            query.observeSingleEvent(of: .value) { snapshot in
                guard let user = try? snapshot.data(as: UserItem.self) else { return }
                users.append(user)
                if users.count == uids.count {
                    completion(UserNode(users: users))
                }
            } withCancel: { error in
                completion(.emptyNode)
            }
        }
    }
}

struct UserNode {
    var users: [UserItem]
    var currentCursor: String?
    static let emptyNode = UserNode(users: [], currentCursor: nil)
}
