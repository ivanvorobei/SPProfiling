import UIKit
import FirebaseCore
import FirebaseWrapper
import FirebaseWrapperAuth
import SwiftBoost

public enum FirebaseProfile {
    
    public static func configure(with options: FirebaseOptions) {
        FirebaseWrapper.configure(with: options)
        FirebaseWrapperAuth.configure() {
            debug("FirebaseProfile: Auth state did change to \(FirebaseWrapperAuth.isAuthed.description)")
            NotificationCenter.default.post(name: .firebaseProfileDidChangedAuth)
        }
    }
    
    public static func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return FirebaseWrapperAuth.application(app, open: url, options: options)
    }
    
    // MARK: - Data
    
    public static var isAuthed: Bool { FirebaseWrapperAuth.userID != nil }
    
    public static var profile: FirebaseProfileModel? {
        guard let userID = FirebaseWrapperAuth.userID else { return nil }
        guard let userEmail = FirebaseWrapperAuth.userEmail else { return nil }
        return FirebaseProfileModel(
            id: userID,
            email: userEmail,
            name: FirebaseWrapperAuth.userName,
            providers: FirebaseWrapperAuth.providers
        )
    }
    
    // MARK: - Actions
    
    public static func signIn(with way: FirebaseAuthWay, completion: ((Error?) -> Void)?) {
        switch way {
        case .apple(let controller):
            FirebaseWrapperAuth.signInWithApple(on: controller) { data, signInError in
                completion?(signInError)
            }
        case .google(let controller):
            FirebaseWrapperAuth.signInWithGoogle(on: controller) { signInError in
                completion?(signInError)
            }
        case .email(let email, let handleURL):
            FirebaseWrapperAuth.signInWithEmail(email: email, handleURL: handleURL) { signInError in
                completion?(signInError)
            }
        }
    }
    
    public static func signOut(completion: @escaping (Error?)->Void) {
        FirebaseWrapperAuth.signOut(completion: completion)
    }
    
    public static func deleteProfile(with way: FirebaseAuthWay, completion: @escaping (FWADeleteProfileError?)->Void) {
        switch way {
        case .apple(let controller):
            FirebaseWrapperAuth.signInWithApple(on: controller) { data, signInError in
                if signInError != nil {
                    completion(.failed)
                    return
                }
                guard let data else {
                    completion(.failed)
                    return
                }
                FirebaseWrapperAuth.revokeSignInWithApple(authorizationCode: data.authorizationCode)
                FirebaseWrapperAuth.delete { deleteError in
                    completion(deleteError)
                }
            }
        case .google(let controller):
            FirebaseWrapperAuth.signInWithGoogle(on: controller) { signInError in
                FirebaseWrapperAuth.delete { deleteError in
                    completion(deleteError)
                }
            }
        case .email(let email, let handleURL):
            FirebaseWrapperAuth.signInWithEmail(email: email, handleURL: handleURL) { signInError in
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
