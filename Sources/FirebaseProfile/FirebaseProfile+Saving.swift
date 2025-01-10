import Foundation
import SwiftBoost
import FirewrapAuth
import FirewrapDatabase

extension FirebaseProfile {
    
    /**
     Saving auth meta to Firestore field.
     Main reason using this values later, for example from backend.
     */
    static func saveProfile(completion: @escaping () -> Void = {}) {
        
        printConsole("Saving profile")
        
        // Middleware
        guard
            let currentProfile = FirebaseProfile.profile,
            let profileDocument = FirewrapModels.makeFirewrapProfileDocument()
        else {
            printConsole("Can't save profile becouse user not authenticated")
            completion()
            return
        }
        
        // Saving
        printConsole("Run operation saving profile to firestore")
        profileDocument.set([
            "email" : currentProfile.email,
            "name" : currentProfile.name ?? FirewrapFieldNil()
        ], merge: true, completion: { success, error in
            if let error {
                printConsole("Saving profile unsuccsesful, error: \(error.localizedDescription)")
                completion()
            } else {
                printConsole("Saving profile successful")
                completion()
            }
        })
    }
    
    static func saveDevice(completion: @escaping (Bool, Error?) -> Void = { _, _ in }) {
        
        printConsole("Saving current device")
        
        // Middleware
        guard
            let deviceCollection = FirewrapModels.makeFirewrapDevicesCollection(),
            let currentDevice = FirebaseProfileDeviceModel.current
        else {
            printConsole("Can't save current device becouse user not authenticated")
            completion(false, FirebaseProfileError.internal)
            return
        }
        
        // Saving
        printConsole("Saving operation current device to Firestore")
        deviceCollection.document(currentDevice.id).set(currentDevice, merge: false) { success, error in
            if let error {
                printConsole("Saving current device unsuccsesful, error: \(error.localizedDescription)")
                completion(success, error)
            } else {
                printConsole("Saving current device successful")
                completion(success, error)
            }
        }
    }
}
