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
/// Create Firebase database: Build -> Realtime Database -> set rules, Build -> Storage -> set rules

/// Install the Kingfisher Dependencies: https://github.com/onevcat/Kingfisher (8.1.0)/(7.11.0)
/// Kingfisher is going to be responsible for handling image caching for us it's very reliable

/// Install the AlertKit Dependencies: https://github.com/sparrowcode/AlertKit (5.1.9)

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
