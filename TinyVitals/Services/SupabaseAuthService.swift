//
//  SupabaseAuthService.swift
//  TinyVitals
//
//  Created by user66 on 29/01/26.
//

import Foundation
import Supabase
import UIKit

final class SupabaseAuthService: AuthService {

    static let shared = SupabaseAuthService()
    private init() {}

    let client = SupabaseClient(
        supabaseURL: URL(string: "https://lclsmfmmyybfsdqdnfmk.supabase.co")!,
        supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxjbHNtZm1teXliZnNkcWRuZm1rIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk2MjI4NDgsImV4cCI6MjA4NTE5ODg0OH0.5Wmk7IdBq0Qv0lvpsP7bQqAvKoCldK41Whn8fzXUCPY",
        options: .init(
            auth: .init(
                redirectToURL: URL(string: "tinyvitals://oauth-callback"),
                flowType: .pkce
            )
        )
    )

    // MARK: - Email Login
    func login(
        email: String,
        password: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        Task {
            do {
                let session = try await client.auth.signIn(
                    email: email,
                    password: password
                )
                completion(.success(session.user.id.uuidString))
            } catch {
                completion(.failure(error))
            }
        }
    }

    // MARK: - Signup
    func signup(
        email: String,
        password: String,
        fullName: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        Task {
            do {
                let session = try await client.auth.signUp(
                    email: email,
                    password: password,
                    data: [
                        "full_name": .string(fullName)
                    ]
                )
                completion(.success(session.user.id.uuidString))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func restoreSession() async -> String? {
        do {
            let session = try await client.auth.session
            return session.user.id.uuidString
        } catch {
            // No active session → user not logged in
            return nil
        }
    }



    // MARK: - Reset Password
    
    func resetPassword(
        email: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        Task {
            do {
                try await client.auth.resetPasswordForEmail(email)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    // MARK: - Google Sign In (Handled later)
//    func signInWithGoogle(
//        presentingVC: UIViewController,
//        completion: @escaping (Result<String, Error>) -> Void
//    ) {
//        Task {
//            do {
//                let redirectURL = URL(string: "tinyvitals://auth-callback")!
//
//                try await client.auth.signInWithOAuth(
//                    provider: .google,
//                    redirectTo: redirectURL
//                )
//
//            } catch {
//                completion(.failure(error))
//            }
//        }
//    }
//    func signInWithGoogle(presentingVC: UIViewController) {
//        Task {
//            do {
//                let redirectURL = URL(string: "tinyvitals://auth-callback")!
//
//                try await client.auth.signInWithOAuth(
//                    provider: .google,
//                    redirectTo: redirectURL
//                )
//
//            } catch {
//                print("Google OAuth error:", error)
//            }
//        }
//    }
    func signInWithGoogle(
        presentingVC: UIViewController,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        Task {
            do {
                // Use custom deep link scheme for OAuth callback
                let redirectURL = URL(string: "tinyvitals://oauth-callback")!

                // With PKCE flow, signInWithOAuth handles everything:
                // opens browser → user authenticates → exchanges code → establishes session
                try await client.auth.signInWithOAuth(
                    provider: .google,
                    redirectTo: redirectURL,
                    scopes: "email profile"
                )
                
                // After signInWithOAuth returns, the session is already established
                let session = try await client.auth.session
//                print("✅ Google sign-in successful:", session.user.id)
                
                DispatchQueue.main.async {
                    completion(.success(session.user.id.uuidString))
                }

            } catch {
//                print("❌ Google OAuth error:", error)
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

    func logout() async {
        try? await client.auth.signOut()
    }

}
