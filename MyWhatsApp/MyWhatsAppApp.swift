//
//  MyWhatsAppApp.swift
//  MyWhatsApp
//
//  Created by Nguyen Huu Nghia on 23/10/24.
//

import SwiftUI
import Firebase

/// Install the Firebase Dependencies: File -> Add Package Dependencies -> https://github.com/firebase/firebase-ios-sdk (10.22.1)
/// FirebaseAuth
/// FirebaseDatabase
/// FirebaseDatabaseSwift
/// FirebaseMessaging
/// FirebaseStorage

/// Config Firebase console
/// Config in project here
/// Config Firebase Authentication
/// Create Firebase database: Build -> Realtime Database -> set rules

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        return true
    }
}

@main
struct MyWhatsAppApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            RootScreen()
        }
    }
}
