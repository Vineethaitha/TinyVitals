//
//  AuthService.swift
//  TinyVitals
//
//  Created by user66 on 29/01/26.
//

import UIKit

protocol AuthService {

    func login(
        email: String,
        password: String,
        completion: @escaping (Result<String, Error>) -> Void
    )

    func signup(
        email: String,
        password: String,
        fullName: String,
        completion: @escaping (Result<String, Error>) -> Void
    )

    func resetPassword(
        email: String,
        completion: @escaping (Result<Void, Error>) -> Void
    )

    func signInWithGoogle(
        presentingVC: UIViewController,
        completion: @escaping (Result<String, Error>) -> Void
    )

    func logout() async
}
