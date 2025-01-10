import UIKit
import Firebase
import Firewrap
import FirewrapAuth
import FirewrapDatabase
import SwiftBoost

public class FirebaseProfile {
    
    // MARK: - Public
    // MARK: Configure
    
    public static func configure(with options: FirebaseOptions) {
        Firewrap.configure(with: options)
        FirewrapAuth.configure(authDidChangedWork: {
            
            printConsole("Auth state did change to \(FirewrapAuth.isAuthed.description)")
            
            if shared.isSignInProcess {
                printConsole("Sign in process going so observers running skip")
            } else {
                if isAuthed {
                    runObservers()
                } else {
                    stopObservers()
                }
            }
            
            NotificationCenter.default.post(name: .firebaseProfileDidChangedAuth)
        })
        
        if isAuthed {
            runObservers()
        }
    }
    
    public static func enableObserveDevicesList() {
        printConsole("Enable observing devices collection. Run observer")
        shared.isEnabledObserveDevices = true
        runDevicesCollectionObserver()
    }
    
    public static func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return FirewrapAuth.application(app, open: url, options: options)
    }
    
    // MARK: Data
    
    public static var isAuthed: Bool { FirewrapAuth.userID != nil }
    public static var isSignInProcess: Bool { shared.isSignInProcess }
    
    public static var profile: FirebaseProfileModel? {
        guard let userID = FirewrapAuth.userID else { return nil }
        guard let userEmail = FirewrapAuth.userEmail else { return nil }
        return FirebaseProfileModel(
            id: userID,
            email: userEmail,
            name: FirewrapAuth.userName
        )
    }
    
    /**
     Cached devices which saved after `enableObserveDevicesList`.
     For get actual list devices without observing use `getDevices()`
     */
    public static var devices: [FirebaseProfileDeviceModel]? {
        guard isAuthed else { return nil }
        return shared.cachedDevices
    }
    
    public static func getDevices(completion: @escaping ([FirebaseProfileDeviceModel]) -> Void) {
        guard let collection = FirewrapModels.makeFirewrapDevicesCollection() else {
            completion([])
            return
        }
        collection.getDocuments(as: FirebaseProfileDeviceModel.self, source: .server) { devices, errror in
            completion(devices ?? [])
        }
    }
    
    public static var authProviders: [FirewrapAuthProvider] { FirewrapAuth.providers }
    
    // MARK: Actions
    
    public static func signIn(with way: FirebaseAuthWay, completion: ((FirewrapAuthSignInError?) -> Void)?) {
        
        shared.isSignInProcess = true
        
        let preparing = {
            saveDevice { success, error in
                
                if success {
                    runObservers()
                    completion?(nil)
                } else {
                    stopObservers()
                    completion?(.unknow)
                }
                
                // Done Sign In process
                shared.isSignInProcess = false
            }
        }
        
        switch way {
        case .apple(let controller):
            FirewrapAuth.signInWithApple(on: controller) { data, signInError in
                if let signInError {
                    shared.isSignInProcess = false
                    completion?(signInError)
                } else {
                    preparing()
                }
            }
        case .google(let controller):
            FirewrapAuth.signInWithGoogle(on: controller) { signInError in
                if let signInError {
                    shared.isSignInProcess = false
                    completion?(signInError)
                } else {
                    preparing()
                }
            }
        case .email(let email, let handleURL):
            FirewrapAuth.signInWithEmail(email: email, handleURL: handleURL) { signInError in
                if let signInError {
                    shared.isSignInProcess = false
                    completion?(signInError)
                } else {
                    preparing()
                }
            }
        }
    }
    
    public static func signOut(completion: @escaping (Error?)->Void = { _ in }) {
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
    
    // MARK: Observers

    private static func runObservers() {
        
        printConsole("Run profile & current device observers")
        
        // Middleware
        guard FirebaseProfile.isAuthed else { return }
        
        // Reset Documents
        shared.firewrapProfileDocument?.removeObserver()
        shared.firewrapProfileDocument = FirewrapModels.makeFirewrapProfileDocument()
        
        shared.firewrapDeviceDocument?.removeObserver()
        shared.firewrapDeviceDocument = FirewrapModels.makeFirewrapDeviceDocument()
        
        // Listners
        shared.firewrapProfileDocument?.observe { data in
            printConsole("Profile Observer got update")
            guard let currentProfile = FirebaseProfile.profile else { return }
            let storedEmail = data?["email"] as? String
            let storedName = data?["name"] as? String
            if currentProfile.email != storedEmail || currentProfile.name != storedName {
                printConsole("Stored email or name not match to auth meta email, run update")
                saveProfile()
            }
        }
        
        shared.firewrapDeviceDocument?.observe(as: FirebaseProfileDeviceModel.self) { device in
            printConsole("Device Observer got update")
            if let device {
                if device.status == .suspended {
                    printConsole("Current device status suspended. Start sign out process")
                    signOut()
                } else {
                    if device != FirebaseProfileDeviceModel.current {
                        printConsole("Remote device not match to current device. Updating fields")
                        saveDevice()
                    }
                }
            } else {
                printConsole("Device not in list. Adding...")
                saveDevice()
            }
        }
        
        if shared.isEnabledObserveDevices {
            runDevicesCollectionObserver()
        }
    }
    
    static func runDevicesCollectionObserver() {
        
        printConsole("Run devices collection observer")
        
        shared.firewrapDeviceCollection?.removeObserver()
        shared.firewrapDeviceCollection = FirewrapModels.makeFirewrapDevicesCollection()
        
        shared.firewrapDeviceCollection?.observe(as: FirebaseProfileDeviceModel.self) { devices in
            printConsole("Devices Collection Observer got update")
            guard let devices else { return }
            shared.cachedDevices = devices
            NotificationCenter.default.post(name: .firebaseProfileDidUpdatedDevices)
        }
    }
    
    private static func stopObservers() {
        printConsole("Stop profile & current device observers")
        shared.firewrapProfileDocument?.removeObserver()
        shared.firewrapDeviceDocument?.removeObserver()
        shared.firewrapDeviceCollection?.removeObserver()
    }
    
    // MARK: - Singltone
    
    internal var firewrapProfileDocument: FirewrapDocument? = nil
    internal var firewrapDeviceDocument: FirewrapDocument? = nil
    internal var firewrapDeviceCollection: FirewrapCollection? = nil
    
    private var isSignInProcess: Bool = false
    
    private var isEnabledObserveDevices: Bool = false
    private var cachedDevices: [FirebaseProfileDeviceModel] = []
    
    static let shared = FirebaseProfile()
    private init() {}
}
