//
//  AppState.swift
//  TinyVitals
//
//  Created by admin0 on 1/25/26.
//

import Foundation

final class AppState {

    static let shared = AppState()
    private init() {}

    // MARK: - Auth
    private(set) var userId: String?

    // MARK: - Children
    private(set) var children: [ChildProfile] = []
    private(set) var activeChild: ChildProfile?

    // MARK: - Mutations
    func setUser(id: String) {
        userId = id
    }

    func setChildren(_ children: [ChildProfile]) {
        self.children = children

        if activeChild == nil {
            activeChild = children.first
        }
    }

    func setActiveChild(_ child: ChildProfile) {
        activeChild = child
    }

    func clear() {
        userId = nil
        children = []
        activeChild = nil
    }
}

