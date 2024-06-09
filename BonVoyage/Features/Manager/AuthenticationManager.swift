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
    private let firstNameKey = "firstName"
    private let lastNameKey = "lastName"
    
    // Check if user is logged in
    func isLoggedIn() -> Bool {
        return UserDefaults.standard.bool(forKey: userDefaultsKey)
    }
    
    // Change login state
    func setLoggedIn(_ loggedIn: Bool, firstName: String?, lastName: String?) {
        UserDefaults.standard.set(loggedIn, forKey: userDefaultsKey)
        if let firstName = firstName {
            UserDefaults.standard.set(firstName, forKey: firstNameKey)
        }
        if let lastName = lastName {
            UserDefaults.standard.set(lastName, forKey: lastNameKey)
        }
        NotificationCenter.default.post(name: Notification.Name("didLogIn"), object: nil)
    }
    
    func getFirstName() -> String? {
        return UserDefaults.standard.string(forKey: firstNameKey)
    }
    
    func getLastName() -> String? {
        return UserDefaults.standard.string(forKey: lastNameKey)
    }
}
