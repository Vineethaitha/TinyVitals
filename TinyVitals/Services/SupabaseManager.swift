//
//  SupabaseManager.swift
//  TinyVitals
//
//  Created by user66 on 29/01/26.
//

//lclsmfmmyybfsdqdnfmk

import Supabase
import Foundation

final class SupabaseManager {

    static let shared = SupabaseManager()
    let client: SupabaseClient

    private init() {
        client = SupabaseClient(
            supabaseURL: URL(string: "https://lclsmfmmyybfsdqdnfmk.supabase.co")!,
            supabaseKey: "sb_publishable_uXN2LscnBh2qWdF1-GnrKg_0aNtKo8Z"
        )
    }
}
