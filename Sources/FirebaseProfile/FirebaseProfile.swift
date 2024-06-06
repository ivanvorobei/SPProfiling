import UIKit
import FirebaseCore
import Firewrap
import FirewrapAuth
import FirewrapDatabase
import SwiftBoost

public enum FirebaseProfile {
    
    public static func configure(with options: FirebaseOptions) {
        Firewrap.configure(with: options)
        FirewrapAuth.configure(authDidChangedWork: {
            debug("FirebaseProfile: Auth state did change to \(FirewrapAuth.isAuthed.description)")
            
            if isAuthed {
                runObservers()
            } else {
                stopObservers()
            }
            
            NotificationCenter.default.post(name: .firebaseProfileDidChangedAuth)
        })
        
        if isAuthed {
            runObservers()
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
            name: FirewrapAuth.userName
        )
    }
    
    public static var authProviders: [FirewrapAuthProvider] {
        FirewrapAuth.providers
    }
    
    // MARK: - Actions
    
    #warning("replace error")
    public static func signIn(with way: FirebaseAuthWay, completion: ((FirewrapAuthSignInError?) -> Void)?) {
        
        // Вход -> Загружаем профиль (если нет, сохраняем текущий) -> загружаем список устройств (если нет, сохраняем текущее) -> выставляем обсерверы -> завершаем авторизацию
        
        // Call after success auth
        let process = {
            validateProfile { profileValidated in
                if profileValidated {
                    validateDevice { deviceValidated in
                        if deviceValidated {
                            runObservers()
                            completion?(nil)
                        } else {
                            completion?(.failed)
                        }
                    }
                } else {
                    completion?(.failed)
                }
            }
        }
        
        switch way {
        case .apple(let controller):
            FirewrapAuth.signInWithApple(on: controller) { data, signInError in
                if let signInError {
                    completion?(signInError)
                } else {
                    process()
                }
            }
        case .google(let controller):
            FirewrapAuth.signInWithGoogle(on: controller) { signInError in
                if let signInError {
                    completion?(signInError)
                } else {
                    process()
                }
            }
        case .email(let email, let handleURL):
            FirewrapAuth.signInWithEmail(email: email, handleURL: handleURL) { signInError in
                if let signInError {
                    completion?(signInError)
                } else {
                    process()
                }
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
    
    // MARK: - Observers
    
    // внутри обсерверов делаем валидацию автоматическую, в фоне так сказать
    
    static func runObservers() {
        debug("FirebaseProfile: Run observers")
    }
    
    static func stopObservers() {
        debug("FirebaseProfile: Stop observers")
    }
    
    // MARK: - Manage
    
    static func validateProfile(completion: @escaping (Bool) -> Void) {
        debug("FirebaseProfile: Validating profile...")
        
        guard
            let currentProfile = FirebaseProfile.profile,
            let profileDocument = firewrapProfileDocument
        else {
            debug("FirebaseProfile: Validated profile canceled, user not authed")
            completion(false)
            return
        }
        
        let updateProfileInFirestore: (_ completion: @escaping () -> Void) -> () = { completion in
            profileDocument.set([
                "email" : currentProfile.email,
                "name" : currentProfile.name ?? FirewrapFieldNil()
            ], merge: true, completion: {
                completion()
            })
        }
        
        profileDocument.get(.server) { data in
            if let data {
                let email = data["email"] as? String
                let name = data["name"] as? String
                
                if email != currentProfile.email || name != currentProfile.name {
                    updateProfileInFirestore {
                        debug("FirebaseProfile: Validated profile, data not match & updated")
                        completion(true)
                    }
                }
            } else {
                #warning("if no internet return false")
                updateProfileInFirestore {
                    debug("FirebaseProfile: Validated profile, no profile in database")
                    completion(true)
                }
            }
        }
    }
    
    static func validateDevice(completion: @escaping (Bool) -> Void) {
        debug("FirebaseProfile: Validating device...")
        debug("FirebaseProfile: Validated device")
        completion(true)
    }
    
    static var firewrapProfileDocument: FirewrapDocument? {
        guard let currentProfile = FirebaseProfile.profile else { return nil }
        return FirewrapDocument("/profiles/" + currentProfile.id)
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
