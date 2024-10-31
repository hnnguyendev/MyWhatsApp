//
//  AuthProvider.swift
//  MyWhatsApp
//
//  Created by Nguyen Huu Nghia on 30/10/24.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseDatabase

enum AuthState {
    case pending, loggedIn, loggedOut
}

protocol AuthProvider {
    /// Make sure we're referring to the same authentication provider - we need to have a single instance of an authentication provider (Singleton)
    static var shared: AuthProvider { get }
    
    var authState: CurrentValueSubject<AuthState, Never> { get } // Always publishes an AuthState or it never returns an error
    
    func login(with email: String, and password: String) async throws
    
    func autoLogin() async
    
    func createAccount(for username: String, with email: String, and password: String) async throws
    
    func logout() async throws
    
}

final class AuthManager: AuthProvider {
    private init() {
        
    }
    
    static let shared: AuthProvider = AuthManager()
    
    var authState = CurrentValueSubject<AuthState, Never>(.pending)
    
    func login(with email: String, and password: String) async throws {
        
    }
    
    func autoLogin() async {
        
    }
    
    func createAccount(for username: String, with email: String, and password: String) async throws {
        /// invoke firebase create account method: store the user in out firebase auth
        
        /// store the new user info in our database
        let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
        let uid = authResult.user.uid
        let newUser = UserItem(uid: uid, username: username, email: email)
        try await saveUserInfoDatabase(user: newUser)
    }
    
    func logout() async throws {
        
    }
    
}

extension AuthManager {
    private func saveUserInfoDatabase(user: UserItem) async throws {
        let userDictionary = ["uid": user.uid, "username": user.username, "email": user.email]
        try await Database.database().reference().child("users").child(user.uid).setValue(userDictionary)
    }
}

struct UserItem: Identifiable, Hashable, Decodable {
    let uid: String
    let username: String
    let email: String
    var bio: String? = nil /// optional
    var profileImageUrl: String? = nil /// optional
    
    var id: String {
        return uid
    }
    
    var bioUnwrapped: String {
        return bio ?? "Hey there! I am using MyWhatsApp."
    }
}
