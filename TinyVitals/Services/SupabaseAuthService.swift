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

    private let client = SupabaseClient(
        supabaseURL: URL(string: "https://lclsmfmmyybfsdqdnfmk.supabase.co")!,
        supabaseKey: "sb_publishable_uXN2LscnBh2qWdF1-GnrKg_0aNtKo8Z"
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
    func signInWithGoogle(
        presentingVC: UIViewController,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        completion(.failure(NSError(
            domain: "Google",
            code: -1,
            userInfo: [NSLocalizedDescriptionKey: "Google OAuth setup pending"]
        )))
    }

    func logout() {
        Task {
            try? await client.auth.signOut()
        }
    }
}
