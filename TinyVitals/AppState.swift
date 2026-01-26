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

    private(set) var userId: String?

    private(set) var children: [ChildProfile] = []
    private(set) var activeChild: ChildProfile?

    func setUser(id: String) {
        userId = id
    }

    func addChild(_ child: ChildProfile) {
        children.append(child)
        activeChild = child
    }

    func updateChild(_ child: ChildProfile) {
        if let index = children.firstIndex(where: { $0.id == child.id }) {
            children[index] = child
            activeChild = child
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
