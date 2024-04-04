import UIKit
import FirebaseCore
import FirebaseWrapper
import FirebaseWrapperAuth
import SwiftBoost

public enum FirebaseProfile {
    
    public static func configure(with options: FirebaseOptions) {
        FirebaseWrapper.configure(with: options)
        FirebaseWrapperAuth.configure() {
            debug("In App: FirebaseWrapperAuth did change \(FirebaseWrapperAuth.isAuthed.description)")
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
        return FirebaseProfileModel(id: userID, email: userEmail, name: FirebaseWrapperAuth.userName)
    }
    
    // MARK: - Actions
    
    public static func signIn(with way: FirebaseAuthWay, on controller: UIViewController, completion: ((Error?) -> Void)?) {
        switch way {
        case .apple:
            FirebaseWrapperAuth.signInWithApple(on: controller) { data, error in
                completion?(error)
            }
        case .google:
            FirebaseWrapperAuth.signInWithGoogle(on: controller) { data, error in
                completion?(error)
            }
        case .email:
            #warning("todo")
            break
        }
    }
    
    public static func signOut(completion: @escaping (Error?)->Void) {
        FirebaseWrapperAuth.signOut(completion: completion)
    }
    
    public static func deleteProfile(on controller: UIViewController, completion: @escaping (Error?)->Void) {
        FirebaseWrapperAuth.delete(on: controller, completion: completion)
    }
    
    // MARK: - Private
}

public enum FirebaseAuthWay: String {
    
    case apple
    case google
    case email
    
    var id: String { rawValue }
}

extension Notification.Name {
    
    public static var firebaseProfileDidChangedAuth = Notification.Name("firebaseProfileDidChangedAuth")
}
