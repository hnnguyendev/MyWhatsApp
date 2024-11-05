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

// Flow: login() result is successful -> call fetchCurrentUserInfo() and fetch current user successful -> trigger AuthState -> trigger RootScreen

enum AuthState {
    case pending, loggedIn(UserItem), loggedOut
}

enum AuthError {
    case accountCreationFailed(_ description: String)
    case failedToSaveUserInfo(_ description: String)
    case emailLoginFailed(_ description: String)
}

extension AuthError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .accountCreationFailed(let description):
            return description
        case .failedToSaveUserInfo(let description):
            return description
        case .emailLoginFailed(let description):
            return description
        }
    }
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

// MARK: AuthManager is a Singleton so there's only shared instance there's only one single instance across our entire application
final class AuthManager: AuthProvider {
    private init() {
        Task {
            await autoLogin()
        }
    }
    
    static let shared: AuthProvider = AuthManager()
    
    var authState = CurrentValueSubject<AuthState, Never>(.pending)
    
    func login(with email: String, and password: String) async throws {
        do {
            let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
            fetchCurrentUserInfo()
            print("🔐 Successfully Signed In \(authResult.user.email ?? "")")
        } catch {
            print("❌ Failed to Sign Into the Account with \(email)")
            throw AuthError.emailLoginFailed(error.localizedDescription)
        }
    }
    
    func autoLogin() async {
        if Auth.auth().currentUser == nil {
            authState.send(.loggedOut)
        } else {
            fetchCurrentUserInfo()
        }
    }
    
    func createAccount(for username: String, with email: String, and password: String) async throws {
        /// invoke firebase create account method: store the user in out firebase auth
        /// store the new user info in our database
        ///
        do {
            let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
            let uid = authResult.user.uid
            let newUser = UserItem(uid: uid, username: username, email: email)
            try await saveUserInfoDatabase(user: newUser)
            self.authState.send(.loggedIn(newUser))
        } catch {
            print("❌ Failed to Create an Account: \(error.localizedDescription)")
            throw AuthError.accountCreationFailed(error.localizedDescription)
        }
    }
    
    func logout() async throws {
        do {
            try Auth.auth().signOut()
            authState.send(.loggedOut)
            print("🔐 Successfully logged out!")
        } catch {
            print("❌ Failed to logout current User: \(error.localizedDescription)")
        }
    }
    
}

extension AuthManager {
    private func saveUserInfoDatabase(user: UserItem) async throws {
        do {
            let userDictionary: [String: Any] = [.uid: user.uid, .username: user.username, .email: user.email]
            try await FirebaseConstants.UsersRef.child(user.uid).setValue(userDictionary)
        } catch {
            print("❌ Failed to Save Created user Info to Database: \(error.localizedDescription)")
            throw AuthError.failedToSaveUserInfo(error.localizedDescription)
        }
    }
    
    private func fetchCurrentUserInfo() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        FirebaseConstants.UsersRef.child(currentUid).observe(.value) {[weak self] snapshot in /// Create weak reference???
            
            /// decode user from Firebase
            guard let userDict = snapshot.value as? [String: Any] else { return }
            let loggedInUser = UserItem(dictionary: userDict)
            self?.authState.send(.loggedIn(loggedInUser))
            print("🔐 \(loggedInUser.username) is logged in")
            
        } withCancel: { error in
            print("Failed to get current user info")
        }
    }
}

extension AuthManager {
    static let testAccounts: [String] = [
        "Hnnguyen1@test.com",
        "Hnnguyen2@test.com",
        "Hnnguyen3@test.com",
        "Hnnguyen4@test.com",
        "Hnnguyen5@test.com",
        "Hnnguyen6@test.com",
        "Hnnguyen7@test.com",
        "Hnnguyen8@test.com",
        "Hnnguyen9@test.com",
        "Hnnguyen10@test.com",
        "Hnnguyen11@test.com",
        "Hnnguyen12@test.com",
        "Hnnguyen13@test.com",
        "Hnnguyen14@test.com",
        "Hnnguyen15@test.com",
        "Hnnguyen16@test.com",
        "Hnnguyen17@test.com",
        "Hnnguyen18@test.com",
        "Hnnguyen19@test.com",
        "Hnnguyen20@test.com",
        "Hnnguyen21@test.com",
        "Hnnguyen22@test.com",
        "Hnnguyen23@test.com",
        "Hnnguyen24@test.com",
        "Hnnguyen25@test.com",
        "Hnnguyen26@test.com",
        "Hnnguyen27@test.com",
        "Hnnguyen28@test.com",
        "Hnnguyen29@test.com",
        "Hnnguyen30@test.com",
        "Hnnguyen31@test.com",
        "Hnnguyen32@test.com",
        "Hnnguyen33@test.com",
        "Hnnguyen34@test.com",
        "Hnnguyen35@test.com",
        "Hnnguyen36@test.com",
        "Hnnguyen37@test.com",
        "Hnnguyen38@test.com",
        "Hnnguyen39@test.com",
        "Hnnguyen40@test.com",
        "Hnnguyen41@test.com",
        "Hnnguyen42@test.com",
        "Hnnguyen43@test.com",
        "Hnnguyen44@test.com",
        "Hnnguyen45@test.com",
        "Hnnguyen46@test.com",
        "Hnnguyen47@test.com",
        "Hnnguyen48@test.com",
        "Hnnguyen49@test.com",
        "Hnnguyen50@test.com"
    ]
}
