//
//  final_app_467_316App.swift
//  final app 467 316
//
//  Created by Varagorn Lapachai on 17/11/2568 BE.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth
@main
struct final_app_467_316App: App {
    
    @StateObject private var auth = AuthViewModel()
    
    init() {
            FirebaseApp.configure()
        }
    
    var body: some Scene {
        WindowGroup {
            ThemeColor{
                ContentView()
                    .environmentObject(auth)
            }
        }
    }
}
struct FirebaseLoginApp{
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate: AppDelegate
    var body:some Scene{
        WindowGroup{
            ContentView()
        }
    }
}
class AppDelegate: NSObject,UIApplicationDelegate{
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey :Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}
