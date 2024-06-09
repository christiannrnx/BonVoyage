//
//  ViewController.swift
//  BonVoyage
//
//  Created by Christian Romero
//

import Foundation
import AuthenticationServices
import UIKit

class ViewController: UIViewController {
    
    private let signInButton = ASAuthorizationAppleIDButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(signInButton)
        signInButton.addTarget(self, action: #selector(didTapSignIn), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        signInButton.frame = CGRect(x: 0, y: 0, width: 250, height: 50)
        signInButton.center = view.center
    }
    
    @objc func didTapSignIn() {
        // Create provider and make a request
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        // Attributes we want from the user
        request.requestedScopes = [.fullName]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
    
}

extension ViewController: ASAuthorizationControllerDelegate {
    
    // If authorization failed
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
        print("Authentication error: \(error.localizedDescription)")
    }
    
    // If authorization correct
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        // Get user credentials
        case let credentials as ASAuthorizationAppleIDCredential:
            var firstName = credentials.fullName?.givenName
            var lastName = credentials.fullName?.familyName
            
            // Update the login state
            AuthenticationManager.shared.setLoggedIn(true, firstName: firstName, lastName: lastName)
            // Notify login success
            NotificationCenter.default.post(name: Notification.Name("didLogIn"), object: nil)
            // Dismiss the login view
            dismiss(animated: true, completion: nil)
            
            break
        default:
            break
        }
    }
    
}

extension ViewController: ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
    
}
