//
//  SceneDelegate.swift
//  TinyVitals
//
//  Created by admin0 on 12/18/25.
//

import UIKit
import Supabase

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: windowScene)
        window?.overrideUserInterfaceStyle = .light

        let splashVC = splashScreenViewController(
            nibName: "splashScreenViewController",
            bundle: Bundle.main
        )

        window?.rootViewController = splashVC
        window?.makeKeyAndVisible()

        // Handle OAuth redirect if app was launched from URL
        if let urlContext = connectionOptions.urlContexts.first {
//            print("🔥 App opened via URL:", urlContext.url)
            handleOAuthCallback(urlContext.url)
        }
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        
//        print("🔥 URL CALLBACK RECEIVED:", url)
        
        // Handle the OAuth callback
        handleOAuthCallback(url)
    }
    
    func handleOAuthCallback(_ url: URL) {
//        print("🔥 CALLBACK URL:", url)
//        print("🔥 URL scheme:", url.scheme ?? "nil")
//        print("🔥 URL host:", url.host ?? "nil")
//        print("🔥 URL path:", url.path)
//        print("🔥 URL query:", url.query ?? "nil")
//        print("🔥 URL fragment:", url.fragment ?? "nil")
        
        // Log all query parameters
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let queryItems = components.queryItems {
            for _ in queryItems {
//                print("🔥 Query param: \(item.name) = \(item.value ?? "nil")")
            }
        }

        Task {
            do {
//                print("🔄 Exchanging OAuth callback for session via session(from:)")

                // Use the SDK's session(from:) which handles PKCE code verifier automatically
                let session = try await SupabaseAuthService.shared.client.auth.session(from: url)

//                print("✅ LOGIN SUCCESS:", session.user.id)

                DispatchQueue.main.async {
                    AppState.shared.userId = session.user.id.uuidString
                    
                    // Post notification to inform LoginViewController of successful authentication
                    NotificationCenter.default.post(name: NSNotification.Name("GoogleAuthSuccessful"), object: nil)
                }
                
                let userUUID = session.user.id
                do {
                    let dtos = try await ChildService.shared.fetchChildren(userId: userUUID)
                    let profiles = dtos.map { ChildProfile(dto: $0) }
                    
                    await MainActor.run {
                        AppState.shared.setChildren(profiles)
                        if let first = profiles.first {
                            AppState.shared.setActiveChild(first)
                        }
                        
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let window = windowScene.windows.first {
                            window.rootViewController = MainTabBarController()
                            window.makeKeyAndVisible()
                        }
                    }
                } catch {
//                    print("❌ Failed to fetch children during OAuth callback:", error)
                    await MainActor.run {
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let window = windowScene.windows.first {
                            window.rootViewController = MainTabBarController()
                            window.makeKeyAndVisible()
                        }
                    }
                }

            } catch {
//                print("❌ OAuth exchange failed:")
//                print("❌ Error type:", type(of: error))
//                print("❌ Error description:", error.localizedDescription)
//                print("❌ Full error:", String(describing: error))
                
                await MainActor.run {
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let rootVC = windowScene.windows.first?.rootViewController {
                        let alert = UIAlertController(
                            title: "Google Sign-In Failed",
                            message: error.localizedDescription,
                            preferredStyle: .alert
                        )
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        rootVC.present(alert, animated: true)
                    }
                }
            }
        }
    }

    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

