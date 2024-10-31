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
    static let UserRef = DatabaseRef.child("users")
}
