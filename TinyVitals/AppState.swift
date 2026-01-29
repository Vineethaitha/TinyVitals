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

    var userId: String?
    private(set) var children: [ChildProfile] = []
    var activeChild: ChildProfile?

    // 🔥 SET FROM SUPABASE
    func setChildren(_ children: [ChildProfile]) {
        self.children = children
        self.activeChild = children.first
    }

    // 🔥 UPDATE CHILD
    func updateChild(_ child: ChildProfile) {
        if let index = children.firstIndex(where: { $0.id == child.id }) {
            children[index] = child
            activeChild = child
        }
    }

    // 🔥 ADD CHILD
    func addChild(_ child: ChildProfile) {
        children.append(child)
        activeChild = child
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

