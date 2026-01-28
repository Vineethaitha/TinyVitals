//
//  FirebaseAuthService.swift
//  TinyVitals
//
//  Created by user66 on 29/01/26.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import GoogleSignIn

final class FirebaseAuthService: AuthService {

    static let shared = FirebaseAuthService()
    private init() {}

    func login(
        email: String,
        password: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let userId = result?.user.uid else {
                completion(.failure(NSError(domain: "Auth", code: -1)))
                return
            }

            completion(.success(userId))
        }
    }

    func signup(
        email: String,
        password: String,
        fullName: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let user = result?.user else {
                completion(.failure(NSError(domain: "Auth", code: -1)))
                return
            }

            let change = user.createProfileChangeRequest()
            change.displayName = fullName

            change.commitChanges { _ in
                completion(.success(user.uid))
            }
        }
    }

    func resetPassword(
        email: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    func signInWithGoogle(
        presentingVC: UIViewController,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            completion(.failure(NSError(domain: "Google", code: -1)))
            return
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        GIDSignIn.sharedInstance.signIn(withPresenting: presentingVC) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard
                let user = result?.user,
                let idToken = user.idToken?.tokenString
            else {
                completion(.failure(NSError(domain: "Google", code: -1)))
                return
            }

            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: user.accessToken.tokenString
            )

            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                completion(.success(authResult?.user.uid ?? ""))
            }
        }
    }

    func logout() {
        try? Auth.auth().signOut()
    }
}
