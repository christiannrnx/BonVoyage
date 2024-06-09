//
//  AuthenticationManager.swift
//  BonVoyage
//
//  Created by Christian Romero
//

import Foundation

class AuthenticationManager {
    static let shared = AuthenticationManager()
    
    private let userDefaultsKey = "isLoggedIn"
    
    // Check if user is logged in
    func isLoggedIn() -> Bool {
        return UserDefaults.standard.bool(forKey: userDefaultsKey)
    }
    
    // Change login state
    func setLoggedIn(_ loggedIn: Bool) {
        UserDefaults.standard.set(loggedIn, forKey: userDefaultsKey)
        NotificationCenter.default.post(name: Notification.Name("didLogIn"), object: nil)
    }
}
