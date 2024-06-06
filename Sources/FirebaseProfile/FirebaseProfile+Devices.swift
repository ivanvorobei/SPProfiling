import Foundation
import FirewrapDatabase

extension FirebaseProfile {
    
    static func startObserveChanges() {
        
    }
    
    static func endObserveChanges() {
        
    }
    
    static var firewrapDevicesCollection: FirewrapCollection? {
        guard let profileDocument = FirebaseProfile.Profile.firewrapDocument else { return nil }
        return FirewrapCollection(profileDocument.path + "/devices")
    }
}
