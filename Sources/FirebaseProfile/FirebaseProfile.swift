import UIKit
import FirebaseCore
import Firewrap
import FirewrapAuth
import SwiftBoost

public enum FirebaseProfile {
    
    public static func configure(with options: FirebaseOptions) {
        Firewrap.configure(with: options)
        FirewrapAuth.configure() {
            debug("FirebaseProfile: Auth state did change to \(FirewrapAuth.isAuthed.description)")
            NotificationCenter.default.post(name: .firebaseProfileDidChangedAuth)
        }
    }
    
    public static func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return FirewrapAuth.application(app, open: url, options: options)
    }
    
    // MARK: - Data
    
    public static var isAuthed: Bool { FirewrapAuth.userID != nil }
    
    public static var profile: FirebaseProfileModel? {
        guard let userID = FirewrapAuth.userID else { return nil }
        guard let userEmail = FirewrapAuth.userEmail else { return nil }
        return FirebaseProfileModel(
            id: userID,
            email: userEmail,
            name: FirewrapAuth.userName,
            providers: FirewrapAuth.providers
        )
    }
    
    // MARK: - Actions
    
    public static func signIn(with way: FirebaseAuthWay, completion: ((FirewrapAuthSignInError?) -> Void)?) {
        switch way {
        case .apple(let controller):
            FirewrapAuth.signInWithApple(on: controller) { data, signInError in
                completion?(signInError)
            }
        case .google(let controller):
            FirewrapAuth.signInWithGoogle(on: controller) { signInError in
                completion?(signInError)
            }
        case .email(let email, let handleURL):
            FirewrapAuth.signInWithEmail(email: email, handleURL: handleURL) { signInError in
                completion?(signInError)
            }
        }
    }
    
    public static func signOut(completion: @escaping (Error?)->Void) {
        FirewrapAuth.signOut(completion: completion)
    }
    
    public static func deleteProfile(with way: FirebaseAuthWay, completion: @escaping (FirewrapDeleteProfileError?)->Void) {
        switch way {
        case .apple(let controller):
            FirewrapAuth.signInWithApple(on: controller) { data, signInError in
                if signInError != nil {
                    completion(.failed)
                    return
                }
                guard let data else {
                    completion(.failed)
                    return
                }
                FirewrapAuth.revokeSignInWithApple(authorizationCode: data.authorizationCode)
                FirewrapAuth.delete { deleteError in
                    completion(deleteError)
                }
            }
        case .google(let controller):
            FirewrapAuth.signInWithGoogle(on: controller) { signInError in
                FirewrapAuth.delete { deleteError in
                    completion(deleteError)
                }
            }
        case .email(let email, let handleURL):
            FirewrapAuth.signInWithEmail(email: email, handleURL: handleURL) { signInError in
                // Event `.mustConfirmViaEmail` not bug
                // Its waiting to handle when user confirm sign in
                if signInError != nil && signInError != .mustConfirmViaEmail {
                    completion(.failed)
                    return
                }
                completion(nil)
            }
        }
    }
}

public enum FirebaseAuthWay {
    
    case apple(_ controller: UIViewController)
    case google(_ controller: UIViewController)
    case email(_ email: String, handleURL: URL)
}

extension Notification.Name {
    
    public static var firebaseProfileDidChangedAuth = Notification.Name("firebaseProfileDidChangedAuth")
}
